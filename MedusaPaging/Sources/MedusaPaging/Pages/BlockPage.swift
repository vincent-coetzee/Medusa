//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import MedusaCore

public class BlockPage: Page
    {
    public static let kBlockPageTotalSlotCountOffset            = Page.kPageHeaderSizeInBytes + MemoryLayout<Integer64>.size
    public static let kBlockPageThisSlotCountOffset             = BlockPage.kBlockPageTotalSlotCountOffset + MemoryLayout<Integer64>.size
    public static let kBlockPageSlotSizeInBytesOffset           = BlockPage.kBlockPageThisSlotCountOffset + MemoryLayout<Integer64>.size
    public static let kBlockPagePageTotalSlotCountOffset        = BlockPage.kBlockPageSlotSizeInBytesOffset + MemoryLayout<Integer64>.size
    public static let kBlockPageFirstEmptySlotIndexOffset       = BlockPage.kBlockPagePageTotalSlotCountOffset + MemoryLayout<Integer64>.size
    public static let kBlockPageSlotClassAddressOffset          = BlockPage.kBlockPageFirstEmptySlotIndexOffset + MemoryLayout<Integer64>.size
    
    public static let kBlockPageHeaderSizeInBytes               = BlockPage.kBlockPageFirstEmptySlotIndexOffset + MemoryLayout<Integer64>.size
        
    public private(set) var totalSlotCount: Integer64
        {
        get
            {
            self.buffer.load(fromByteOffset: Self.kBlockPageTotalSlotCountOffset, as: Integer64.self)
            }
        set
            {
            self.buffer.storeBytes(of: newValue, toByteOffset: Self.kBlockPageTotalSlotCountOffset, as: Integer64.self)
            }
        }
        
    public private(set) var slotCount: Integer64
        {
        get
            {
            self.buffer.load(fromByteOffset: Self.kBlockPageThisSlotCountOffset, as: Integer64.self)
            }
        set
            {
            self.buffer.storeBytes(of: newValue, toByteOffset: Self.kBlockPageThisSlotCountOffset, as: Integer64.self)
            }
        }
        
    public var slotSizeInBytes: Integer64
        {
        get
            {
            self.buffer.load(fromByteOffset: Self.kBlockPageSlotSizeInBytesOffset, as: Integer64.self)
            }
        set
            {
            self.buffer.storeBytes(of: newValue, toByteOffset: Self.kBlockPageSlotSizeInBytesOffset, as: Integer64.self)
            }
        }
        
    public private(set) var pageTotalSlotCount: Integer64
        {
        get
            {
            self.buffer.load(fromByteOffset: Self.kBlockPagePageTotalSlotCountOffset, as: Integer64.self)
            }
        set
            {
            self.buffer.storeBytes(of: newValue, toByteOffset: Self.kBlockPagePageTotalSlotCountOffset, as: Integer64.self)
            }
        }
        
    public private(set) var firstEmptySlotIndex: Integer64
        {
        get
            {
            self.buffer.load(fromByteOffset: Self.kBlockPageFirstEmptySlotIndexOffset, as: Integer64.self)
            }
        set
            {
            self.buffer.storeBytes(of: newValue, toByteOffset: Self.kBlockPageFirstEmptySlotIndexOffset, as: Integer64.self)
            }
        }
        
    public var slotClassAddress: ObjectAddress
        {
        get
            {
            ObjectAddress(bitPattern: self.buffer.load(fromByteOffset: Self.kBlockPageFirstEmptySlotIndexOffset, as: Unsigned64.self))
            }
        set
            {
            self.buffer.storeBytes(of: newValue.address, toByteOffset: Self.kBlockPageFirstEmptySlotIndexOffset, as: Unsigned64.self)
            }
        }
    
    open override var kind: Page.Kind
        {
        Page.Kind.blockPage
        }
        
    public required init(buffer: RawPointer,sizeInBytes: Integer64)
        {
        super.init(buffer: buffer,sizeInBytes: sizeInBytes)
        self.magicNumber = Page.kBlockPageMagicNumber
        }
        
    public required init()
        {
        super.init()
        self.magicNumber = Page.kBlockPageMagicNumber
        }
        
    public required init(emptyPageAtOffset offset: Integer64)
        {
        super.init(emptyPageAtOffset: offset)
        self.magicNumber = Page.kBlockPageMagicNumber
        }
    
    public required init(stubBuffer: RawPointer, pageOffset offset: Integer64, sizeInBytes: Integer64)
        {
        super.init(stubBuffer: stubBuffer,pageOffset: offset,sizeInBytes: sizeInBytes)
        }
    
    private func initSlots()
        {
        let availableSpace = Page.kPageSizeInBytes - BlockPage.kBlockPageHeaderSizeInBytes
        let availableSlots = availableSpace / self.slotSizeInBytes
        self.pageTotalSlotCount = availableSlots
        self.totalSlotCount = self.pageTotalSlotCount
        self.slotCount = 0
        self.firstEmptySlotIndex = 0
        
        }
    }

public class BitSet
    {
    public let sizeInBits: Integer64
    private var sizeInBytes: Integer64
    private var pointer: RawPointer
    private var buffer: RawPointer?
    private var ownsBuffer = false
    
    public init(sizeInBits: Integer64)
        {
        self.sizeInBits = sizeInBits
        self.sizeInBytes = sizeInBits / 8 + 1
        self.buffer = RawPointer.allocate(byteCount: self.sizeInBytes, alignment: 1)
        self.ownsBuffer = true
        self.pointer = self.buffer!
        }
        
    public init(sizeInBits: Integer64,pointer: RawPointer)
        {
        self.pointer = pointer
        self.sizeInBits = sizeInBits
        self.sizeInBytes = sizeInBits / 8 + 1
        self.ownsBuffer = false
        }
        
    deinit
        {
        if self.ownsBuffer
            {
            self.buffer?.deallocate()
            }
        }
        
    public func setValueOfBit(atIndex: Integer64,to: Integer64)
        {
        let offset = atIndex / 8
        let mask = Byte(atIndex % 8)
        var byte = self.pointer.load(fromByteOffset: offset, as: Byte.self)
        byte &= ~mask
        if to == 1
            {
            byte |= mask
            }
        self.pointer.storeBytes(of: byte, toByteOffset: offset, as: Byte.self)
        }
        
    public func valueOfBit(atIndex: Integer64) -> Integer64
        {
        let offset = atIndex / 8
        let mask = Byte(atIndex % 8)
        var byte = self.pointer.load(fromByteOffset: offset, as: Byte.self)
        return(Integer64((byte & mask) >> mask))
        }
    }
