//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import MedusaCore

public class ObjectPage: Page
    {
    public static let kObjectPageTableSizeInSlots           = 128
    public static let kObjectPageTableSizeInBytes           = ObjectPage.kObjectPageTableSizeInSlots * MemoryLayout<Integer64>.size
    public static let kObjectPageTableCountOffset           = Page.kPageHeaderSizeInBytes + MemoryLayout<Integer64>.size
    public static let kObjectPageTableSlotCountOffset       = ObjectPage.kObjectPageTableCountOffset + MemoryLayout<Integer64>.size
    public static let kObjectPageNextPageOffsetOffset       = ObjectPage.kObjectPageTableSlotCountOffset + MemoryLayout<Integer64>.size
    public static let kObjectPageHeaderSizeInBytes          = ObjectPage.kObjectPageNextPageOffsetOffset + MemoryLayout<Integer64>.size
    
    open override var kind: Page.Kind
        {
        Page.Kind.objectPage
        }
        
    private var objectTable = Array<Integer64>()
    private var objectTableSize = 128
    private var objectTableCount = 0
    public var nextObjectPageOffset = 0
    private var objectTableSlotCount = ObjectPage.kObjectPageTableSizeInSlots
    
    open override var initialFreeCellOffset: Integer64
        {
        Self.kObjectPageHeaderSizeInBytes + Self.kObjectPageTableSizeInBytes
        }
        
    open override var initialFreeByteCount: Integer64
        {
        Self.kPageSizeInBytes - Self.kObjectPageHeaderSizeInBytes - Self.kObjectPageTableSizeInBytes
        }
        
    public override init()
        {
        super.init()
        self.magicNumber = Page.kObjectPageMagicNumber
        }
        
    public override init(from buffer: RawPointer)
        {
        super.init(from: buffer)
        }
        
    public override func storeHeader()
        {
        super.storeHeader()
        self.buffer.storeBytes(of: self.objectTableCount, toByteOffset: Self.kObjectPageTableCountOffset, as: Integer64.self)
        self.buffer.storeBytes(of: self.objectTableSlotCount, toByteOffset: Self.kObjectPageTableSlotCountOffset, as: Integer64.self)
        self.buffer.storeBytes(of: self.nextObjectPageOffset, toByteOffset: Self.kObjectPageNextPageOffsetOffset, as: Integer64.self)
        }
        
    public override func loadHeader()
        {
        super.loadHeader()
        self.objectTableCount = self.buffer.load(fromByteOffset: Self.kObjectPageTableCountOffset, as: Integer64.self)
        self.objectTableSlotCount = self.buffer.load(fromByteOffset: Self.kObjectPageTableSlotCountOffset, as: Integer64.self)
        self.nextObjectPageOffset = self.buffer.load(fromByteOffset: Self.kObjectPageNextPageOffsetOffset, as: Integer64.self)
        }
        
    public func hasFreeSpace(sizeInBytes: Integer64) -> Boolean
        {
        self.freeByteCount >= sizeInBytes && self.objectTableCount < self.objectTableSlotCount
        }
    }
