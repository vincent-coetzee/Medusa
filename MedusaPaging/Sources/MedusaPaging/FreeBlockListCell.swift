//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 12/12/2023.
//

import Foundation
import MedusaCore
import MedusaStorage

public class FreeBlockListCell: Equatable
    {
    public static let kCellHeaderSizeInBytes = MemoryLayout<Integer64>.size * 2 + MemoryLayout<Byte>.size
    private static let kAllocatedBitOffset = 32
    private static let kAllocatedBits = 1 << FreeBlockListCell.kAllocatedBitOffset
    
    // This is the difference between size of cell and requested allocation size
    public var deltaSize: Int = 0
    // This is the byte offset of the START OF THE CELL, not the start of the freee space,
    // the free space starts 2 words ahead of this beacuse every block has a header
    // containing a pointer to the next cell and the size of the block ( which includes
    // the 2 extra words )
    public var byteOffset: Int
    // The size in bytes of the whole cell
    public var sizeInBytes: Int
    // Pointer to next cell
    internal var lastCell: FreeBlockListCell?
    // Pointer tom previous cell
    internal var nextCell: FreeBlockListCell?
    public var isAllocated = false
     
    public var count: Integer64
        {
        1 + (self.nextCell?.count ?? 0)
        }
    
    public var endCell: FreeBlockListCell
        {
        if self.nextCell.isNotNil
            {
            return(self.nextCell!.endCell)
            }
        return(self)
        }
        
    public static func ==(lhs: FreeBlockListCell,rhs: FreeBlockListCell) -> Bool
        {
        lhs.byteOffset == rhs.byteOffset
        }
        
    public init(atByteOffset: Int,sizeInBytes: Int)
        {
        self.sizeInBytes = sizeInBytes
        self.byteOffset = atByteOffset
        self.lastCell = nil
        self.nextCell = nil
        }
    //
    // Read in the free list
    //
    public init(in buffer: RawPointer,atByteOffset: Int,lastCell: FreeBlockListCell?)
        {
        var pointer = buffer + atByteOffset
        let nextCellOffset = pointer.loadValue(as: Integer64.self)
        self.sizeInBytes = pointer.loadValue(as: Integer64.self)
        self.isAllocated = pointer.loadValue(as: Byte.self) == 1
        self.byteOffset = atByteOffset
        if nextCellOffset != 0
            {
            self.nextCell = FreeBlockListCell(in: buffer,atByteOffset: nextCellOffset,lastCell: self)
            }
        self.lastCell = lastCell
        }
        
    public func release()
        {
        self.nextCell?.release()
        self.lastCell = nil
        self.nextCell = nil
        }
        
    public func writeAll(to pageBuffer: UnsafeMutableRawPointer,number: Int = 0)
        {
        self.write(to: pageBuffer)
        self.nextCell?.write(to: pageBuffer,number: number + 1)
        }
        
    public func write(to pageBuffer: UnsafeMutableRawPointer,number: Int = 0)
        {
        var pointer = pageBuffer + self.byteOffset
        let value = self.nextCell?.byteOffset ?? 0
        pointer.storeValue(of: value,as: Integer64.self)
        pointer.storeValue(of: self.sizeInBytes,as: Integer64.self)
        pointer.storeValue(of: self.isAllocated ? 1 : 0,as: Byte.self)
        }
        
    public func cellsWithSufficientSpace(sizeInBytes size: Int) -> Array<FreeBlockListCell>
        {
        var cells = self.nextCell?.cellsWithSufficientSpace(sizeInBytes: sizeInBytes) ?? Array<FreeBlockListCell>()
        if self.sizeInBytes > size && !self.isAllocated
            {
            self.deltaSize = self.sizeInBytes - size
            cells.append(self)
            }
        return(cells)
        }
    }
