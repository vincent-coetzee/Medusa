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
    public static let kRootPageSizeInBytes                            = Page.kPageSizeInBytes
    public static let kRootPageFirstEmptyPageOffsetOffset             = Page.kPageHeaderSizeInBytes
    public static let kRootPageFirstObjectPageOffsetOffset            = RootPage.kRootPageFirstEmptyPageOffsetOffset + MemoryLayout<Integer64>.size
    public static let kRootPageFirstBlockPageOffsetOffset             = RootPage.kRootPageFirstObjectPageOffsetOffset + MemoryLayout<Integer64>.size
    public static let kRootPageFirstOverflowPageOffsetOffset          = RootPage.kRootPageFirstBlockPageOffsetOffset + MemoryLayout<Integer64>.size
    public static let kRootPageSystemDictionaryAddressOffset          = RootPage.kRootPageFirstOverflowPageOffsetOffset + MemoryLayout<Integer64>.size
    public static let kRootPageSystemModuleAddressOffset              = RootPage.kRootPageSystemDictionaryAddressOffset + MemoryLayout<Integer64>.size
    public static let kRootPageEndPageOffsetOffset                    = RootPage.kRootPageSystemModuleAddressOffset + MemoryLayout<Integer64>.size
    
    public static let kRootPageHeaderSizeInBytes                      = RootPage.kRootPageEndPageOffsetOffset + MemoryLayout<Integer64>.size
    
    open override var kind: Page.Kind
        {
        Page.Kind.rootPage
        }
        
    public var endPageOffset: Integer64
        {
        get
            {
            self.buffer.load(fromByteOffset: Self.kRootPageFirstEmptyPageOffsetOffset, as: Integer64.self)
            }
        set
            {
            self.buffer.storeBytes(of: newValue, toByteOffset: Self.kRootPageFirstEmptyPageOffsetOffset, as: Integer64.self)
            self.isDirty = true
            }
        }
        
    public var firstEmptyPageOffset: Integer64
        {
        get
            {
            self.buffer.load(fromByteOffset: Self.kRootPageFirstEmptyPageOffsetOffset, as: Integer64.self)
            }
        set
            {
            self.buffer.storeBytes(of: newValue, toByteOffset: Self.kRootPageFirstEmptyPageOffsetOffset, as: Integer64.self)
            self.isDirty = true
            }
        }
        
    public var firstObjectPageOffset: Integer64
        {
        get
            {
            self.buffer.load(fromByteOffset: Self.kRootPageFirstObjectPageOffsetOffset, as: Integer64.self)
            }
        set
            {
            self.buffer.storeBytes(of: newValue, toByteOffset: Self.kRootPageFirstObjectPageOffsetOffset, as: Integer64.self)
            self.isDirty = true
            }
        }
        
    public var firstBlockPageOffset: Integer64
        {
        get
            {
            self.buffer.load(fromByteOffset: Self.kRootPageFirstBlockPageOffsetOffset, as: Integer64.self)
            }
        set
            {
            self.buffer.storeBytes(of: newValue, toByteOffset: Self.kRootPageFirstBlockPageOffsetOffset, as: Integer64.self)
            self.isDirty = true
            }
        }
        
    public var firstOverflowPageOffset: Integer64
        {
        get
            {
            self.buffer.load(fromByteOffset: Self.kRootPageFirstOverflowPageOffsetOffset, as: Integer64.self)
            }
        set
            {
            self.buffer.storeBytes(of: newValue, toByteOffset: Self.kRootPageFirstOverflowPageOffsetOffset, as: Integer64.self)
            self.isDirty = true
            }
        }
        
    public var systemDictionaryAddress: ObjectAddress
        {
        get
            {
            ObjectAddress(bitPattern: self.buffer.load(fromByteOffset: Self.kRootPageSystemDictionaryAddressOffset, as: Unsigned64.self))
            }
        set
            {
            self.buffer.storeBytes(of: newValue.address, toByteOffset: Self.kRootPageSystemDictionaryAddressOffset, as: Unsigned64.self)
            self.isDirty = true
            }
        }
        
    public var systemModuleAddress: ObjectAddress
        {
        get
            {
            ObjectAddress(bitPattern: self.buffer.load(fromByteOffset: Self.kRootPageSystemModuleAddressOffset, as: Unsigned64.self))
            }
        set
            {
            self.buffer.storeBytes(of: newValue.address, toByteOffset: Self.kRootPageSystemModuleAddressOffset, as: Unsigned64.self)
            self.isDirty = true
            }
        }
        
    
    public required init()
        {
        super.init()
        self.magicNumber = Page.kRootPageMagicNumber
        }
        
    public required init(buffer: RawPointer,sizeInBytes: Integer64)
        {
        super.init(buffer: buffer,sizeInBytes: sizeInBytes)
        }
    
    public required init(stubBuffer: RawPointer, pageOffset offset: Integer64, sizeInBytes: Integer64) {
        fatalError("init(stubBuffer:pageOffset:sizeInBytes:) has not been implemented")
    }
    
    public required init(emptyPageAtOffset: Integer64) {
        fatalError("init(emptyPageAtOffset:) has not been implemented")
    }
    
    public override func loadHeader()
        {
        super.loadHeader()
        }
    
    public override func storeHeader()
        {
        super.storeHeader()
        }
    }
