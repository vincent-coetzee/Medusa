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
    public var fields: CompositeField
        {
        let fields = CompositeField(name: "Header Fields")
        fields.append(Field(name: "magicNumber",value: .magicNumber(self.magicNumber),offset: Medusa.kPageMagicNumberOffset))
        fields.append(Field(name: "checksum",value: .checksum(self.checksum),offset: Medusa.kPageChecksumOffset))
        fields.append(Field(name: "freeByteCount",value: .offset(self.freeByteCount),offset: Medusa.kPageFreeByteCountOffset))
        fields.append(Field(name: "firstFreeCellOffset",value: .offset(self.firstFreeCellOffset),offset: Medusa.kPageFirstFreeCellOffsetOffset))
        fields.append(Field(name: "freeCellCount",value: .offset(self.freeCellCount),offset: Medusa.kPageFreeCellCountOffset))
        fields.append(Field(name: "pageAddress",value: .address(self.pageAddress)))
//        fields.append(Field(name: "fileIdentifier",value: .integer(self.fileIdentifier)))
        fields.append(Field(name: "isDirty",value: .boolean(self.isDirty)))
        fields.append(Field(name: "needsDefragmentation",value: .boolean(self.needsDefragmentation)))
        fields.append(self.freeList.fields)
        return(fields)
        }
        
    internal var basePageSizeInBytes: Medusa.Integer64
        {
        Medusa.kPageHeaderSizeInBytes
        }

    internal var bufferSizeInBytes: Medusa.Integer64 = 0
    internal var buffer: UnsafeMutableRawPointer
    internal var magicNumber: Medusa.MagicNumber = 0xDEADB00BCAFED00D
    internal var freeByteCount: Medusa.Integer64 = 0
    internal var checksum: Medusa.Checksum = 0
    internal var freeList: FreeList!
    internal var firstFreeCellOffset: Medusa.Integer64
    internal var freeCellCount: Medusa.Integer64 = 0
    internal var pageAddress: Medusa.Address = 0
    internal var fileIdentifier: FileIdentifier = .empty
    internal var isDirty = false
    internal var needsDefragmentation = false
    
    public init(magicNumber: Medusa.MagicNumber)
        {
        self.buffer = UnsafeMutableRawPointer.allocate(byteCount: Medusa.kPageSizeInBytes, alignment: 1)
        self.buffer.initializeMemory(as: Medusa.Byte.self, repeating: 0, count: Medusa.kPageSizeInBytes)
        self.bufferSizeInBytes = Medusa.kPageSizeInBytes
        self.magicNumber = magicNumber
        self.firstFreeCellOffset = Medusa.kBTreePageHeaderSizeInBytes
        self.freeCellCount = 0
        self.pageAddress = 0
        self.needsDefragmentation = false
        self.isDirty = false
        self.initFreeCellList()
        self.freeList.write(to: self.buffer)
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
        self.fileIdentifier = page.fileIdentifier
        self.pageAddress = page.pageAddress
        self.buffer = page.buffer
        self.pageAddress = 0
        self.firstFreeCellOffset = 0
        self.readHeader()
        self.freeList = FreeList(buffer: self.buffer, atByteOffset: self.firstFreeCellOffset)
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
        self.freeCellCount = readInteger(self.buffer,Medusa.kPageFreeCellCountOffset)
        }
        
    internal func initFreeCellList()
        {
        let offset = self.basePageSizeInBytes + MemoryLayout<Medusa.Integer64>.size
        self.firstFreeCellOffset = offset
        self.freeByteCount = Medusa.kBTreePageSizeInBytes - self.basePageSizeInBytes - MemoryLayout<Medusa.Integer64>.size
        self.freeList = FreeList(buffer: self.buffer,atByteOffset: self.firstFreeCellOffset,sizeInBytes: self.freeByteCount)
        self.freeList.write(to: self.buffer)
        self.isDirty = true
        }
        
    internal func read()
        {
        self.readHeader()
        }
        
    internal func writeChecksum()
        {
        // set the checksum to 0 before we do the checksum to ensure we get a clean checksum
        writeUnsigned64(self.buffer,UInt64(0),Medusa.kPageChecksumOffset)
        let data = UnsafePointer<UInt32>(OpaquePointer(self.buffer))
        let length = Medusa.kBTreePageSizeInBytes
        self.checksum = fletcher64(data,length)
        writeUnsigned64(self.buffer,self.checksum,Medusa.kPageChecksumOffset)
        }
        
    public func write() throws
        {
        if self.needsDefragmentation
            {
            try self.rewritePage()
            }
        self.writeChecksum()
        self.writeHeader()
        self.writeFreeList()
        }
        
    internal func rewritePage() throws
        {
        self.freeByteCount = Medusa.kBTreePageSizeInBytes - self.basePageSizeInBytes - MemoryLayout<Medusa.Integer64>.size
        self.initFreeCellList()
        self.writeFreeList()
        self.writeHeader()
        self.writeChecksum()
        self.needsDefragmentation = false
        }
        
    internal func allocate(sizeInBytes: Int) throws -> Medusa.Integer64
        {
        if self.freeByteCount < sizeInBytes && self.needsDefragmentation
            {
            try self.rewritePage()
            }
        let byteOffset = try self.freeList.allocate(from: self.buffer,sizeInBytes: sizeInBytes)
        self.freeByteCount -= sizeInBytes
        return(byteOffset)
        }
        
    internal func deallocate(at: Int) throws
        {
        if at < 0 || at > Medusa.kPageSizeInBytes
            {
            throw(SystemIssue(code: .invalidIntraPageAddress,agentKind: .pageServer,message: "Byte offset in Page.deallocate is \(at) but should be > 0 and < \(Medusa.kPageSizeInBytes)."))
            }
        let sizeInBytes = readInteger(buffer,at)
        if sizeInBytes < 0 || sizeInBytes > Medusa.kPageSizeInBytes
            {
            throw(SystemIssue(code: .invalidIntraPageAddress,agentKind: .pageServer,message: "Cell size in Page.deallocate is \(sizeInBytes) but should be > 0 and < \(Medusa.kPageSizeInBytes)."))
            }
        self.freeList.deallocate(from: buffer,atByteOffset: at - MemoryLayout<Medusa.Integer64>.size,sizeInBytes: Int(sizeInBytes))
        self.needsDefragmentation = true
        }
    }


public class PageWrapper: Buffer
    {
    public var rawPointer: UnsafeMutableRawPointer
        {
        self.page.buffer
        }
        
    public var fields: CompositeField
        {
        self.page.fields
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
        
    public func allocate(sizeInBytes: Medusa.Integer64) throws -> Medusa.Integer64
        {
        try self.page.allocate(sizeInBytes: sizeInBytes)
        }
        
    public func deallocate(at: Medusa.Integer64) throws
        {
        try self.page.deallocate(at: at)
        }
        
    public func flush()
        {
        do
            {
            try self.page.write()
            }
        catch let error
            {
            print(error)
            }
        }
    }
