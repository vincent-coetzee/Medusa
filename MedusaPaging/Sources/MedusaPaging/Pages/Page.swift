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

public protocol PageProtocol: AnyObject,Equatable
    {
    var pageOffset: Integer64 { get set }
    var nextPageOffset: Integer64 { get set }
    var freeByteCount: Integer64 { get set }
    var nextPage: (any PageProtocol)? { get set }
    var previousPage: (any PageProtocol)? { get set }
    var isStubbed: Bool { get }
    var magicNumber: Unsigned64 { get set }
    init(emptyPageAtOffset: Integer64)
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
            
        public var pageClass: Page.Type
            {
            switch(self)
                {
                case .page:
                    return(Page.self)
                case .objectPage:
                    return(ObjectPage.self)
                case .btreeNodePage:
                    return(BTreeNodePage.self)
                case .btreeRootPage:
                    return(BTreeRootPage.self)
                case .blockPage:
                    return(BlockPage.self)
                case .rootPage:
                    return(RootPage.self)
                case .overflowPage:
                    return(OverflowPage.self)
                case .hashtableRootPage:
                    return(HashtableRootPage.self)
                case .hashtableBucketPage:
                    return(HashtableBucketPage.self)
                case .freePage:
                    return(Page.self)
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
    public static let kPagePageOffsetOffset                    = kPageMagicNumberOffset + MemoryLayout<Integer64>.size
    public static let kPageNextPageOffsetOffset                = kPagePageOffsetOffset + MemoryLayout<Integer64>.size
    public static let kPagePreviousPageOffsetOffset            = kPageNextPageOffsetOffset + MemoryLayout<Integer64>.size
    public static let kPageFreeByteCountOffset                 = kPagePreviousPageOffsetOffset + MemoryLayout<Integer64>.size
    public static let kPageChecksumOffset                      = kPageFreeByteCountOffset + MemoryLayout<Integer64>.size
    public static let kPageFreeCellCountOffset                 = kPageChecksumOffset + MemoryLayout<Integer64>.size
    public static let kPageHeaderSizeInBytes                   = kPageFreeCellCountOffset + MemoryLayout<Integer64>.size
    
    public static let kPageStubSizeInBytes                     = kPageHeaderSizeInBytes
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
    internal var bufferSizeInBytes: Integer64
    public   var buffer: RawPointer
    private  let accessLock = NSRecursiveLock()

    open var checksum: Unsigned64
        {
        get
            {
            self.buffer.load(fromByteOffset: Page.kPageChecksumOffset,as: Unsigned64.self)
            }
        set
            {
            self.buffer.storeBytes(of: newValue, toByteOffset: Page.kPageChecksumOffset, as: Unsigned64.self)
            self.isDirty = true
            }
        }
    
    open var magicNumber: Unsigned64
        {
        get
            {
            self.buffer.load(fromByteOffset: Page.kPageMagicNumberOffset,as: Unsigned64.self)
            }
        set
            {
            self.buffer.storeBytes(of: newValue, toByteOffset: Page.kPageMagicNumberOffset, as: Unsigned64.self)
            self.isDirty = true
            }
        }
        
    open var freeByteCount: Integer64
        {
        get
            {
            self.buffer.load(fromByteOffset: Page.kPageFreeByteCountOffset,as: Integer64.self)
            }
        set
            {
            self.buffer.storeBytes(of: newValue, toByteOffset: Page.kPageFreeByteCountOffset, as: Integer64.self)
            self.isDirty = true
            }
        }
        
    internal var freeList: FreeBlockList!
    
    open var pageOffset: Integer64
        {
        get
            {
            self.buffer.load(fromByteOffset: Page.kPagePageOffsetOffset,as: Integer64.self)
            }
        set
            {
            self.buffer.storeBytes(of: newValue, toByteOffset: Page.kPagePageOffsetOffset, as: Integer64.self)
            self.isDirty = true
            }
        }
        
    open var nextPageOffset: Integer64
        {
        get
            {
            self.buffer.load(fromByteOffset: Page.kPageNextPageOffsetOffset,as: Integer64.self)
            }
        set
            {
            self.buffer.storeBytes(of: newValue, toByteOffset: Page.kPageNextPageOffsetOffset, as: Integer64.self)
            self.isDirty = true
            }
        }
        
    open var previousPageOffset: Integer64
        {
        get
            {
            self.buffer.load(fromByteOffset: Page.kPagePreviousPageOffsetOffset,as: Integer64.self)
            }
        set
            {
            self.buffer.storeBytes(of: newValue, toByteOffset: Page.kPagePreviousPageOffsetOffset, as: Integer64.self)
            self.isDirty = true
            }
        }
        
    open var nextPage: (any PageProtocol)?
        {
        didSet
            {
            self.nextPageOffset = self.nextPage?.pageOffset ?? 0
            }
        }
        
    open var previousPage: (any PageProtocol)?
        {
        didSet
            {
            self.previousPageOffset = self.previousPage?.pageOffset ?? 0
            }
        }
    
    open var isDirty = false
    internal var needsDefragmentation = false
    internal var lastAccessTimestamp = Medusa.timeInMicroseconds
    public private(set) var isStubbed = false
    
    public required init(stubBuffer: RawPointer,pageOffset offset: Integer64,sizeInBytes: Integer64)
        {
        self.buffer = stubBuffer
        self.bufferSizeInBytes = sizeInBytes
        self.pageOffset = offset
        self.isStubbed = true
        self.checksum = 0
        self.lastAccessTimestamp = Medusa.timeInMicroseconds
        self.initFreeCellList()
        self.magicNumber = Page.kPageMagicNumber
        }
        
    public required init(emptyPageAtOffset: Integer64)
        {
        self.buffer = RawPointer.allocate(byteCount: Self.kPageSizeInBytes, alignment: 1)
        self.buffer.initializeMemory(as: Byte.self, repeating: 0, count: Self.kPageSizeInBytes)
        self.bufferSizeInBytes = Self.kPageSizeInBytes
        self.pageOffset = emptyPageAtOffset
        self.checksum = 0
        self.lastAccessTimestamp = Medusa.timeInMicroseconds
        self.initFreeCellList()
        self.freeList.writeAll(to: self.buffer)
        self.magicNumber = Page.kPageMagicNumber
        self.isStubbed = false
        }
        
    public required init()
        {
        let someBuffer = RawPointer.allocate(byteCount: Self.kPageSizeInBytes, alignment: 1)
        someBuffer.initializeMemory(as: Byte.self, repeating: 0, count: Self.kPageSizeInBytes)
        self.buffer = someBuffer
        self.bufferSizeInBytes = Self.kPageSizeInBytes
        self.pageOffset = 0
        self.checksum = 0
        self.lastAccessTimestamp = Medusa.timeInMicroseconds
        self.initFreeCellList()
        self.freeList.writeAll(to: self.buffer)
        self.magicNumber = Page.kPageMagicNumber
        self.isStubbed = false
        }
    //
    // In this case, the page takes over ownership of the
    // buffer because it will be freed when this object goes
    // bye bye.
    //
    public required init(buffer: RawPointer,sizeInBytes: Integer64)
        {
        self.buffer = buffer
        // these instance variables are all set evcen though they are loaded from the buffer,
        // this is due to Swift's inane way of handling initialization of instance variables
        self.bufferSizeInBytes = sizeInBytes
        self.checksum = 0
        self.freeList = FreeBlockList(buffer: buffer, atByteOffset: Self.kPageHeaderSizeInBytes)
        self.lastAccessTimestamp = Medusa.timeInMicroseconds
        self.pageOffset = 0
        self.loadHeader()
        self.isStubbed = false
        }
    //
    // Take a copy of the buffer, but do not take ownership.
    // The caller needs to deallocate the buffer
    //
    public init(copyPage page: Page)
        {
        self.buffer = RawPointer.allocate(byteCount: page.bufferSizeInBytes, alignment: 1)
        self.buffer.copyMemory(from: page.buffer, byteCount: page.bufferSizeInBytes)
        self.bufferSizeInBytes = page.bufferSizeInBytes
        // these instance variables are all set evcen though they are loaded from the buffer,
        // this is due to Swift's inane way of handling initialization of instance variables
        self.pageOffset = 0
        self.checksum = 0
        self.freeByteCount = 0
        self.loadHeader()
        self.freeList = FreeBlockList(buffer: self.buffer, atByteOffset: self.initialFreeCellOffset)
        self.lastAccessTimestamp = Medusa.timeInMicroseconds
        self.isStubbed = false
        self.pageOffset = page.pageOffset
        }
    //
    // Take a copy of the buffer but do not take ownership of it.
    //
    public init(copyBuffer buffer: RawPointer,sizeInBytes: Integer64)
        {
        self.buffer = RawPointer.allocate(byteCount: sizeInBytes, alignment: 1)
        self.buffer.copyMemory(from: buffer, byteCount: sizeInBytes)
        self.bufferSizeInBytes = sizeInBytes
        // these instance variables are all set evcen though they are loaded from the buffer,
        // this is due to Swift's inane way of handling initialization of instance variables
        self.pageOffset = 0
        self.checksum = 0
        self.loadHeader()
        self.freeList = FreeBlockList(buffer: self.buffer, atByteOffset: self.initialFreeCellOffset)
        self.lastAccessTimestamp = Medusa.timeInMicroseconds
        }
        
    deinit
        {
        self.buffer.deallocate()
        }
        
    public func loadContents(from file: FileIdentifier) throws
        {
        let nextAddress = self.nextPageOffset
        let previousAddress = self.previousPageOffset
        self.buffer.deallocate()
        self.bufferSizeInBytes = Self.kPageSizeInBytes
        self.buffer = try file.readBuffer(atOffset: self.pageOffset, sizeInBytes: Self.kPageSizeInBytes)
        self.freeList = FreeBlockList(buffer: self.buffer, atByteOffset: self.initialFreeCellOffset)
        self.lastAccessTimestamp = Medusa.timeInMicroseconds
        self.nextPageOffset = nextAddress
        self.previousPageOffset = previousAddress
        self.isStubbed = false
        }
        
    public static func ==(lhs:Page,rhs: Page) -> Bool
        {
        lhs.pageOffset == rhs.pageOffset
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
        self.lastAccessTimestamp = Medusa.timeInMicroseconds
        }
        
    internal func loadHeader()
        {
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
        self.checksum = 0
        let data = UnsafePointer<UInt32>(OpaquePointer(self.buffer))
        let length = Self.kPageSizeInBytes
        self.checksum = fletcher64(data,length)
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
        
    open func allocate(sizeInBytes: Int) throws -> Integer64
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
