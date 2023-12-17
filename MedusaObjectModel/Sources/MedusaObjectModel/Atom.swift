//
//  File 2.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import MedusaCore
import MedusaStorage

open class Atom: Instance
{
    public var _class: Any = 0
    
    public var objectAddress: MedusaCore.ObjectAddress = .kNothing
    
    public var objectHash: MedusaCore.Integer64 = 0
    
    public var hasBytes: MedusaCore.Boolean = false
    
    public func write(into page: Any, atIndex: MedusaCore.Integer64) throws {
        fatalError()
    }
    
    public func writeKey(into pointer: MedusaCore.RawPointer, atByteOffset: inout MedusaCore.Integer64) throws {
        fatalError()
    }
    
    public func writeValue(into pointer: MedusaCore.RawPointer, atByteOffset: inout MedusaCore.Integer64) throws {
        fatalError()
    }
    
    public func pack(into buffer: MedusaCore.RawPointer, atByteOffset: inout MedusaCore.Integer64) throws {
        fatalError()
    }
    
    public private(set) var rawValue: Integer64 = 0
    private var bitPattern: Unsigned64 = 0
    
    public var isNothing: MedusaCore.Boolean
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
    
    public var sizeInBytes: MedusaCore.Integer64
        {
        MemoryLayout<Integer64>.size
        }
    
    public var isIndexed: MedusaCore.Boolean
        {
        false
        }
    
    public func write(into: MedusaCore.RawPointer, atByteOffset: MedusaCore.Integer64) {
        fatalError()
    }
    
    public func write(into: MedusaCore.RawPointer, atByteOffset: inout MedusaCore.Integer64) {
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
    
    public static func <(lhs: Atom,rhs: Atom) -> Bool
        {
        fatalError()
        }
        
    public static func ==(lhs: Atom,rhs: Atom) -> Bool
        {
        fatalError()
        }
        
    init(_ string: String)
        {
        fatalError()
        }
        
    init(_ string: MOMString)
        {
        fatalError()
        }
        
    public required init(from: RawPointer,atByteOffset:inout Integer64)
        {
        fatalError()
        }
        
    public init(rawValue: Integer64)
        {
        self.rawValue = rawValue
        }
        
    public func hash(into: inout Hasher)
        {
        }
        
    public init(bitPattern: Unsigned64)
        {
        self.bitPattern = bitPattern
        }
    }
