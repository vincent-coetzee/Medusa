//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

    
import Foundation
import MedusaCore

public class RootPage: Page
    {
    public static let kRootPageSizeInBytes                      = Page.kPageSizeInBytes
    public static let kRootPageFirstEmptyPageCellOffset         = Page.kPageHeaderSizeInBytes
    
    open override var kind: Page.Kind
        {
        Page.Kind.rootPage
        }
        
    public var firstEmptyPageCellOffset = 0
    
    public override init()
        {
        super.init()
        self.magicNumber = Page.kRootPageMagicNumber
        }
        
    public override init(from: RawPointer)
        {
        super.init(from: from)
        self.firstEmptyPageCellOffset = self.buffer.load(fromByteOffset: Self.kRootPageFirstEmptyPageCellOffset, as: Integer64.self)

        }
        
    public override func loadHeader()
        {
        super.loadHeader()
        self.firstEmptyPageCellOffset = self.buffer.load(fromByteOffset: Self.kRootPageFirstEmptyPageCellOffset, as: Integer64.self)
        }

    public override func store() throws
        {
        try super.store()
        self.buffer.storeBytes(of: self.firstEmptyPageCellOffset, toByteOffset: Self.kRootPageFirstEmptyPageCellOffset, as: Integer64.self)
        }
//    public static let atomTable = IdentityDictionary(initializeCount:
//    
//
//
//    
//public class RootPage: Page
//    {
//    private static let kFirstFreePageAddressOffset      = Page.kHeaderSizeInBytes
//    private static let kLastFreePageAddressOffset       = RootPage.kFirstFreePageAddressOffset + MemoryLayout<Address>.size
//    private static let kLastAllocatedPageAddressOffset  = RootPage.kLastFreePageAddressOffset + MemoryLayout<Address>.size
//    
//    private var lastAllocatedPageOffset: Integer64 = 0
//    private var freePageList: FreePageList
//    private var accessLock = NSLock()
//    
//    
//    public override init(from: RawPointer)
//        {
//        super.init(from: from)
//        self.readHeader()
//        }
//        
//    internal override func readHeader()
//        {
//        super.readHeader()
//        self.freePageList = FreePageList(firstPageAddress: readInteger(self.buffer,Self.kFirstFreePageAddressOffset),lastFreePageAddress: readInteger(self.buffer,Self.kLastFreePageAddressOffset))
//        self.lastAllocatedPageOffset = readInteger(self.buffer,Self.kLastAllocatedPageAddressOffset)
//        }
//        
//    public override func writeHeader()
//        {
//        self.accessLock.withLock
//            {
//            super.writeHeader()
//            writeInteger(self.buffer,self.freePageList.firstCellAddress,Self.kFirstFreePageAddressOffset)
//            writeInteger(self.buffer,self.lastAllocatedPageOffset,Self.kLastAllocatedPageAddressOffset)
//            writeInteger(self.buffer,self.freePageList.lastCellAddress,Self.kLastFreePageAddressOffset)
//            }
//        }
//        
//    public func appendFreePage(_ page: Page)
//        {
//        self.accessLock.withLock
//            {
//            self.freePageList.appendFreePage(at: page.buffer)
//            }
//        }
//    }
//    
//public protocol SimpleType
//    {
//    }
//
//public class MOPPageProperty
//    {
//    private weak var page: Page?
//    private let byteOffset: Integer64
//    public let name: String
//    private let propertyType: SimpleType.Type
//    
//    public init<T>(page: Page,name: String,value: T? = nil,atByteOffset: Integer64) where T:SimpleType
//        {
//        self.name = name
//        self.byteOffset = atByteOffset
//        self.page = page
//        self.propertyType = T.self
//        }
//        
//    public func setValue<T>(_ value: T) where T:SimpleType
//        {
//        if self.propertyType  == Integer64.self
//            {
//            
//            }
//        self.page!.buffer.storeBytes(of: value, toByteOffset: self.byteOffset, as: T.self)
//        }
//        
//    public func value<T>(as: T.Type) -> T? where T:SimpleType
//        {
//        self.page!.buffer.load(fromByteOffset: self.byteOffset, as: T.self)
//        }
//    }

    }
