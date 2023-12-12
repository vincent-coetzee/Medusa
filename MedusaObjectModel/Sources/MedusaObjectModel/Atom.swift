//
//  File 2.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import Path
import MedusaCore
import MedusaStorage

open class Atom: Instance
{
    public var description: String
        {
                fatalError()
                }
    
    public var objectAddress: MedusaCore.ObjectAddress
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
    
    public var _class: Any
        {
        fatalError()
        }
    
    public var isIndexed: MedusaCore.Boolean
        {
        fatalError()
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
        
    public func hash(into: inout Hasher)
        {
        }
    }
