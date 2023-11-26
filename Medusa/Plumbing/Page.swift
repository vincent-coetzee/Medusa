//
//  MedusaPage.swift
//  Medusa
//
//  Created by Vincent Coetzee on 20/11/2023.
//

import Foundation
import Fletcher

public class Page
    {
    public var fieldSets: FieldSetList
        {
        let fields = FieldSet(name: "Header Fields")
        fields.append(Field(index: 0,name: "magicNumber",value: .magicNumber(self.magicNumber),offset: Medusa.kPageMagicNumberOffset))
        fields.append(Field(index: 1,name: "checksum",value: .checksum(self.checksum),offset: Medusa.kPageChecksumOffset))
        fields.append(Field(index: 2,name: "freeByteCount",value: .offset(self.freeByteCount),offset: Medusa.kPageFreeByteCountOffset))
        fields.append(Field(index: 3,name: "firstFreeCellOffset",value: .offset(self.firstFreeCellOffset),offset: Medusa.kPageFirstFreeCellOffsetOffset))
        fields.append(Field(index: 4,name: "freeCellCount",value: .offset(self.freeCellCount),offset: Medusa.kPageFreeCellCountOffset))
        fields.append(Field(index: 6,name: "pageAddress",value: .pageAddress(self.pageAddress)))
        fields.append(Field(index: 6,name: "file",value: .string(self.file?.path.string ?? "nil")))
        var list = FieldSetList()
        list["Header Fields"] = fields
        list["Free Cell Fields"] = self.freeList.freeListFields
        return(list)
        }

    internal var bufferSizeInBytes: Medusa.Integer64 = 0
    internal var buffer: UnsafeMutableRawPointer
    internal var magicNumber: Medusa.MagicNumber = 0xDEADB00BCAFED00D
    internal var freeByteCount: Medusa.Integer64 = 0
    internal var checksum: Medusa.Checksum = 0
    internal var freeList: FreeList!
    internal var firstFreeCellOffset: Medusa.Integer64
    internal var freeCellCount: Medusa.Integer64 = 0
    internal var pageAddress: Medusa.PageAddress = 0
    internal var file: File!
    internal var isDirty = false
    
    public required init(magicNumber: Medusa.MagicNumber)
        {
        self.buffer = UnsafeMutableRawPointer.allocate(byteCount: Medusa.kPageSizeInBytes, alignment: 1)
        self.buffer.initializeMemory(as: Medusa.Byte.self, repeating: 0, count: Medusa.kPageSizeInBytes)
        self.bufferSizeInBytes = Medusa.kPageSizeInBytes
        self.magicNumber = magicNumber
        self.firstFreeCellOffset = Medusa.kBTreePageHeaderSizeInBytes
        self.freeCellCount = 0
        self.pageAddress = 0
        self.initFreeCellList()
        }
        
    public init(from buffer: UnsafeMutableRawPointer)
        {
        self.buffer = buffer
        self.pageAddress = 0
        self.firstFreeCellOffset = 0
        self.readHeader()
        self.freeList = FreeList(buffer: self.buffer, atByteOffset: self.firstFreeCellOffset)
        }
        
    public init(from page: Page)
        {
        self.buffer = page.buffer
        self.pageAddress = 0
        self.firstFreeCellOffset = 0
        self.readHeader()
        self.freeList = FreeList(buffer: self.buffer, atByteOffset: self.firstFreeCellOffset)
        }
        
    public init(file: File,pageAddress: Medusa.PageAddress) throws
        {
        self.file = file
        self.pageAddress = pageAddress
        try self.file.seek(pageAddress: pageAddress)
        self.buffer = try self.file.readBuffer(sizeInBytes: Medusa.kPageSizeInBytes)
        self.firstFreeCellOffset = 0
        self.readHeader()
        }
        
    internal func writeFreeList()
        {
        self.firstFreeCellOffset = self.freeList.firstCell?.byteOffset ?? 0
        self.freeList.write(to: self.buffer)
        }
        
    internal func writeHeader()
        {
        self.freeCellCount = self.freeList.count
        writeUnsigned64(self.buffer,self.magicNumber,Medusa.kPageMagicNumberOffset)
        writeUnsigned64(self.buffer,self.checksum,Medusa.kPageChecksumOffset)
        writeInteger(self.buffer,self.freeByteCount,Medusa.kPageFreeByteCountOffset)
        self.freeCellCount = self.freeList.count
        writeInteger(self.buffer,self.freeList.firstCell?.byteOffset ?? 0,Medusa.kPageFirstFreeCellOffsetOffset)
        writeInteger(self.buffer,self.freeCellCount,Medusa.kPageFreeCellCountOffset)
        }
        
    internal func readHeader()
        {
        print("READING PAGE HEADER")
        self.magicNumber = readUnsigned64(self.buffer,Medusa.kPageMagicNumberOffset)
        var number = String(self.magicNumber,radix: 16,uppercase: true)
        print("     MAGIC NUMBER \(number)")
        number = String(self.checksum,radix: 16,uppercase: true)
        print("     CHECKSUM \(number)")
        // Store 0 into the checksum after we have loaded it so when we check the checksum it uses a value of 0 for the checksum in the calculation
        writeInteger(self.buffer,0,Medusa.kPageChecksumOffset)
        self.freeByteCount = readInteger(self.buffer,Medusa.kPageFreeByteCountOffset)
        print("     FREE BYTE COUNT \(self.freeByteCount)")
        self.firstFreeCellOffset = readInteger(self.buffer,Medusa.kPageFirstFreeCellOffsetOffset)
        print("     FIRST FREE CELL OFFSET \(self.firstFreeCellOffset)")
        }
        
    internal func initFreeCellList()
        {
        let offset = Medusa.kBTreePageHeaderSizeInBytes + MemoryLayout<Medusa.Integer64>.size * Medusa.kBTreePageKeysPerPage
        self.firstFreeCellOffset = offset
        self.freeByteCount = Medusa.kBTreePageSizeInBytes - Medusa.kBTreePageHeaderSizeInBytes - Medusa.kBTreePageKeysPerPage * MemoryLayout<Medusa.Integer64>.size
        self.freeList = FreeList(buffer: self.buffer,atByteOffset: self.firstFreeCellOffset,sizeInBytes: self.freeByteCount)
        self.freeList.write(to: self.buffer)
        self.isDirty = true
        }
        
    internal func read()
        {
        self.readHeader()
        }
        
    internal func allocate(sizeInBytes: Int) throws -> Medusa.Integer64
        {
        let byteOffset = try self.freeList.allocate(sizeInBytes: sizeInBytes)
        self.freeByteCount -= sizeInBytes
        return(byteOffset)
        }
    }


public class PageWrapper: Buffer
    {
    public var fieldSets: FieldSetList
        {
        self.page.fieldSets
        }
        
    public let page: Page
    public let sizeInBytes: Int = Medusa.kPageSizeInBytes
    
    public init(page: Page)
        {
        self.page = page
        }
        
    public subscript(_ index: Int) -> Medusa.Byte
        {
        get
            {
            self.page.buffer.loadUnaligned(fromByteOffset: index, as: Medusa.Byte.self)
            }
        set
            {
            UnsafeMutablePointer<Medusa.Byte>(OpaquePointer(self.page.buffer + index)).pointee = newValue
            }
        }
    }
