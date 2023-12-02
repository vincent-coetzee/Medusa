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
        let allFields = CompositeField(name: "Fields")
        allFields.append(fields)
        fields.append(Field(name: "magicNumber",value: .magicNumber(self.magicNumber),offset: Medusa.kPageMagicNumberOffset))
        fields.append(Field(name: "checksum",value: .checksum(self.checksum),offset: Medusa.kPageChecksumOffset))
        fields.append(Field(name: "freeByteCount",value: .offset(self.freeByteCount),offset: Medusa.kPageFreeByteCountOffset))
        fields.append(Field(name: "initialFreeCellOffset",value: .integer(self.initialFreeCellOffset)))
        fields.append(Field(name: "initialFreeByteCount",value: .integer(self.initialFreeByteCount)))
        fields.append(Field(name: "freeCellCount",value: .offset(self.freeCellCount),offset: Medusa.kPageFreeCellCountOffset))
        fields.append(Field(name: "pageAddress",value: .address(self.pageAddress)))
//        fields.append(Field(name: "fileIdentifier",value: .integer(self.fileIdentifier)))
        fields.append(Field(name: "isDirty",value: .boolean(self.isDirty)))
        fields.append(Field(name: "needsDefragmentation",value: .boolean(self.needsDefragmentation)))
        allFields.append(self.freeList.fields)
        return(allFields)
        }
        
    internal var initialFreeCellOffset: Medusa.Integer64
        {
        Medusa.kPageHeaderSizeInBytes
        }
        
    public var initialFreeByteCount: Medusa.Integer64
        {
        Medusa.kPageSizeInBytes - Medusa.kPageHeaderSizeInBytes
        }
        
    internal var bufferSizeInBytes: Medusa.Integer64 = 0
    internal var buffer: UnsafeMutableRawPointer
    internal var magicNumber: Medusa.MagicNumber = 0xDEADB00BCAFED00D
    internal var freeByteCount: Medusa.Integer64 = 0
    internal var checksum: Medusa.Checksum = 0
    internal var freeList: FreeList!
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
        self.freeCellCount = 0
        self.pageAddress = 0
        self.needsDefragmentation = false
        self.isDirty = false
        self.initFreeCellList()
        self.freeList.writeAll(to: self.buffer)
        }
        
    public init(from buffer: UnsafeMutableRawPointer)
        {
        self.buffer = buffer
        self.pageAddress = 0
        self.readHeader()
        self.freeList = FreeList(buffer: self.buffer, atByteOffset: self.initialFreeCellOffset)
        }
        
    public init(from page: Page)
        {
        self.fileIdentifier = page.fileIdentifier
        self.pageAddress = page.pageAddress
        self.buffer = page.buffer
        self.pageAddress = 0
        self.readHeader()
        self.freeList = FreeList(buffer: self.buffer, atByteOffset: self.initialFreeCellOffset)
        }
        
    internal func writeFreeList()
        {
        self.freeList.writeAll(to: self.buffer)
        }
        
    internal func writeHeader()
        {
        self.freeCellCount = self.freeList.count
        writeUnsigned64(self.buffer,self.magicNumber,Medusa.kPageMagicNumberOffset)
        writeUnsigned64(self.buffer,self.checksum,Medusa.kPageChecksumOffset)
        writeInteger(self.buffer,self.freeByteCount,Medusa.kPageFreeByteCountOffset)
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
        self.freeCellCount = readInteger(self.buffer,Medusa.kPageFreeCellCountOffset)
        }
        
    internal func initFreeCellList()
        {
        self.freeByteCount = self.initialFreeByteCount
        self.freeList = FreeList(buffer: self.buffer,atByteOffset: self.initialFreeCellOffset,sizeInBytes: self.initialFreeByteCount)
        self.freeList.writeAll(to: self.buffer)
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
//        if self.needsDefragmentation
//            {
//            try self.rewritePage()
//            }
        self.writeChecksum()
        self.writeHeader()
        self.writeFreeList()
        }
        
    internal func rewrite() throws
        {
        self.initFreeCellList()
        self.writeFreeList()
        self.writeHeader()
        self.writeChecksum()
        self.needsDefragmentation = false
        }
        
    internal func allocate(sizeInBytes: Int) throws -> Medusa.Integer64
        {
        // adjust size up by 8 bytes for storage of the size of the allocated chunk
        if self.freeByteCount < sizeInBytes && self.needsDefragmentation
            {
            try self.rewrite()
            }
        // but pass the allocator the exact size the caller wants not the adjusted size
        let byteOffset = try self.freeList.allocate(from: self.buffer,sizeInBytes: sizeInBytes)
        self.freeByteCount -= sizeInBytes + FreeListBlockCell.kCellHeaderSizeInBytes
        return(byteOffset)
        }
        
    internal func deallocate(at: Int) throws
        {
        if at < 0 || at > Medusa.kPageSizeInBytes
            {
            throw(SystemIssue(code: .invalidIntraPageAddress,agentKind: .pageServer,message: "Byte offset in Page.deallocate is \(at) but should be > 0 and < \(Medusa.kPageSizeInBytes)."))
            }
        self.freeByteCount += try self.freeList.deallocate(from: buffer,atByteOffset: at)
        }
        
    public func fill(atByteOffset: Medusa.Integer64,with: Medusa.Byte,count: Medusa.Integer64)
        {
        var offset = atByteOffset
        for _ in 0..<count
            {
            writeByteWithOffset(self.buffer,with,&offset)
            }
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
        
    public func fill(atByteOffset: Medusa.Integer64,with: Medusa.Byte,count: Medusa.Integer64)
        {
        self.page.fill(atByteOffset: atByteOffset, with: with, count: count)
        }
        
    func addKey(_ key: String,value: String)
        {
        do
            {
            _ = try (self.page as? BTreePage<String,String>)?.insert(key: key, value: value)
            }
        catch let error
            {
            print(error)
            }
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
        
    public func compact() throws
        {
        try self.page.rewrite()
        }
    }

public typealias Pages = Array<Page>
