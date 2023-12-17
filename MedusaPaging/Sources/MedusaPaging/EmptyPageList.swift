//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 11/12/2023.
//

import Foundation
import MedusaCore
import MedusaStorage

public class EmptyPageList
    {
    public class EmptyPageCell
        {
        public let pageOffset: Integer64
        public var nextCell: EmptyPageCell?
        public var previousCell: EmptyPageCell?
        
        public init(pageOffset: Integer64,nextCell: EmptyPageCell? = nil,previousCell: EmptyPageCell? = nil)
            {
            self.pageOffset = pageOffset
            self.nextCell = nextCell
            self.previousCell = previousCell
            }
            
        public func loadNextCell(fromFile: FileIdentifier) throws -> EmptyPageCell
            {
            let nextOffset = try fromFile.readInteger64(atOffset: self.pageOffset)
            guard nextOffset != 0 else
                {
                return(self)
                }
            self.nextCell = EmptyPageCell(pageOffset: nextOffset)
            self.nextCell?.previousCell = self
            return(try self.nextCell!.loadNextCell(fromFile: fromFile))
            }
            
        public func storeCell(inFile: FileIdentifier) throws
            {
            try inFile.write(self.nextCell?.pageOffset ?? 0,atOffset: self.pageOffset)
            try self.nextCell?.storeCell(inFile: inFile)
            }
        }
        
    public var isEmpty: Boolean
        {
        self.firstCell.isNotNil
        }
        
    public var firstPageOffset: Integer64
        {
        self.firstCell?.pageOffset ?? 0
        }
        
    private var firstCell: EmptyPageCell?
    private var lastCell: EmptyPageCell?
    
    public init()
        {
        }
        
    public func loadEmptyPageList(startingAt offset: Integer64,inFile file: FileIdentifier) throws
        {
        guard offset != 0 else
            {
            return
            }
        self.firstCell = EmptyPageCell(pageOffset: offset)
        self.lastCell = try self.firstCell!.loadNextCell(fromFile: file)
        }
        
    public func storeEmptyPageList(inFile: FileIdentifier) throws
        {
        try self.firstCell?.storeCell(inFile: inFile)
        }
        
    public func allocateEmptyPageOffset() -> Integer64?
        {
        guard self.firstCell.isNotNil else
            {
            return(nil)
            }
        let offset = self.firstCell!.pageOffset
        self.firstCell = self.firstCell!.nextCell
        self.firstCell?.previousCell = nil
        fatalError()
        }

    public func addEmptyPage(at offset: Integer64,inFile: FileIdentifier) throws
        {
        let newCell = EmptyPageCell(pageOffset: offset)
        newCell.previousCell = self.lastCell
        self.lastCell?.nextCell = newCell
        let cellToBeWritten = self.lastCell
        self.lastCell = newCell
        try cellToBeWritten?.storeCell(inFile: inFile)
        }
    }
