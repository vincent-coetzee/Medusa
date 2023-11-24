//
//  FreeList.swift
//  Medusa
//
//  Created by Vincent Coetzee on 23/11/2023.
//

import Foundation

public class FreeListCell: Equatable
    {
    private var deltaSize: Int = 0
    public var byteOffset: Int
    public var sizeInBytes: Int
    internal var lastCell: FreeListCell?
    internal var nextCell: FreeListCell?
     
    public var count: Medusa.Integer
        {
        1 + (self.nextCell?.count ?? 0)
        }
        
    public var cellSizeInBytes: Int
        {
        Int(MemoryLayout<Int>.size * 2)
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
        
    public init(in page: PageBuffer,atByteOffset: Int,lastCell: FreeListCell?)
        {
        var offset = atByteOffset
        let nextCellOffset = page.load(fromByteOffset: &offset, as: Int.self)
        let size = page.load(fromByteOffset: &offset, as: Int.self)
        self.sizeInBytes = size
        self.byteOffset = Int(atByteOffset)
        if nextCellOffset != 0
            {
            self.nextCell = FreeListCell(in: page,atByteOffset: Int(nextCellOffset),lastCell: self)
            }
        self.lastCell = lastCell
        }
        
    public func write(to pageBuffer: PageBuffer)
        {
        var offset = Int(self.byteOffset)
        pageBuffer.storeBytes(of: self.nextCell?.byteOffset ?? 0, atByteOffset: &offset, as: Int.self)
        pageBuffer.storeBytes(of: Int(self.sizeInBytes), atByteOffset: &offset, as: Int.self)
        self.nextCell?.write(to: pageBuffer)
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
        return(cells.sorted{$0.deltaSize < $1.deltaSize})
        }
    }

public class FreeList
    {
    public var count: Medusa.Integer
        {
        self.firstCell.isNil ? 0 : self.firstCell!.count
        }
        
    public var freeListFields: FieldSet
        {
        let fields = FieldSet()
        var cell = self.firstCell
        var index = 0
        var count = 0
        while cell.isNotNil
            {
            fields.append(Field(index: index,name: "Free cell \(count)",value: .freeCell(cell!.byteOffset,cell!.nextCell?.byteOffset ?? 0,cell!.sizeInBytes)))
            count += 1
            index += 1
            cell = cell?.nextCell
            }
        return(fields)
        }
        
    private var pageBuffer: PageBuffer
    public private(set) var firstCell: FreeListCell?
    
    init(pageBuffer: PageBuffer,atByteOffset: Int,sizeInBytes: Int)
        {
        self.pageBuffer = pageBuffer
        self.firstCell = FreeListCell(atByteOffset: atByteOffset,sizeInBytes: sizeInBytes)
        }
        
    init(pageBuffer: PageBuffer,atByteOffset: Int)
        {
        self.pageBuffer = pageBuffer
        self.firstCell = FreeListCell(in: pageBuffer,atByteOffset: Int(atByteOffset),lastCell: nil)
        }
        
    public func allocate(sizeInBytes size: Int) throws -> Int
        {
        guard let someCell = self.firstCell else
            {
            throw(SystemIssue(code: .insufficientFreeSpace,message: "Insufficient free space in free space list.",agentKind: .pageServer,agentLocation: .unknown))
            }
        let cells = someCell.cellsWithSufficientSpace(sizeInBytes: size)
        guard !cells.isEmpty else
            {
            throw(SystemIssue(code: .insufficientFreeSpace,agentKind: .pageServer))
            }
        let bestCell = cells.first!
        let newCellSize = bestCell.sizeInBytes - size
        //
        // If it's the first cell and there's not enough EXTRA space in the cell
        // to store a cell reference, so eliminate the cell completely
        //
        if bestCell == self.firstCell && bestCell.sizeInBytes - size < bestCell.cellSizeInBytes
            {
            bestCell.nextCell?.lastCell = nil
            self.firstCell = bestCell.nextCell
            self.firstCell?.write(to: self.pageBuffer)
            return(bestCell.byteOffset)
            }
        //
        // If it's the first cell AND there is sufficient space for a cell
        //
        else if bestCell == self.firstCell
            {
            let oldOffset = bestCell.byteOffset
            bestCell.sizeInBytes = newCellSize
            bestCell.byteOffset = bestCell.byteOffset + size
            self.firstCell?.write(to: self.pageBuffer)
            return(oldOffset)
            }
        //
        // It's not the first cell, but it does not have enough space to store a cell,
        // so eliminate it completely
        //
        else if bestCell.sizeInBytes - size < bestCell.cellSizeInBytes
            {
            let oldOffset = bestCell.byteOffset
            bestCell.lastCell?.nextCell = bestCell.nextCell
            bestCell.nextCell?.lastCell = bestCell.lastCell
            self.firstCell?.write(to: self.pageBuffer)
            return(oldOffset)
            }
        //
        // So it's not the first cell but it DOES have enough space to store a cell
        // so adjust its values accordingly
        //
        else
            {
            let oldOffset = bestCell.byteOffset
            bestCell.sizeInBytes = newCellSize
            bestCell.byteOffset = bestCell.byteOffset + size
            self.firstCell?.write(to: self.pageBuffer)
            return(oldOffset)
            }
        }
        
    public func write(to page: PageBuffer)
        {
        self.firstCell?.write(to: page)
        }
    }
