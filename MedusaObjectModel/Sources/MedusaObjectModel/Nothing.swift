//
//  File 3.swift
//  
//
//  Created by Vincent Coetzee on 10/12/2023.
//

import Foundation
import MedusaCore
import MedusaStorage
import MedusaPaging

public struct Nothing: Instance
{
    public var objectAddress: MedusaCore.ObjectAddress = ObjectAddress.kNothing
    
    public var objectHash: MedusaCore.Integer64 = 0
    
    public var _class: Any
    
    public var hasBytes: MedusaCore.Boolean = false
    
    public var isNothing: MedusaCore.Boolean = true
    
    public func write(into page: Any, atIndex: MedusaCore.Integer64) throws {
        
    }
    
    public func writeKey(into pointer: MedusaCore.RawPointer, atByteOffset: inout MedusaCore.Integer64) throws {
        
    }
    
    public func writeValue(into pointer: MedusaCore.RawPointer, atByteOffset: inout MedusaCore.Integer64) throws {
        
    }
    
    public func pack(into buffer: MedusaCore.RawPointer, atByteOffset: inout MedusaCore.Integer64) throws {
        
    }
    
    public var objectHandle: MedusaCore.ObjectHandle
        {
        fatalError()
        }
    
    public func write(into: MedusaCore.RawPointer, atByteOffset: inout MedusaCore.Integer64) {
        fatalError()
    }
    
    public static let kNothing = Self()
    public let sizeInBytes: Integer64 = MemoryLayout<Integer64>.size
    public let `class` = Class.nothingClass
    public let isIndexed = false
    
    public init()
        {
        fatalError()
        }
        
    public init(from: Page, atByteOffset: MedusaCore.Integer64)
        {
        fatalError()
        }
        
    public init(from: RawPointer, atByteOffset: MedusaCore.Integer64)
        {
        fatalError()
        }
    
    public static func == (lhs: Nothing, rhs: Nothing) -> Boolean
        {
        true
        }
        
    public static func < (lhs: Nothing, rhs: Nothing) -> Boolean
        {
        return(false)
        }
        
    public func write(into buffer: RawPointer,atByteOffset: Integer64)
        {
        buffer.storeBytes(of: ObjectAddress.kNothing.address, toByteOffset: atByteOffset, as: Unsigned64.self)
        }
        
    public func pack(into buffer: RawPointer,atByteOffset: Integer64)
        {
        buffer.storeBytes(of: ObjectAddress.kNothing.address, toByteOffset: atByteOffset, as: Unsigned64.self)
        }
        
    public func value(ofSlotAtKey: String) -> any Instance
        {
        fatalError("This should be called on an instance of Nothing.")
        }
        
    public func setValue(_ value: any Instance,ofSlotAtKey: String)
        {
        fatalError("This should be called on an instance of Nothing.")
        }
        
    public func hash(into hasher:inout Hasher)
        {
        hasher.combine(0)
        }
        
    public var description: String
        {
                fatalError()
                }
    
    public func isEqual(to: Any) -> Bool {
        fatalError()
    }
    
    public func isLess(than: Any) -> Bool {
        fatalError()
    }
        
    }
