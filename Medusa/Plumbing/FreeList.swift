//
//  FreeList.swift
//  Medusa
//
//  Created by Vincent Coetzee on 23/11/2023.
//

import Foundation
import Fletcher

public class FreeListBlockCell: Equatable
    {
    public static let kCellHeaderSizeInBytes = MemoryLayout<Medusa.Integer64>.size * 2 + MemoryLayout<Medusa.Byte>.size
    private static let kAllocatedBitOffset = 32
    private static let kAllocatedBits = 1 << FreeListBlockCell.kAllocatedBitOffset
    
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
    internal var lastCell: FreeListBlockCell?
    // Pointer tom previous cell
    internal var nextCell: FreeListBlockCell?
    public var isAllocated = false
     
    public var count: Medusa.Integer64
        {
        1 + (self.nextCell?.count ?? 0)
        }
    
    public var endCell: FreeListBlockCell
        {
        if self.nextCell.isNotNil
            {
            return(self.nextCell!.endCell)
            }
        return(self)
        }
        
    public static func ==(lhs: FreeListBlockCell,rhs: FreeListBlockCell) -> Bool
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
    public init(in page: UnsafeMutableRawPointer,atByteOffset: Int,lastCell: FreeListBlockCell?)
        {
        var offset = atByteOffset
        let nextCellOffset = readIntegerWithOffset(page,&offset)
        self.sizeInBytes = readIntegerWithOffset(page,&offset)
        self.isAllocated = readByte(page,offset) == 1
        self.byteOffset = atByteOffset
        if nextCellOffset != 0
            {
            self.nextCell = FreeListBlockCell(in: page,atByteOffset: nextCellOffset,lastCell: self)
            }
        self.lastCell = lastCell
        }
        
    public func writeAll(to pageBuffer: UnsafeMutableRawPointer,number: Int = 0)
        {
        self.write(to: pageBuffer)
        self.nextCell?.write(to: pageBuffer,number: number + 1)
        }
        
    public func write(to pageBuffer: UnsafeMutableRawPointer,number: Int = 0)
        {
        var offset = self.byteOffset
        print("WRITING FREE LIST CELL \(number) AT \(offset)")
        let value = self.nextCell?.byteOffset ?? 0
        writeIntegerWithOffset(pageBuffer,value,&offset)
        print("     NEXT CELL OFFSET \(value)")
        writeIntegerWithOffset(pageBuffer,self.sizeInBytes,&offset)
        print("     SIZE IN BYTES \(self.sizeInBytes)")
        writeByte(pageBuffer,self.isAllocated ? 1 : 0,offset)
        print("     ALLOCATED \(self.isAllocated)")
        }
        
    public func cellsWithSufficientSpace(sizeInBytes size: Int) -> Array<FreeListBlockCell>
        {
        var cells = Array<FreeListBlockCell>()
        if self.sizeInBytes > size && !self.isAllocated
            {
            self.deltaSize = self.sizeInBytes - size
            cells.append(self)
            }
        if self.nextCell.isNotNil
            {
            cells.append(contentsOf: self.nextCell!.cellsWithSufficientSpace(sizeInBytes: size))
            }
        return(cells)
        }
    }

public class FreeList
    {
    public var count: Medusa.Integer64
        {
        self.firstCell.count
        }
        
    public var fields: CompositeField
        {
        let fields = CompositeField(name: "Free Cell Fields")
        var cell:FreeListBlockCell? = self.firstCell
        var count = 0
        while cell.isNotNil
            {
            assert(cell!.byteOffset != 0,"ByteOffset should not be 0 but is.")
            fields.append(Field(name: "Cell \(count) Next",value: .integer(cell!.nextCell?.byteOffset ?? 0),offset: cell!.byteOffset))
            fields.append(Field(name: "Cell \(count) Size",value: .integer(cell!.sizeInBytes),offset: cell!.byteOffset + MemoryLayout<Medusa.Integer64>.size))
            fields.append(Field(name: "Cell \(count) Allocated",value: .boolean(cell!.isAllocated),offset: cell!.byteOffset + 2 * MemoryLayout<Medusa.Integer64>.size))
            count += 1
            cell = cell?.nextCell
            }
        return(fields)
        }
        
    private var buffer: UnsafeMutableRawPointer
    public private(set) var firstCell: FreeListBlockCell
    private var endCell: FreeListBlockCell
    
    init(buffer: UnsafeMutableRawPointer,atByteOffset: Int,sizeInBytes: Int)
        {
        self.buffer = buffer
        self.firstCell = FreeListBlockCell(atByteOffset: atByteOffset,sizeInBytes: sizeInBytes)
        self.endCell = self.firstCell.endCell
        }
        
    init(buffer: UnsafeMutableRawPointer,atByteOffset: Int)
        {
        self.buffer = buffer
        self.firstCell = FreeListBlockCell(in: buffer,atByteOffset: Int(atByteOffset),lastCell: nil)
        self.endCell = self.firstCell.endCell
        }

    public func allocate(from buffer: UnsafeMutableRawPointer,sizeInBytes: Int) throws -> Medusa.Integer64
        {
        // Try the endCell to see if it has space
        let actualSize = sizeInBytes + FreeListBlockCell.kCellHeaderSizeInBytes
        if self.endCell.sizeInBytes > actualSize
            {
            // It has space, grab actualSize bytes and add a new end cell to the list
            let lastOffset = self.endCell.byteOffset
            let nextOffset = self.endCell.byteOffset + actualSize
            let nextSize = self.endCell.sizeInBytes - actualSize
            self.endCell.sizeInBytes = actualSize
            self.endCell.isAllocated = true
            let newEndCell = FreeListBlockCell(atByteOffset: nextOffset,sizeInBytes: nextSize)
            self.endCell.nextCell = newEndCell
            newEndCell.lastCell = self.endCell
            let oldEndCell = self.endCell
            self.endCell = newEndCell
            oldEndCell.writeAll(to: buffer)
            return(lastOffset + FreeListBlockCell.kCellHeaderSizeInBytes)
            }
        // There was no space in the end, see if we can find some free space in the list
        var cells = self.firstCell.cellsWithSufficientSpace(sizeInBytes: actualSize).sorted{$0.deltaSize < $1.deltaSize}
        if cells.isEmpty
            {
            self.coalesceFreeSpace(buffer: buffer)
            cells = self.firstCell.cellsWithSufficientSpace(sizeInBytes: actualSize).sorted{$0.deltaSize < $1.deltaSize}
            }
        guard !cells.isEmpty else
            {
            throw(SystemIssue(code: .insufficientFreeSpaceInPage, agentKind: .pageServer))
            }
        let bestCell = cells.first!
        // Use the space in the best cell by allocating it to the caller
        bestCell.isAllocated = true
        bestCell.write(to: buffer)
        return(bestCell.byteOffset + FreeListBlockCell.kCellHeaderSizeInBytes)
        }
        
    public func deallocate(from buffer: UnsafeMutableRawPointer,atByteOffset: Medusa.Integer64) throws -> Medusa.Integer64
        {
        var cell: FreeListBlockCell? = self.firstCell
        while cell.isNotNil
            {
            if atByteOffset - FreeListBlockCell.kCellHeaderSizeInBytes == cell!.byteOffset
                {
                cell!.isAllocated = false
                cell!.write(to: buffer)
                return(cell!.sizeInBytes)
                }
            cell = cell!.nextCell
            }
        throw(SystemIssue(code: .invalidDeallocationAddress,agentKind: .pageServer))
        }
        
    public func writeAll(to buffer: UnsafeMutableRawPointer)
        {
        print("WRITING FREE LIST FOR BUFFER \(buffer)")
        self.firstCell.writeAll(to: buffer,number: 0)
        }
        
    private func coalesceFreeSpace(buffer: UnsafeMutableRawPointer)
        {
        let cell: FreeListBlockCell? = self.firstCell
        while cell.isNotNil && cell!.nextCell.isNotNil
            {
            if !cell!.isAllocated && !cell!.nextCell!.isAllocated
                {
                cell!.sizeInBytes += cell!.nextCell!.sizeInBytes
                cell!.nextCell = cell!.nextCell!.nextCell
                cell!.nextCell!.lastCell = cell
                // calculate offset from which to zero out the new empty space
                let offsetBuffer = buffer + cell!.byteOffset + FreeListBlockCell.kCellHeaderSizeInBytes
                // calculate the number of bytes to zero
//                let size = cell!.sizeInBytes - FreeListBlockCell.kCellHeaderSizeInBytes
                // zero the coalesced memory
                offsetBuffer.initializeMemory(as: Medusa.Byte.self,repeating: 0,count: cell!.sizeInBytes)
                }
            }
        self.firstCell.writeAll(to: buffer)
        }
    }
