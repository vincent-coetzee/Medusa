//
//  File 2.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import MedusaCore

open class Slot
    {
    public var isObjectSlot: Bool
        {
        self.class.isObjectClass
        }
        
    public var name: String
    public let key: Atom
    public let `class`: Class
    public var byteOffset: Integer64
    public var isStaticSlot: Boolean
    
    init(name: String,class: Class,atByteOffset: Integer64,isStaticSlot: Boolean = false)
        {
        self.name = name
        self.key = Atom(name)
        self.class = `class`
        self.byteOffset = atByteOffset
        self.isStaticSlot = isStaticSlot
        }
        
    public func copy() -> Self
        {
        Slot(name: self.name,class: self.class,atByteOffset: self.byteOffset,isStaticSlot: self.isStaticSlot) as! Self
        }
        
    public func value(in pointer: RawPointer) -> any Instance
        {
        self.class.instanceValue(atPointer: pointer + self.byteOffset)
        }
        
    public func setValue(_ value: any Instance,in pointer: RawPointer)
        {
        self.class.setInstanceValue(value,atPointer: pointer)
        }
        
    public func writeValue(from: RawPointer,into pointer: RawPointer)
        {
        let value = from.load(fromByteOffset: self.byteOffset, as: Unsigned64.self)
        if self.isObjectSlot && ObjectAddress(bitPattern: value).isNothing
            {
            
            }
        }
    }

public typealias Slots = Array<Slot>
