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
    
    open var annotatedBytes: AnnotatedBytes
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
        bytes.annotations = allFields
        return(bytes)
        }
        
    internal var isLockedInMemory: Boolean = false
    internal var bufferSizeInBytes: Integer64
    public   var buffer: RawPointer
    private  let accessLock = NSRecursiveLock()
    internal var freeList: FreeBlockList!
    open var isDirty = false
    internal var needsDefragmentation = false
    internal var lastAccessTimestamp = Medusa.timeInMicroseconds
    public private(set) var isStubbed = false

    open var kind: Page.Kind
        {
        Page.Kind.page
        }
        
    open var initialFreeCellOffset: Integer64
        {
        Self.kPageSizeInBytes - FreeBlockListCell.kCellHeaderSizeInBytes
        }
        
    open var initialFreeByteCount: Integer64
        {
        Self.kPageSizeInBytes - Self.kPageHeaderSizeInBytes - FreeBlockListCell.kCellHeaderSizeInBytes
        }
        
    final var sizeInBytes: Integer64
        {
        Page.kPageSizeInBytes
        }
        
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
    
    //
    // Create a a stubbed page. The page takes ownership of the passed in stub buffer. This
    // is a required initializer because it's used by the PageServer to create Page instances
    // using the Page metatype.
    //
    public required init(stubBuffer: RawPointer,pageOffset offset: Integer64,sizeInBytes: Integer64)
        {
        self.buffer = stubBuffer
        self.bufferSizeInBytes = sizeInBytes
        self.pageOffset = offset
        self.lastAccessTimestamp = Medusa.timeInMicroseconds
        self.isStubbed = true
        self.magicNumber = Page.kPageMagicNumber
        // we don't initialize the free list because the stubbed buffer
        // does not contain free cell information. When loadContents is invoked
        // ( which destubs the stub ) the free list information is part of the loaded
        // buffer and the free list is constructed then.
        }
    //
    // This initializer is used when creating an empty clean page that
    // we do not yet know the page offset of. It's also used by some
    // subclass initializers.
    //
    public required init()
        {
        let someBuffer = RawPointer.allocate(byteCount: Self.kPageSizeInBytes, alignment: 1)
        someBuffer.initializeMemory(as: Byte.self, repeating: 0, count: Self.kPageSizeInBytes)
        self.buffer = someBuffer
        self.bufferSizeInBytes = Self.kPageSizeInBytes
        self.lastAccessTimestamp = Medusa.timeInMicroseconds
        self.initFreeCellList()
        self.freeList.writeAll(to: self.buffer)
        self.magicNumber = Page.kPageMagicNumber
        }
    //
    // In this case, the page takes over ownership of the
    // buffer because it will be freed when this object goes
    // bye bye. This initializer is used when loading a page
    // from disk.
    //
    public required init(buffer: RawPointer,sizeInBytes: Integer64)
        {
        self.buffer = buffer
        // these instance variables are all set even though they are loaded from the buffer,
        // this is due to Swift's inane way of handling initialization of instance variables
        self.bufferSizeInBytes = sizeInBytes
        self.freeList = FreeBlockList(buffer: buffer, atByteOffset: self.initialFreeCellOffset)
        self.lastAccessTimestamp = Medusa.timeInMicroseconds
        self.loadHeader()
        }
    //
    // We always own our own buffer, so we free it when we are
    // released. Also release all the free cells becuase they
    // are two way lists which means they form a retain cycle
    //
    deinit
        {
        self.buffer.deallocate()
        self.freeList.release()
        }
    //
    // This method effectively destubs a page by loading the full
    // page buffer from disk. Buffers in stubbed pages are truncated
    // buffers to save memory, they only contain the absolute essentials
    // of the page fields which are located right at the top
    // of the full page buffer, this allows a truncated buffer to easily
    // be loaded in when the page exists as a stub page.
    //
    public func loadContents(from file: FileIdentifier) throws
        {
        // save these two instance variables because they may have changed from
        // the page being in a stubbed page list and the values would be overwritten
        // when the complete buffer is loaded.
        let nextAddress = self.nextPageOffset
        let previousAddress = self.previousPageOffset
        self.buffer.deallocate()
        self.bufferSizeInBytes = Self.kPageSizeInBytes
        self.buffer = try file.readBuffer(atOffset: self.pageOffset, sizeInBytes: Self.kPageSizeInBytes)
        self.freeList = FreeBlockList(buffer: self.buffer, atByteOffset: self.initialFreeCellOffset)
        self.lastAccessTimestamp = Medusa.timeInMicroseconds
        // reapply these changes
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
        
    public func release()
        {
        self.nextPage?.release()
        self.nextPage = nil
        self.previousPage = nil
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
        
    internal func validateChecksum() throws
        {
        let oldChecksum = self.checksum
        self.checksum = 0
        let data = UnsafePointer<UInt32>(OpaquePointer(self.buffer))
        let length = Self.kPageSizeInBytes
        let newChecksum = fletcher64(data,length)
        if newChecksum != oldChecksum
            {
            throw(SystemIssue(code: .checksumsDiffer,agentKind: .pageServer))
            }
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
        // is this a reasonable size for a page
        if sizeInBytes >= self.initialFreeByteCount
            {
            throw(SystemIssue(code: .allocationRequestSizeExceedsMaximumPageObjectSize,agentKind: .pageServer))
            }
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

public typealias Pages = Array<Page>
