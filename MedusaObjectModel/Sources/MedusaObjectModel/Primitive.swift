//
//  File 2.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import MedusaCore
import MedusaStorage

public enum Primitive: Instance
    {
    case nothing
    case integer64(Integer64)
    case unsigned64(Unsigned64)
    case float64(Float64)
    case atom(Atom)
    case boolean(Boolean)
    case byte(Byte)
    case unicodeScalar(UnicodeScalar)
        
    public var objectAddress: ObjectAddress
        {
        ObjectAddress(self)
        }
        
    public var `class`: Class
        {
        switch(self)
            {
            case .nothing:
                return(.nothingClass)
            case .integer64:
                return(.integer64Class)
            case .unsigned64:
                return(.unsigned64Class)
            case .float64:
                return(.float64Class)
            case .atom:
                return(.atomClass)
            case .boolean:
                return(.booleanClass)
            case .byte:
                return(.byteClass)
            case .unicodeScalar:
                return(.unicodeScalarClass)
            }
        }
            
    public var sizeInBytes: Integer64
        {
        switch(self)
            {
            case .nothing:
                return(MemoryLayout<Integer64>.size)
            case .integer64:
                return(MemoryLayout<Integer64>.size)
            case .unsigned64:
                return(MemoryLayout<Integer64>.size)
            case .float64:
                return(MemoryLayout<Integer64>.size)
            case .atom:
                return(MemoryLayout<Integer64>.size)
            case .boolean:
                return(MemoryLayout<Boolean>.size)
            case .byte:
                return(MemoryLayout<Byte>.size)
            case .unicodeScalar:
                return(MemoryLayout<UnicodeScalar>.size)
            }
        }
    
    public var isIndexed: Bool
        {
        false
        }
    }
