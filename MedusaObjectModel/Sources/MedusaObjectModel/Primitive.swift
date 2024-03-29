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
    public var objectAddress: MedusaCore.ObjectAddress
        {
        get
            {
            ObjectAddress(0)
            }
        set
            {
            }
        }
        
    public var objectHash: MedusaCore.Integer64
        {
        fatalError()
        }
    
    public var _class: Any
        {
        get
            {
            0
            }
        set
            {
            }
        }
    
    public var hasBytes: MedusaCore.Boolean
        {
        false
        }
    
    public var isNothing: MedusaCore.Boolean
        {
        false
        }
    
    public func write(into page: Any, atIndex: MedusaCore.Integer64) throws {
        
    }
    
    public func writeKey(into pointer: MedusaCore.RawPointer, atByteOffset: inout MedusaCore.Integer64) throws {
        
    }
    
    public func writeValue(into pointer: MedusaCore.RawPointer, atByteOffset: inout MedusaCore.Integer64) throws {
        
    }
    
    public func pack(into buffer: MedusaCore.RawPointer, atByteOffset: inout MedusaCore.Integer64) throws {
        
    }
    
    case nothing
    case integer64(Integer64)
    case unsigned64(Unsigned64)
    case float64(Float64)
    case atom(Atom)
    case boolean(Boolean)
    case byte(Byte)
    case unicodeScalar(UnicodeScalar)
        
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
        
    public var description: String
        {
                fatalError()
                }
    
    public var objectHandle: MedusaCore.ObjectHandle
        {
        fatalError()
        }

    
    public func write(into: MedusaCore.RawPointer, atByteOffset: MedusaCore.Integer64) {
        fatalError()
    }
    
    public func pack(into: MedusaCore.RawPointer, atByteOffset: MedusaCore.Integer64) {
        fatalError()
    }
    
    public func value(ofSlotAtKey: String) -> any Instance {
        fatalError()
    }
    
    public func setValue(_ value: any Instance, ofSlotAtKey: String) {
        fatalError()
    }
    
    public func isEqual(to: Any) -> Bool {
        fatalError()
    }
    
    public func isLess(than: Any) -> Bool {
        fatalError()
    }
    
    public static func <(lhs: Primitive,rhs: Primitive) -> Bool
        {
        fatalError()
        }
        
    public static func ==(lhs: Primitive,rhs: Primitive) -> Bool
        {
        fatalError()
        }
        
    public func hash(into: inout Hasher)
        {
        }
        
    public func write(into: MedusaCore.RawPointer, atByteOffset: inout MedusaCore.Integer64) {
        fatalError()
    }
    }
