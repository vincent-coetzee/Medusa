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
    public static let kObjectPageTableSlotCountOffset       = Page.kPageHeaderSizeInBytes
    public static let kObjectPageHeaderSizeInBytes          = ObjectPage.kObjectPageTableSlotCountOffset + MemoryLayout<Integer64>.size
    public static let kObjectPageTableOffset                = ObjectPage.kObjectPageHeaderSizeInBytes
    public static let kObjectPageMaximumObjectSizeInBytes   = (ObjectPage.kPageSizeInBytes - ObjectPage.kObjectPageHeaderSizeInBytes - ObjectPage.kObjectPageTableSizeInBytes) / MemoryLayout<Integer64>.size
    
    open override var kind: Page.Kind
        {
        Page.Kind.objectPage
        }
        
    private var objectTableSize = 128
    
    open var objectTableSlotCount: Integer64
        {
        get
            {
            self.buffer.load(fromByteOffset: Self.kObjectPageTableSlotCountOffset,as: Integer64.self)
            }
        set
            {
            self.buffer.storeBytes(of: newValue, toByteOffset: Self.kObjectPageTableSlotCountOffset, as: Integer64.self)
            self.isDirty = true
            }
        }
        
    open override var initialFreeCellOffset: Integer64
        {
        Self.kObjectPageHeaderSizeInBytes + Self.kObjectPageTableSizeInBytes
        }
        
    open override var initialFreeByteCount: Integer64
        {
        Self.kPageSizeInBytes - Self.kObjectPageHeaderSizeInBytes - Self.kObjectPageTableSizeInBytes
        }
        
    public required init()
        {
        super.init()
        self.magicNumber = Page.kObjectPageMagicNumber
        }
        
    public required init(buffer: RawPointer,sizeInBytes: Integer64)
        {
        super.init(buffer: buffer,sizeInBytes: sizeInBytes)
        self.magicNumber = Page.kObjectPageMagicNumber
        }
        
    public required init(stubBuffer: RawPointer,pageOffset: Integer64,sizeInBytes: Integer64)
        {
        super.init(stubBuffer: stubBuffer,pageOffset: pageOffset,sizeInBytes: sizeInBytes)
        self.magicNumber = Page.kObjectPageMagicNumber
        }
        
    public override func storeHeader()
        {
        super.storeHeader()
        }
        
    public override func loadHeader()
        {
        super.loadHeader()
        }
        
    public func hasObjectFreeSpace(sizeInBytes: Integer64) -> Boolean
        {
        self.freeByteCount >= sizeInBytes && self.objectTableSlotCount < Self.kObjectPageTableSizeInSlots
        }
 
    public func objectOffset(at: Integer64) -> Integer64
        {
        let offset =  Self.kObjectPageTableOffset + at * MemoryLayout<Integer64>.size
        return(self.buffer.load(fromByteOffset: offset, as: Integer64.self))
        }
        
    private func setObjectOffset(_ objectOffset: Integer64,at: Integer64)
        {
        let offset =  Self.kObjectPageTableOffset + at * MemoryLayout<Integer64>.size
        self.buffer.storeBytes(of: objectOffset, toByteOffset: offset, as: Integer64.self)
        self.isDirty = true
        }
        
    private func firstEmptyObjectSlotIndex() -> Integer64
        {
        var index = 0
        while index < self.objectTableSlotCount
            {
            if self.objectOffset(at: index) == 0
                {
                return(index)
                }
            }
        if index < Self.kObjectPageTableSizeInSlots
            {
            return(index)
            }
        fatalError("Object table slot count exceeded, this should not happen.")
        }
    //
    // This method allocates the actual bytes needed to store an object. Once the
    // bytes have been allocated the offset of the bytes is placed in the next available
    // slot in the page's object table and the index is returned. We have this extra level
    // of indirection in the object page ( by means of the object table ) so that the page
    // can be reorganised without affecting pointers to the object. The object table is
    // never reorganised so references to indexes into the table never need change.
    //
    open func allocateObjectBytes(sizeInBytes: Int) throws -> Integer64
        {
        if sizeInBytes >= Self.kObjectPageMaximumObjectSizeInBytes
            {
            throw(SystemIssue(code: .objectSizeExceedsPageSize,agentKind: .pageServer,message: "Attempt to allocate \(sizeInBytes) object bytes which exceeds the size of a page \(Page.kPageSizeInBytes)."))
            }
        let offset = try self.allocate(sizeInBytes: sizeInBytes)
        let index = self.firstEmptyObjectSlotIndex()
        self.setObjectOffset(offset,at: index)
        return(index)
        }
    }
