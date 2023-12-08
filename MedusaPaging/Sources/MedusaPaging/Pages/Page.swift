//
//  Page.swift
//  MedusaPaging
//
//  Created by Vincent Coetzee on 20/11/2023.
//

import Foundation
import MedusaStorage
import MedusaCore
import Fletcher

public class Page
    {
    //
    // Local constants
    //
    public static let kPageMagicNumberOffset                   = 0
    public static let kPageChecksumOffset                      = kPageMagicNumberOffset + MemoryLayout<Integer64>.size
    public static let kPageFreeByteCountOffset                 = kPageChecksumOffset + MemoryLayout<Integer64>.size
    public static let kPageFreeCellCountOffset                 = kPageFreeByteCountOffset + MemoryLayout<Integer64>.size
    public static let kPageHeaderSizeInBytes                   = kPageFreeCellCountOffset + MemoryLayout<Integer64>.size
    public static let kPageSizeInBytes                         = 16 * 1024
    //
    // Page Magic Numbers
    //
    public static let kPageMagicNumber: MagicNumber            = 0xFED_BAD_BEEF_F00D
    public static let kBTreePageMagicNumber: MagicNumber       = 0xFADE_DEED_CAFE_BABE
    public static let kObjectPageMagicNumber: MagicNumber      = 0xBEE_BABE_B0D_D00D
    public static let kOverlfowPageMagicNumber: MagicNumber    = 0xBAD_C0DE_D0D0_CAD
    public static let kRootPageMagicNumber: MagicNumber        = 0xDEAD_C0D_BAD_F00D
    
    public var fields: CompositeField
        {
        let fields = CompositeField(name: "Header Fields")
        let allFields = CompositeField(name: "Fields")
        allFields.append(fields)
        fields.append(Field(name: "magicNumber",value: .magicNumber(self.magicNumber),offset: Self.kPageMagicNumberOffset))
        fields.append(Field(name: "checksum",value: .checksum(self.checksum),offset: Self.kPageChecksumOffset))
        fields.append(Field(name: "freeByteCount",value: .offset(self.freeByteCount),offset: Self.kPageFreeByteCountOffset))
        fields.append(Field(name: "initialFreeCellOffset",value: .integer(self.initialFreeCellOffset)))
        fields.append(Field(name: "initialFreeByteCount",value: .integer(self.initialFreeByteCount)))
        fields.append(Field(name: "freeCellCount",value: .offset(self.freeCellCount),offset: Self.kPageFreeCellCountOffset))
        fields.append(Field(name: "pageAddress",value: .address(self.pageAddress)))
        fields.append(Field(name: "isDirty",value: .boolean(self.isDirty)))
        fields.append(Field(name: "needsDefragmentation",value: .boolean(self.needsDefragmentation)))
        allFields.append(self.freeList.fields)
        return(allFields)
        }
        
    internal var initialFreeCellOffset: Integer64
        {
        Self.kPageHeaderSizeInBytes
        }
        
    public var initialFreeByteCount: Integer64
        {
        Self.kPageSizeInBytes - Self.kPageHeaderSizeInBytes
        }
        
    internal var bufferSizeInBytes: Integer64 = 0
    public var buffer: UnsafeMutableRawPointer
    internal var magicNumber: MagicNumber = 0xDEADB00BCAFED00D
    internal var freeByteCount: Integer64 = 0
    internal var checksum: Checksum = 0
    internal var freeList: FreeList!
    internal var freeCellCount: Integer64 = 0
    internal var pageAddress: Address = 0
    internal var isDirty = false
    internal var needsDefragmentation = false
    
    public init(magicNumber: MagicNumber)
        {
        self.buffer = RawPointer.allocate(byteCount: Self.kPageSizeInBytes, alignment: 1)
        self.buffer.initializeMemory(as: Byte.self, repeating: 0, count: Self.kPageSizeInBytes)
        self.bufferSizeInBytes = Self.kPageSizeInBytes
        self.magicNumber = magicNumber
        self.freeCellCount = 0
        self.pageAddress = 0
        self.needsDefragmentation = false
        self.isDirty = false
        self.initFreeCellList()
        self.freeList.writeAll(to: self.buffer)
        }
        
    public init(from buffer: RawPointer)
        {
        self.buffer = buffer
        self.pageAddress = 0
        self.loadHeader()
        self.freeList = FreeList(buffer: self.buffer, atByteOffset: self.initialFreeCellOffset)
        }
        
    public init(from page: Page)
        {
        self.pageAddress = page.pageAddress
        self.buffer = page.buffer
        self.pageAddress = 0
        self.loadHeader()
        self.freeList = FreeList(buffer: self.buffer, atByteOffset: self.initialFreeCellOffset)
        }
        
    internal func storeFreeList()
        {
        self.freeList.writeAll(to: self.buffer)
        }
        
    internal func storeHeader()
        {
        self.freeCellCount = self.freeList.count
        writeUnsigned64(self.buffer,self.magicNumber,Self.kPageMagicNumberOffset)
        writeUnsigned64(self.buffer,self.checksum,Self.kPageChecksumOffset)
        writeInteger64(self.buffer,self.freeByteCount,Self.kPageFreeByteCountOffset)
        writeInteger64(self.buffer,self.freeCellCount,Self.kPageFreeCellCountOffset)
        }
        
    internal func loadHeader()
        {
        print("READING PAGE HEADER")
        self.magicNumber = readUnsigned64(self.buffer,Self.kPageMagicNumberOffset)
        var number = String(self.magicNumber,radix: 16,uppercase: true)
        print("     MAGIC NUMBER \(number)")
        number = String(self.checksum,radix: 16,uppercase: true)
        print("     CHECKSUM \(number)")
        // Store 0 into the checksum after we have loaded it so when we check the checksum it uses a value of 0 for the checksum in the calculation
        writeInteger64(self.buffer,0,Self.kPageChecksumOffset)
        self.freeByteCount = readInteger64(self.buffer,Self.kPageFreeByteCountOffset)
        print("     FREE BYTE COUNT \(self.freeByteCount)")
        self.freeCellCount = readInteger64(self.buffer,Self.kPageFreeCellCountOffset)
        }
        
    internal func initFreeCellList()
        {
        self.freeByteCount = self.initialFreeByteCount
        self.freeList = FreeList(buffer: self.buffer,atByteOffset: self.initialFreeCellOffset,sizeInBytes: self.initialFreeByteCount)
        self.freeList.writeAll(to: self.buffer)
        self.isDirty = true
        }
        
    internal func load()
        {
        self.loadHeader()
        }
        
    internal func storeChecksum()
        {
        // set the checksum to 0 before we do the checksum to ensure we get a clean checksum
        writeUnsigned64(self.buffer,UInt64(0),Self.kPageChecksumOffset)
        let data = UnsafePointer<UInt32>(OpaquePointer(self.buffer))
        let length = Self.kPageSizeInBytes
        self.checksum = fletcher64(data,length)
        writeUnsigned64(self.buffer,self.checksum,Self.kPageChecksumOffset)
        }
        
    public func store() throws
        {
//        if self.needsDefragmentation
//            {
//            try self.rewritePage()
//            }
        self.storeChecksum()
        self.storeHeader()
        self.storeFreeList()
        }
        
    internal func reStore() throws
        {
        self.initFreeCellList()
        self.storeFreeList()
        self.storeHeader()
        self.storeChecksum()
        self.needsDefragmentation = false
        }
        
    internal func allocate(sizeInBytes: Int) throws -> Integer64
        {
        // adjust size up by 8 bytes for storage of the size of the allocated chunk
        if self.freeByteCount < sizeInBytes && self.needsDefragmentation
            {
            try self.reStore()
            }
        // but pass the allocator the exact size the caller wants not the adjusted size
        let byteOffset = try self.freeList.allocate(from: self.buffer,sizeInBytes: sizeInBytes)
        self.freeByteCount -= sizeInBytes + FreeListBlockCell.kCellHeaderSizeInBytes
        return(byteOffset)
        }
        
    internal func deallocate(at: Int) throws
        {
        if at < 0 || at > Self.kPageSizeInBytes
            {
            throw(SystemIssue(code: .invalidIntraPageAddress,agentKind: .pageServer,message: "Byte offset in Page.deallocate is \(at) but should be > 0 and < \(Self.kPageSizeInBytes)."))
            }
        self.freeByteCount += try self.freeList.deallocate(from: buffer,atByteOffset: at)
        }
        
    public func fill(atByteOffset: Integer64,with: Byte,count: Integer64)
        {
        var offset = atByteOffset
        for _ in 0..<count
            {
            writeByteWithOffset(self.buffer,with,&offset)
            }
        }
    }


//public class PageWrapper: Buffer
//    {
//    public var rawPointer: UnsafeMutableRawPointer
//        {
//        self.page.buffer
//        }
//        
//    public var fields: CompositeField
//        {
//        self.page.fields
//        }
//        
//    public let page: Page
//    public let sizeInBytes: Int = Self.kPageSizeInBytes
//    
//    public init(page: Page)
//        {
//        self.page = page
//        }
//        
//    public subscript(_ index: Int) -> Medusa.Byte
//        {
//        get
//            {
//            self.page.buffer.loadUnaligned(fromByteOffset: index, as: Medusa.Byte.self)
//            }
//        set
//            {
//            UnsafeMutablePointer<Medusa.Byte>(OpaquePointer(self.page.buffer + index)).pointee = newValue
//            }
//        }
//        
//    public func allocate(sizeInBytes: Integer64) throws -> Integer64
//        {
//        try self.page.allocate(sizeInBytes: sizeInBytes)
//        }
//        
//    public func deallocate(at: Integer64) throws
//        {
//        try self.page.deallocate(at: at)
//        }
//        
//    public func fill(atByteOffset: Integer64,with: Medusa.Byte,count: Integer64)
//        {
//        self.page.fill(atByteOffset: atByteOffset, with: with, count: count)
//        }
//        
//    func addKey(_ key: String,value: String)
//        {
//        do
//            {
//            _ = try (self.page as? BTreePage<String,String>)?.insert(key: key, value: value)
//            }
//        catch let error
//            {
//            print(error)
//            }
//        }
//        
//    public func flush()
//        {
//        do
//            {
//            try self.page.write()
//            }
//        catch let error
//            {
//            print(error)
//            }
//        }
//        
//    public func compact() throws
//        {
//        try self.page.rewrite()
//        }
//    }

public typealias Pages = Array<Page>
