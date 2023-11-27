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
    public static let kCellSizeInBytes = MemoryLayout<Int>.size
    
    public var count: Medusa.Integer64
        {
        self.firstCell?.count ?? 0
        }
        
    public var freeListFields: FieldSet
        {
        let fields = FieldSet(name: "Free Cell Fields")
        var cell = self.firstCell
        var count = 0
        while cell.isNotNil
            {
            assert(cell!.byteOffset != 0,"ByteOffset should not be 0 but is.")
            fields.append(Field(index: count,name: "Free \(count) Next",value: .integer(cell!.nextCell?.byteOffset ?? 0),offset: cell!.byteOffset))
            fields.append(Field(index: count,name: "Free \(count) Size",value: .integer(cell!.sizeInBytes),offset: cell!.byteOffset + MemoryLayout<Medusa.Integer64>.size))
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
        
    public func allocate(sizeInBytes: Int) throws -> Int
        {
        guard let someCell = self.firstCell else
            {
            throw(SystemIssue(code: .insufficientFreeSpace,message: "Insufficient free space in free space list.",agentKind: .pageServer,agentLocation: .unknown))
            }
        let cells = someCell.cellsWithSufficientSpace(sizeInBytes: sizeInBytes).sorted{$0.deltaSize < $1.deltaSize}
        guard !cells.isEmpty else
            {
            throw(SystemIssue(code: .insufficientFreeSpace,agentKind: .pageServer))
            }
        let bestCell = cells.first!
        let newCellSize = bestCell.sizeInBytes - sizeInBytes
        assert(newCellSize>0,"newCellSize SHOULD BE > 0 BUT IS NOT.")
        //
        // If it's the first cell and there's not enough EXTRA space in the cell
        // to store a cell reference, so eliminate the cell completely
        //
        if bestCell == self.firstCell && newCellSize < FreeList.kCellSizeInBytes
            {
            print("BEST CELL IS FIRST CELL AND CELL SPACE IS TOO SMALL FOR CELL, ELMINATE CELL")
            bestCell.nextCell?.lastCell = nil
            self.firstCell = bestCell.nextCell
            bestCell.lastCell = nil
            return(bestCell.byteOffset)
            }
        //
        // If it's the first cell AND there is sufficient space for a cell
        //
        else if bestCell == self.firstCell
            {
            print("BEST CELL IS FIRST CELL AND CELL SPACE HAS SPACE FOR CELL, CHANGE OLD CELL TO REFER TO NEW CELL")
            assert(bestCell.sizeInBytes > sizeInBytes + FreeList.kCellSizeInBytes,"bestCell.sizeInBytes !> sizeInBytes + FreeList.kCellSize IN BYTES AND SHOULD BE.")
            let oldOffset = bestCell.byteOffset
            print("     BEST CELL IS AT \(oldOffset)")
            print("     CHANGING BEST CELL SIZE FROM \(bestCell.sizeInBytes) TO \(newCellSize)")
            bestCell.sizeInBytes = newCellSize
            print("     CHANGING BEST CELL BYTE OFFSET FROM \(oldOffset) TO \(oldOffset + sizeInBytes)")
            bestCell.byteOffset = oldOffset + sizeInBytes
            bestCell.lastCell = nil
            return(oldOffset)
            }
        //
        // It's not the first cell, but it does not have enough space to store a cell,
        // so eliminate it completely
        //
        else if bestCell.sizeInBytes - sizeInBytes < bestCell.cellSizeInBytes
            {
            print("BEST CELL IS NOT FIRST CELL AND CELL SPACE IS TOO SMALL FOR CELL, ELMINATE CELL")
            let oldOffset = bestCell.byteOffset
            bestCell.lastCell?.nextCell = bestCell.nextCell
            bestCell.nextCell?.lastCell = bestCell.lastCell
            return(oldOffset)
            }
        //
        // So it's not the first cell but it DOES have enough space to store a cell
        // so adjust its values accordingly
        //
        else
            {
            print("BEST CELL IS NOT FIRST CELL AND CELL SPACE HAS SPACE FOR CELL, CHANGE CELL TO REFER TO NEW CELL")
            let oldOffset = bestCell.byteOffset
            print("     BEST CELL IS CELL AT \(bestCell.byteOffset)")
            print("     CHANGING BEST CELL SIZE FROM \(bestCell.sizeInBytes) TO \(newCellSize)")
            bestCell.sizeInBytes = newCellSize
            print("     CHANGING BEST CELL BYTE OFFSET FROM \(bestCell.byteOffset) TO \(bestCell.byteOffset + sizeInBytes)")
            bestCell.byteOffset = bestCell.byteOffset + sizeInBytes
            return(oldOffset)
            }
        }
        
    public func write(to buffer: UnsafeMutableRawPointer)
        {
        print("WRITING FREE LIST FOR BUFFER \(buffer)")
        self.firstCell?.write(to: buffer,number: 0)
        }
    }
