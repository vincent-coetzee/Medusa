//
//  RootPage.swift
//  Medusa
//
//  Created by Vincent Coetzee on 05/12/2023.
//

import Foundation
import Fletcher

public class FreePageList
    {
    private var firstCell: RawPointer?
    private var lastCell: RawPointer?
    
    public var firstCellAddress: Address
        {
        Address(bitPattern: self.firstCell)
        }
        
    public var lastCellAddress: Address
        {
        Address(bitPattern: self.lastCell)
        }
        
    public init(firstPageAddress: Address,lastFreePageAddress: Address)
        {
        self.firstCell = RawPointer(bitPattern: firstPageAddress)
        self.lastCell = RawPointer(bitPattern: lastFreePageAddress)
        }
        
    public init()
        {
        }
        
    public func appendFreePage(at pointer: RawPointer)
        {
        pointer.storeBytes(of: 0, as: Integer64.self)
        if self.lastCell.isNil
            {
            self.lastCell = pointer
            }
        else
            {
            self.lastCell!.storeBytes(of: Address(bitPattern: pointer),as: Address.self)
            }
        }
        
    public func firstFreePage() -> RawPointer?
        {
        if self.firstCell.isNil
            {
            return(nil)
            }
        let pointer = self.firstCell
        self.firstCell = RawPointer(bitPattern: pointer!.load(as: Address.self))
        return(pointer)
        }
    }
    
public class RootPage: Page
    {
    private static let kFirstFreePageAddressOffset      = Page.kHeaderSizeInBytes
    private static let kLastFreePageAddressOffset       = RootPage.kFirstFreePageAddressOffset + MemoryLayout<Address>.size
    private static let kLastAllocatedPageAddressOffset  = RootPage.kLastFreePageAddressOffset + MemoryLayout<Address>.size
    
    private var lastAllocatedPageOffset: Integer64 = 0
    private var freePageList: FreePageList
    private var accessLock = NSLock()
    
    
    public override init(from: RawPointer)
        {
        super.init(from: from)
        self.readHeader()
        }
        
    internal override func readHeader()
        {
        super.readHeader()
        self.freePageList = FreePageList(firstPageAddress: readInteger(self.buffer,Self.kFirstFreePageAddressOffset),lastFreePageAddress: readInteger(self.buffer,Self.kLastFreePageAddressOffset))
        self.lastAllocatedPageOffset = readInteger(self.buffer,Self.kLastAllocatedPageAddressOffset)
        }
        
    public override func writeHeader()
        {
        self.accessLock.withLock
            {
            super.writeHeader()
            writeInteger(self.buffer,self.freePageList.firstCellAddress,Self.kFirstFreePageAddressOffset)
            writeInteger(self.buffer,self.lastAllocatedPageOffset,Self.kLastAllocatedPageAddressOffset)
            writeInteger(self.buffer,self.freePageList.lastCellAddress,Self.kLastFreePageAddressOffset)
            }
        }
        
    public func appendFreePage(_ page: Page)
        {
        self.accessLock.withLock
            {
            self.freePageList.appendFreePage(at: page.buffer)
            }
        }
    }
    
public protocol SimpleType
    {
    }

public class MOPPageProperty
    {
    private weak var page: Page?
    private let byteOffset: Integer64
    public let name: String
    private let propertyType: SimpleType.Type
    
    public init<T>(page: Page,name: String,value: T? = nil,atByteOffset: Integer64) where T:SimpleType
        {
        self.name = name
        self.byteOffset = atByteOffset
        self.page = page
        self.propertyType = T.self
        }
        
    public func setValue<T>(_ value: T) where T:SimpleType
        {
        if self.propertyType  == Integer64.self
            {
            
            }
        self.page!.buffer.storeBytes(of: value, toByteOffset: self.byteOffset, as: T.self)
        }
        
    public func value<T>(as: T.Type) -> T? where T:SimpleType
        {
        self.page!.buffer.load(fromByteOffset: self.byteOffset, as: T.self)
        }
    }
