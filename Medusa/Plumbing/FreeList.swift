//
//  FreeList.swift
//  Medusa
//
//  Created by Vincent Coetzee on 23/11/2023.
//

import Foundation
import Fletcher

public class FreeListCell: Equatable
    {
    public var deltaSize: Int = 0
    public var byteOffset: Int
    public var sizeInBytes: Int
    internal var lastCell: FreeListCell?
    internal var nextCell: FreeListCell?
     
    public var count: Medusa.Integer64
        {
        1 + (self.nextCell?.count ?? 0)
        }
        
    public var cellSizeInBytes: Int
        {
        Int(MemoryLayout<Medusa.Integer64>.size * 2)
        }
        
    public static func ==(lhs: FreeListCell,rhs: FreeListCell) -> Bool
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
        
    public init(in page: UnsafeMutableRawPointer,atByteOffset: Int,lastCell: FreeListCell?)
        {
        var offset = atByteOffset
        let nextCellOffset = readIntegerWithOffset(page,&offset)
        self.sizeInBytes = readIntegerWithOffset(page,&offset)
        self.byteOffset = atByteOffset
        if nextCellOffset != 0
            {
            self.nextCell = FreeListCell(in: page,atByteOffset: nextCellOffset,lastCell: self)
            }
        self.lastCell = lastCell
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
        self.nextCell?.write(to: pageBuffer,number: number + 1)
        }
        
    public func cellsWithSufficientSpace(sizeInBytes: Int) -> Array<FreeListCell>
        {
        var cells = Array<FreeListCell>()
        if self.sizeInBytes > sizeInBytes
            {
            self.deltaSize = self.sizeInBytes - sizeInBytes
            cells.append(self)
            }
        if self.nextCell.isNotNil
            {
            cells.append(contentsOf: self.nextCell!.cellsWithSufficientSpace(sizeInBytes: sizeInBytes))
            }
        return(cells)
        }
    }

public class FreeList
    {
    public struct CellReference
        {
        public let byteoffset: Medusa.Integer64
        public let sizeInBytes: Medusa.Integer64
        }
        
    public static let kCellSizeInBytes = 2 * MemoryLayout<Int>.size
    public static let kSmallestFreeSpaceSizeInBytes = 10 * MemoryLayout<Int>.size * 2
    
    public var count: Medusa.Integer64
        {
        self.firstCell?.count ?? 0
        }
        
    public var fields: CompositeField
        {
        let fields = CompositeField(name: "Free Cell Fields")
        var cell = self.firstCell
        var count = 0
        while cell.isNotNil
            {
            assert(cell!.byteOffset != 0,"ByteOffset should not be 0 but is.")
            fields.append(Field(name: "Free \(count) Next",value: .integer(cell!.nextCell?.byteOffset ?? 0),offset: cell!.byteOffset))
            fields.append(Field(name: "Free \(count) Size",value: .integer(cell!.sizeInBytes),offset: cell!.byteOffset + MemoryLayout<Medusa.Integer64>.size))
            count += 1
            cell = cell?.nextCell
            }
        return(fields)
        }
        
    private var buffer: UnsafeMutableRawPointer
    public private(set) var firstCell: FreeListCell?
    
    init(buffer: UnsafeMutableRawPointer,atByteOffset: Int,sizeInBytes: Int)
        {
        self.buffer = buffer
        self.firstCell = FreeListCell(atByteOffset: atByteOffset,sizeInBytes: sizeInBytes)
        }
        
    init(buffer: UnsafeMutableRawPointer,atByteOffset: Int)
        {
        self.buffer = buffer
        self.firstCell = FreeListCell(in: buffer,atByteOffset: Int(atByteOffset),lastCell: nil)
        }
        
    public func allocate(from buffer: UnsafeMutableRawPointer,sizeInBytes: Int) throws -> Medusa.Integer64
        {
        guard let someCell = self.firstCell else
            {
            throw(SystemIssue(code: .insufficientFreeSpace,agentKind: .pageServer,message: "Insufficient free space in free space list."))
            }
        let actualSize = sizeInBytes + MemoryLayout<Int>.size
        let cells = someCell.cellsWithSufficientSpace(sizeInBytes: actualSize).sorted{$0.deltaSize < $1.deltaSize}
        guard !cells.isEmpty else
            {
            throw(SystemIssue(code: .insufficientFreeSpace,agentKind: .pageServer))
            }
        let bestCell = cells.first!
        let oldCellSize = bestCell.sizeInBytes
        let newCellSize = bestCell.sizeInBytes - actualSize
        assert(newCellSize>0,"newCellSize SHOULD BE > 0 BUT IS NOT.")
        //
        // If it's the first cell and the cell is too small
        // then transfer free space to allocation
        //
        if bestCell == self.firstCell && newCellSize < FreeList.kSmallestFreeSpaceSizeInBytes
            {
            var oldOffset = bestCell.byteOffset
            bestCell.nextCell?.lastCell = nil
            self.firstCell = bestCell.nextCell
            bestCell.byteOffset = oldOffset + MemoryLayout<Medusa.Integer64>.size
            // Write the size of the allocation one word back from the start of the allocation
            writeIntegerWithOffset(buffer,oldCellSize,&oldOffset)
            return(bestCell.byteOffset)
            }
        //
        // If it's the first cell AND there is sufficient space for a cell
        //
        else if bestCell == self.firstCell
            {
            var oldOffset = bestCell.byteOffset
            bestCell.sizeInBytes = newCellSize
            bestCell.byteOffset += actualSize
            // Write the size of the allocation one word back from the start of the allocation
            writeIntegerWithOffset(buffer,actualSize,&oldOffset)
            return(oldOffset + MemoryLayout<Medusa.Integer64>.size)
            }
        //
        // It's not the first cell, and it does not have sufficient space for another cell
        // so attach the extra space to the allocation
        //
        else if bestCell.sizeInBytes - actualSize < FreeList.kSmallestFreeSpaceSizeInBytes
            {
            var oldOffset = bestCell.byteOffset
            bestCell.lastCell?.nextCell = bestCell.nextCell
            bestCell.nextCell?.lastCell = bestCell.lastCell
            // Write the size of the allocation one word back from the start of the allocation
            writeIntegerWithOffset(buffer,oldCellSize,&oldOffset)
            return(oldOffset + MemoryLayout<Medusa.Integer64>.size)
            }
        //
        // So it's not the first cell but it DOES have enough space to store a cell
        // so adjust its values accordingly
        //
        else
            {
            var oldOffset = bestCell.byteOffset
            bestCell.sizeInBytes = newCellSize
            bestCell.byteOffset = oldOffset + actualSize
            // Write the size of the allocation one word back from the start of the allocation
            writeIntegerWithOffset(buffer,actualSize,&oldOffset)
            return(oldOffset + MemoryLayout<Medusa.Integer64>.size)
            }
        }
        
    public func deallocate(from buffer: UnsafeMutableRawPointer,atByteOffset: Medusa.Integer64,sizeInBytes: Int)
        {
        let address = atByteOffset - MemoryLayout<Medusa.Integer64>.size
        let newCell = FreeListCell(atByteOffset: address, sizeInBytes: sizeInBytes)
        newCell.nextCell = self.firstCell
        self.firstCell?.nextCell = newCell
        newCell.write(to: buffer)
        }
        
    public func write(to buffer: UnsafeMutableRawPointer)
        {
        print("WRITING FREE LIST FOR BUFFER \(buffer)")
        self.firstCell?.write(to: buffer,number: 0)
        }
    }
