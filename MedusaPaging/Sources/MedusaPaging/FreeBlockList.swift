//
//  FreeList.swift
//  Medusa
//
//  Created by Vincent Coetzee on 23/11/2023.
//

import Foundation
import MedusaStorage
import MedusaCore

public class FreeBlockList
    {
    public var count: Integer64
        {
        self.firstCell.count
        }
        
    public var annotations: AnnotatedBytes.CompositeAnnotation
        {
        let fields = AnnotatedBytes.CompositeAnnotation(key: "Free Cell Fields")
        var cell:FreeBlockListCell? = self.firstCell
        var count = 0
        let bytes = AnnotatedBytes(from: self.buffer, sizeInBytes: Page.kPageSizeInBytes)
        while cell.isNotNil
            {
            assert(cell!.byteOffset != 0,"ByteOffset should not be 0 but is.")
            fields.append(bytes: bytes,key: "Cell \(count) Next",kind: .integer64,atByteOffset: cell!.byteOffset)
            fields.append(bytes: bytes,key: "Cell \(count) Size",kind: .integer64,atByteOffset: cell!.byteOffset + MemoryLayout<Integer64>.size)
            fields.append(bytes: bytes,key: "Cell \(count) Allocated",kind: .boolean,atByteOffset: cell!.byteOffset + 2 * MemoryLayout<Integer64>.size)
            count += 1
            cell = cell?.nextCell
            }
        return(fields)
        }
        
    private var buffer: UnsafeMutableRawPointer
    public private(set) var firstCell: FreeBlockListCell
    private var endCell: FreeBlockListCell
    
    init(buffer: RawPointer,atByteOffset: Int,sizeInBytes: Int)
        {
        self.buffer = buffer
        self.firstCell = FreeBlockListCell(atByteOffset: atByteOffset,sizeInBytes: sizeInBytes)
        self.endCell = self.firstCell.endCell
        }
        
    init(buffer: RawPointer,atByteOffset: Int)
        {
        self.buffer = buffer
        self.firstCell = FreeBlockListCell(in: buffer,atByteOffset: Int(atByteOffset),lastCell: nil)
        self.endCell = self.firstCell.endCell
        }

    public func allocate(from buffer: UnsafeMutableRawPointer,sizeInBytes: Int) throws -> Integer64
        {
        // Try the endCell to see if it has space
        let actualSize = sizeInBytes + FreeBlockListCell.kCellHeaderSizeInBytes
        if self.endCell.sizeInBytes > actualSize
            {
            // It has space, grab actualSize bytes and add a new end cell to the list
            let lastOffset = self.endCell.byteOffset
            let nextOffset = self.endCell.byteOffset + actualSize
            let nextSize = self.endCell.sizeInBytes - actualSize
            self.endCell.sizeInBytes = actualSize
            self.endCell.isAllocated = true
            let newEndCell = FreeBlockListCell(atByteOffset: nextOffset,sizeInBytes: nextSize)
            self.endCell.nextCell = newEndCell
            newEndCell.lastCell = self.endCell
            let oldEndCell = self.endCell
            self.endCell = newEndCell
            oldEndCell.writeAll(to: buffer)
            return(lastOffset + FreeBlockListCell.kCellHeaderSizeInBytes)
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
        return(bestCell.byteOffset + FreeBlockListCell.kCellHeaderSizeInBytes)
        }
        
    public func deallocate(from buffer: UnsafeMutableRawPointer,atByteOffset: Integer64) throws -> Integer64
        {
        var cell: FreeBlockListCell? = self.firstCell
        while cell.isNotNil
            {
            if atByteOffset - FreeBlockListCell.kCellHeaderSizeInBytes == cell!.byteOffset
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
        let cell: FreeBlockListCell? = self.firstCell
        while cell.isNotNil && cell!.nextCell.isNotNil
            {
            if !cell!.isAllocated && !cell!.nextCell!.isAllocated
                {
                cell!.sizeInBytes += cell!.nextCell!.sizeInBytes
                cell!.nextCell = cell!.nextCell!.nextCell
                cell!.nextCell!.lastCell = cell
                // calculate offset from which to zero out the new empty space
                let offsetBuffer = buffer + cell!.byteOffset + FreeBlockListCell.kCellHeaderSizeInBytes
                // calculate the number of bytes to zero
//                let size = cell!.sizeInBytes - FreeListBlockCell.kCellHeaderSizeInBytes
                // zero the coalesced memory
                offsetBuffer.initializeMemory(as: Byte.self,repeating: 0,count: cell!.sizeInBytes)
                }
            }
        self.firstCell.writeAll(to: buffer)
        }
    }
