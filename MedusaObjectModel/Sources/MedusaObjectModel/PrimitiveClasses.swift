//
//  File 2.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import MedusaCore
import MedusaStorage

public class PrimitiveClass: Class
    {
    public override var isObjectClass: Bool
        {
        false
        }
        
    public func instanceValue(from pointer: RawPointer) -> any Instance
        {
        fatalError()
        }
        
    public required init(named: String,superclass: Class)
        {
        super.init(inMemoryNamed: named, superclass: superclass)
        }
    
    public required init(inMemoryNamed name: String, superclass: Class?, hasBytes: Boolean = false) {
        fatalError("init(inMemoryNamed:superclass:hasBytes:) has not been implemented")
    }
}

public class Integer64Class: PrimitiveClass
    {
    public override func instanceValue(from pointer: RawPointer) -> any Instance
        {
        Primitive.integer64(pointer.load(as: Integer64.self))
        }
    }

public class Float64Class: PrimitiveClass
    {
    public override func instanceValue(from pointer: RawPointer) -> any Instance
        {
        Primitive.float64(pointer.load(as: Float64.self))
        }
    }

public class Unsigned64Class: PrimitiveClass
    {
    public override func instanceValue(from pointer: RawPointer) -> any Instance
        {
        Primitive.unsigned64(pointer.load(as: Unsigned64.self))
        }
    }
    
public class BooleanClass: PrimitiveClass
    {
    public override func instanceValue(from pointer: RawPointer) -> any Instance
        {
        Primitive.boolean(pointer.load(as: Unsigned64.self) == 1)
        }
    }

public class ByteClass: PrimitiveClass
    {
    public override func instanceValue(from pointer: RawPointer) -> any Instance
        {
        Primitive.byte(Byte(pointer.load(as: Unsigned64.self)))
        }
    }
    
public class AtomClass: PrimitiveClass
    {
    public override func instanceValue(from pointer: RawPointer) -> any Instance
        {
        Atom(bitPattern: pointer.load(as: Unsigned64.self))
        }
    }
