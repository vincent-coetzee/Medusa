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

public protocol PageProtocol
    {
    var pageOffset: Integer64 { get set }
    var nextPageOffset: Integer64 { get set }
    var freeByteCount: Integer64 { get set }
    }
    
open class Page: PageProtocol
    {
    public enum Kind: Byte
        {
        case page                   = 0
        case objectPage             = 1
        case btreeNodePage          = 2
        case btreeRootPage          = 3
        case blockPage              = 4
        case rootPage               = 5
        case overflowPage           = 6
        case hashtableRootPage      = 7
        case hashtableBucketPage    = 8
        case freePage               = 9
        
        public var magicNumber: MagicNumber
            {
            switch(self)
                {
                case .page:
                    return(Page.kPageMagicNumber)
                case .objectPage:
                    return(Page.kObjectPageMagicNumber)
                case .btreeNodePage:
                    return(Page.kBTreeNodePageMagicNumber)
                case .btreeRootPage:
                    return(Page.kBTreeRootPageMagicNumber)
                case .blockPage:
                    return(Page.kBlockPageMagicNumber)
                case .rootPage:
                    return(Page.kRootPageMagicNumber)
                case .overflowPage:
                    return(Page.kOverflowPageMagicNumber)
                case .hashtableRootPage:
                    return(Page.kHashtableRootPageMagicNumber)
                case .hashtableBucketPage:
                    return(Page.kHashtableBucketPageMagicNumber)
                case .freePage:
                    return(0)
                }
            }
            
        public init?(magicNumber: MagicNumber)
            {
            if magicNumber == Page.kPageMagicNumber
                {
                self = .page
                }
            else if magicNumber == Page.kObjectPageMagicNumber
                {
                self = .objectPage
                }
            else if magicNumber == Page.kBTreeNodePageMagicNumber
                {
                self = .btreeNodePage
                }
            else if magicNumber == Page.kBTreeRootPageMagicNumber
                {
                self = .btreeRootPage
                }
            else if magicNumber == Page.kBlockPageMagicNumber
                {
                self = .blockPage
                }
            else if magicNumber == Page.kRootPageMagicNumber
                {
                self = .rootPage
                }
            else if magicNumber == Page.kOverflowPageMagicNumber
                {
                self = .overflowPage
                }
            else if magicNumber == Page.kHashtableRootPageMagicNumber
                {
                self = .hashtableRootPage
                }
            else if magicNumber == Page.kHashtableBucketPageMagicNumber
                {
                self = .hashtableBucketPage
                }
            else
                {
                return(nil)
                }
            }
        }
    //
    // Local constants
    //
    public static let kPageMagicNumberOffset                   = 0
    public static let kPageNextPageOffsetOffset                = kPageMagicNumberOffset + MemoryLayout<Integer64>.size
    public static let kPagePreviousPageOffsetOffset            = kPageNextPageOffsetOffset + MemoryLayout<Integer64>.size
    public static let kPageChecksumOffset                      = kPagePreviousPageOffsetOffset + MemoryLayout<Integer64>.size
    public static let kPageFreeByteCountOffset                 = kPageChecksumOffset + MemoryLayout<Integer64>.size
    public static let kPageFreeCellCountOffset                 = kPageFreeByteCountOffset + MemoryLayout<Integer64>.size
    public static let kPageHeaderSizeInBytes                   = kPageNextPageOffsetOffset + MemoryLayout<Integer64>.size
    
    public static let kPageSizeInBytes                         = 16 * 1024
    //
    // Page Magic Numbers
    //
    public static let kPageMagicNumber: MagicNumber                = 0x0FED_0BAD_BEEF_F00D
    public static let kBTreeRootPageMagicNumber: MagicNumber       = 0xFADE_DEED_CAFE_BABE
    public static let kBTreeNodePageMagicNumber: MagicNumber       = 0xFADE_B00B_D00B_BABE
    public static let kObjectPageMagicNumber: MagicNumber          = 0x0BEE_BABE_0B0D_D00D
    public static let kHashtableRootPageMagicNumber: MagicNumber   = 0xB0DE_0CAD_0BAD_BABE
    public static let kHashtableBucketPageMagicNumber: MagicNumber = 0xB0DE_D00D_BADE_BABE
    public static let kBlockPageMagicNumber: MagicNumber           = 0xCAFE_BADE_0BAD_D00B
    public static let kOverflowPageMagicNumber: MagicNumber        = 0x0BAD_C0DE_D0D0_0CAD
    public static let kRootPageMagicNumber: MagicNumber            = 0xDEAD_0C0D_0BAD_F00D
    
    open var annotations: AnnotatedBytes.CompositeAnnotation
        {
        let bytes = AnnotatedBytes(from: self.buffer, sizeInBytes: Self.kPageSizeInBytes)
        let fields = AnnotatedBytes.CompositeAnnotation(key: "Header Fields")
        let allFields = AnnotatedBytes.CompositeAnnotation(key: "Fields")
        allFields.append(fields)
        fields.append(bytes: bytes,key: "magicNumber",kind: .unsigned64,atByteOffset: Self.kPageMagicNumberOffset)
        fields.append(bytes: bytes,key: "checksum",kind: .unsigned64,atByteOffset: Self.kPageChecksumOffset)
        fields.append(bytes: bytes,key: "freeByteCount",kind: .integer64,atByteOffset: Self.kPageFreeByteCountOffset)
        fields.append(bytes: bytes,key: "initialFreeCellOffset",kind: .integer64Value(self.initialFreeCellOffset))
        fields.append(bytes: bytes,key: "initialFreeByteCount",kind: .integer64Value(self.initialFreeByteCount))
        fields.append(bytes: bytes,key: "freeCellCount",kind: .integer64,atByteOffset: Self.kPageFreeCellCountOffset)
        fields.append(bytes: bytes,key: "nextPageOffset",kind: .integer64,atByteOffset: Self.kPageNextPageOffsetOffset)
        fields.append(bytes: bytes,key: "pageOffset",kind: .integer64Value(self.pageOffset))
        fields.append(bytes: bytes,key: "isDirty",kind: .booleanValue(self.isDirty))
        fields.append(bytes: bytes,key: "needsDefragmentation",kind: .booleanValue(self.needsDefragmentation))
        allFields.append(self.freeList.annotations)
        return(allFields)
        }
        
    open var kind: Page.Kind
        {
        Page.Kind.page
        }
        
    open var initialFreeCellOffset: Integer64
        {
        Self.kPageHeaderSizeInBytes
        }
        
    open var initialFreeByteCount: Integer64
        {
        Self.kPageSizeInBytes - Self.kPageHeaderSizeInBytes
        }
        
    final var sizeInBytes: Integer64
        {
        Page.kPageSizeInBytes
        }
        
    internal var isLockedInMemory: Boolean = false
    internal var bufferSizeInBytes: Integer64 = 0
    public   var buffer: RawPointer = RawPointer(bitPattern: 1)!
    internal var magicNumber: MagicNumber = 0xDEADB00BCAFED00D
    private  let accessLock = NSRecursiveLock()

    internal var checksum: Checksum = 0
    
    public   var freeByteCount: Integer64 = 0
    internal var freeList: FreeBlockList!
    internal var freeCellCount: Integer64 = 0
    
    open     var pageOffset: Integer64 = 0
    open     var nextPageOffset = 0
    open     var previousPageOffset = 0
    
    internal var isDirty = false
    internal var needsDefragmentation = false
    internal var lastAccessTimestamp = Medusa.timeInMicroseconds
    
    public init()
        {
        self.magicNumber = Page.kPageMagicNumber
        self.buffer = RawPointer.allocate(byteCount: Self.kPageSizeInBytes, alignment: 1)
        self.buffer.initializeMemory(as: Byte.self, repeating: 0, count: Self.kPageSizeInBytes)
        self.bufferSizeInBytes = Self.kPageSizeInBytes
        self.freeCellCount = 0
        self.pageOffset = 0
        self.needsDefragmentation = false
        self.isDirty = false
        self.initFreeCellList()
        self.freeList.writeAll(to: self.buffer)
        self.lastAccessTimestamp = Medusa.timeInMicroseconds
        }
        
    public init(from buffer: RawPointer)
        {
        self.buffer = buffer
        self.pageOffset = 0
        self.loadHeader()
        self.freeList = FreeBlockList(buffer: self.buffer, atByteOffset: self.initialFreeCellOffset)
        self.lastAccessTimestamp = Medusa.timeInMicroseconds
        }
        
    public init(copyOf page: Page)
        {
        self.pageOffset = page.pageOffset
        self.buffer = RawPointer.allocate(byteCount: page.bufferSizeInBytes, alignment: 1)
        self.buffer.copyMemory(from: page.buffer, byteCount: page.bufferSizeInBytes)
        self.bufferSizeInBytes = page.bufferSizeInBytes
        self.loadHeader()
        self.freeList = FreeBlockList(buffer: self.buffer, atByteOffset: self.initialFreeCellOffset)
        self.lastAccessTimestamp = Medusa.timeInMicroseconds
        }
        
    deinit
        {
        self.buffer.deallocate()
        }
        
    public func lockInMemory()
        {
        self.accessLock.lock()
        defer
            {
            self.accessLock.unlock()
            }
        self.isLockedInMemory = true
        }
        
    public func unlockInMemory()
        {
        self.accessLock.lock()
        defer
            {
            self.accessLock.unlock()
            }
        self.isLockedInMemory = false
        }
        
    internal func storeFreeList()
        {
        self.freeList.writeAll(to: self.buffer)
        self.lastAccessTimestamp = Medusa.timeInMicroseconds
        }
        
    internal func storeHeader()
        {
        self.freeCellCount = self.freeList.count
        writeUnsigned64(self.buffer,self.magicNumber,Self.kPageMagicNumberOffset)
        writeUnsigned64(self.buffer,self.checksum,Self.kPageChecksumOffset)
        writeInteger64(self.buffer,self.freeByteCount,Self.kPageFreeByteCountOffset)
        writeInteger64(self.buffer,self.freeCellCount,Self.kPageFreeCellCountOffset)
        writeInteger64(self.buffer,self.nextPageOffset,Self.kPageNextPageOffsetOffset)
        self.lastAccessTimestamp = Medusa.timeInMicroseconds
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
        self.nextPageOffset = readInteger64(self.buffer,Self.kPageNextPageOffsetOffset)
        self.lastAccessTimestamp = Medusa.timeInMicroseconds
        }
        
    internal func initFreeCellList()
        {
        self.freeByteCount = self.initialFreeByteCount
        self.freeList = FreeBlockList(buffer: self.buffer,atByteOffset: self.initialFreeCellOffset,sizeInBytes: self.initialFreeByteCount)
        self.freeList.writeAll(to: self.buffer)
        self.isDirty = true
        self.lastAccessTimestamp = Medusa.timeInMicroseconds
        }
        
    internal func load()
        {
        self.loadHeader()
        self.lastAccessTimestamp = Medusa.timeInMicroseconds
        }
        
    internal func storeChecksum()
        {
        // set the checksum to 0 before we do the checksum to ensure we get a clean checksum
        writeUnsigned64(self.buffer,UInt64(0),Self.kPageChecksumOffset)
        let data = UnsafePointer<UInt32>(OpaquePointer(self.buffer))
        let length = Self.kPageSizeInBytes
        self.checksum = fletcher64(data,length)
        writeUnsigned64(self.buffer,self.checksum,Self.kPageChecksumOffset)
        self.lastAccessTimestamp = Medusa.timeInMicroseconds
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
        self.lastAccessTimestamp = Medusa.timeInMicroseconds
        }
        
    internal func restore() throws
        {
        self.initFreeCellList()
        self.storeFreeList()
        self.storeHeader()
        self.storeChecksum()
        self.needsDefragmentation = false
        self.lastAccessTimestamp = Medusa.timeInMicroseconds
        }
        
    internal func allocate(sizeInBytes: Int) throws -> Integer64
        {
        // adjust size up by 8 bytes for storage of the size of the allocated chunk
        if self.freeByteCount < sizeInBytes && self.needsDefragmentation
            {
            try self.restore()
            }
        // but pass the allocator the exact size the caller wants not the adjusted size
        let byteOffset = try self.freeList.allocate(from: self.buffer,sizeInBytes: sizeInBytes)
        self.freeByteCount -= sizeInBytes + FreeBlockListCell.kCellHeaderSizeInBytes
        self.lastAccessTimestamp = Medusa.timeInMicroseconds
        return(byteOffset)
        }
        
    internal func deallocate(at: Int) throws
        {
        if at < 0 || at > Self.kPageSizeInBytes
            {
            throw(SystemIssue(code: .invalidIntraPageAddress,agentKind: .pageServer,message: "Byte offset in Page.deallocate is \(at) but should be > 0 and < \(Self.kPageSizeInBytes)."))
            }
        self.freeByteCount += try self.freeList.deallocate(from: buffer,atByteOffset: at)
        self.lastAccessTimestamp = Medusa.timeInMicroseconds
        }
        
    public func fill(atByteOffset: Integer64,with: Byte,count: Integer64)
        {
        var offset = atByteOffset
        for _ in 0..<count
            {
            writeByteWithOffset(self.buffer,with,&offset)
            }
        self.lastAccessTimestamp = Medusa.timeInMicroseconds
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
