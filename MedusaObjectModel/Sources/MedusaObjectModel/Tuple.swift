//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 13/12/2023.
//

import Foundation
import MedusaCore

public class Tuple: Instance
{
    public func value(ofSlotAtKey: String) -> any Instance {
        fatalError()
    }
    
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
    
    public var objectHash: MedusaCore.Integer64 = 0
    
    public var _class: Any = 0
        
    
    public var hasBytes: MedusaCore.Boolean = false
    
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
        
    public var isNothing: MedusaCore.Boolean
        {
        false
        }
        
    public required init(from buffer: RawPointer,atByteOffset:inout Integer64)
        {
        fatalError()
        }
        
    public func write(into buffer: RawPointer,atByteOffset: inout Integer64)
        {
        fatalError("Unimplemented")
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
        fatalError()
        }
    
    public var isIndexed: MedusaCore.Boolean
        {
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
    
    public static func <(lhs: Tuple,rhs: Tuple) -> Bool
        {
        fatalError()
        }
        
    public static func ==(lhs: Tuple,rhs: Tuple) -> Bool
        {
        fatalError()
        }
        
    public func hash(into: inout Hasher)
        {
        }
    }
