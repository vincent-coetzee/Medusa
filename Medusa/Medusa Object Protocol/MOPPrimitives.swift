//
//  MOPPrimitiveValue.swift
//  Medusa
//
//  Created by Vincent Coetzee on 17/11/2023.
//

import Foundation

public class MOPPrimitive: MOPClass
    {
    }
    
public class MOPInteger64Primitive: MOPPrimitive
    {
    public init()
        {
        super.init(module: .argonModule,name: "Integer64")
        }
        
    public class func encode(_ value: Integer64,into page: Page,toByteOffset: inout Integer64)
        {
        page.buffer.storeBytes(of: value, toByteOffset: toByteOffset, as: Integer64.self)
        toByteOffset += MemoryLayout<Integer64>.size
        }
        
    public override var sizeInBytes: Integer64
        {
        MemoryLayout<Integer64>.size
        }
    }
    
public class MOPUnsigned64Primitive: MOPPrimitive
    {
    public init()
        {
        super.init(module: .argonModule,name: "Unsigned64")
        }
        
    public class func encode(_ value: Unsigned64,into page: Page,toByteOffset: inout Integer64)
        {
        page.buffer.storeBytes(of: value, toByteOffset: toByteOffset, as: Unsigned64.self)
        toByteOffset += MemoryLayout<Unsigned64>.size
        }
        
    public override var sizeInBytes: Integer64
        {
        MemoryLayout<Integer64>.size
        }
    }

public class MOPFloat64Primitive: MOPPrimitive
    {
    public init()
        {
        super.init(module: .argonModule,name: "Float64")
        }
        
    public class func encode(_ value: Float64,into buffer: RawBuffer,toByteOffset: inout Integer64)
        {
        buffer.storeBytes(of: value, toByteOffset: toByteOffset, as: Float64.self)
        toByteOffset += MemoryLayout<Float64>.size
        }
        
    public override var sizeInBytes: Integer64
        {
        MemoryLayout<Float64>.size
        }
    }
    
public class MOPBooleanPrimitive: MOPPrimitive
    {
    public init()
        {
        super.init(module: .argonModule,name: "Boolean")
        }
        
    public class func encode(_ value: Boolean,into buffer: RawBuffer,toByteOffset: inout Integer64)
        {
        buffer.storeBytes(of: value, toByteOffset: toByteOffset, as: Boolean.self)
        toByteOffset += MemoryLayout<Boolean>.size
        }
        
    public override var sizeInBytes: Integer64
        {
        MemoryLayout<Boolean>.size
        }
    }

public class MOPBytePrimitive: MOPPrimitive
    {
    public init()
        {
        super.init(module: .argonModule,name: "Byte")
        }
        
    public class func encode(_ value: Byte,into buffer: RawBuffer,toByteOffset: inout Integer64)
        {
        buffer.storeBytes(of: value, toByteOffset: toByteOffset, as: Byte.self)
        toByteOffset += MemoryLayout<Byte>.size
        }
        
    public override var sizeInBytes: Integer64
        {
        MemoryLayout<Byte>.size
        }
    }


