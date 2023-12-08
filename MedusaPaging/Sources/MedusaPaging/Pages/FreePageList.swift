//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import MedusaCore

public class FreePageList
    {
    private var firstCell: RawPointer?
    private var lastCell: RawPointer?
    
    public var firstCellAddress: Integer64
        {
        Integer64(bitPattern: self.firstCell)
        }
        
    public var lastCellAddress: Integer64
        {
        Integer64(bitPattern: self.lastCell)
        }
        
    public init(firstPageAddress: Integer64,lastFreePageAddress: Integer64)
        {
        self.firstCell = RawPointer(bitPattern: firstPageAddress)
        self.lastCell = RawPointer(bitPattern: lastFreePageAddress)
        }
        
    public init()
        {
        }
        
    public func appendFreePage(at pointer: RawPointer)
        {
        pointer.storeBytes(of: 0, as: Integer64.self)
        if self.lastCell.isNil
            {
            self.lastCell = pointer
            }
        else
            {
            self.lastCell!.storeBytes(of: Integer64(bitPattern: pointer),as: Integer64.self)
            }
        }
        
    public func firstFreePage() -> RawPointer?
        {
        if self.firstCell.isNil
            {
            return(nil)
            }
        let pointer = self.firstCell
        self.firstCell = RawPointer(bitPattern: pointer!.load(as: Integer64.self))
        return(pointer)
        }
    }
