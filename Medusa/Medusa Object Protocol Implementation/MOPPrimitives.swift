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
    
public class MOPInteger64: MOPPrimitive
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
    
public class MOPInteger32: MOPPrimitive
    {
    public init()
        {
        super.init(module: .argonModule,name: "Integer32")
        }
        
    public class func encode(_ value: Integer64,into page: Page,toByteOffset: inout Integer64)
        {
        page.buffer.storeBytes(of: value, toByteOffset: toByteOffset, as: Integer64.self)
        toByteOffset += MemoryLayout<Integer32>.size
        }
        
    public override var sizeInBytes: Integer64
        {
        MemoryLayout<Integer32>.size
        }
    }
    
public class MOPInteger16: MOPPrimitive
    {
    public init()
        {
        super.init(module: .argonModule,name: "Integer16")
        }
        
    public class func encode(_ value: Integer32,into page: Page,toByteOffset: inout Integer64)
        {
        page.buffer.storeBytes(of: value, toByteOffset: toByteOffset, as: Integer32.self)
        toByteOffset += MemoryLayout<Integer16>.size
        }
        
    public override var sizeInBytes: Integer64
        {
        MemoryLayout<Integer16>.size
        }
    }
    
public class MOPUnsigned64: MOPPrimitive
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
        MemoryLayout<Unsigned64>.size
        }
    }
    
public class MOPUnsigned32: MOPPrimitive
    {
    public init()
        {
        super.init(module: .argonModule,name: "Unsigned32")
        }
        
    public class func encode(_ value: Unsigned32,into page: Page,toByteOffset: inout Integer64)
        {
        page.buffer.storeBytes(of: value, toByteOffset: toByteOffset, as: Unsigned32.self)
        toByteOffset += MemoryLayout<Unsigned32>.size
        }
        
    public override var sizeInBytes: Integer64
        {
        MemoryLayout<Unsigned32>.size
        }
    }
    
public class MOPUnsigned16: MOPPrimitive
    {
    public init()
        {
        super.init(module: .argonModule,name: "Unsigned16")
        }
        
    public class func encode(_ value: Unsigned16,into page: Page,toByteOffset: inout Integer64)
        {
        page.buffer.storeBytes(of: value, toByteOffset: toByteOffset, as: Unsigned16.self)
        toByteOffset += MemoryLayout<Unsigned16>.size
        }
        
    public override var sizeInBytes: Integer64
        {
        MemoryLayout<Unsigned16>.size
        }
    }

public class MOPFloat64: MOPPrimitive
    {
    public init()
        {
        super.init(module: .argonModule,name: "Float64")
        }
        
    public class func encode(_ value: Float64,into page: Page,toByteOffset: inout Integer64)
        {
        page.buffer.storeBytes(of: value, toByteOffset: toByteOffset, as: Float64.self)
        toByteOffset += MemoryLayout<Float64>.size
        }
        
    public override var sizeInBytes: Integer64
        {
        MemoryLayout<Float64>.size
        }
    }
    
public class MOPFloat32: MOPPrimitive
    {
    public init()
        {
        super.init(module: .argonModule,name: "Float32")
        }
        
    public class func encode(_ value: Float32,into page: Page,toByteOffset: inout Integer64)
        {
        page.buffer.storeBytes(of: value, toByteOffset: toByteOffset, as: Float32.self)
        toByteOffset += MemoryLayout<Float32>.size
        }
        
    public override var sizeInBytes: Integer64
        {
        MemoryLayout<Float32>.size
        }
    }
    
public class MOPFloat16: MOPPrimitive
    {
    public init()
        {
        super.init(module: .argonModule,name: "Float16")
        }
        
    public class func encode(_ value: Float16,into page: Page,toByteOffset: inout Integer64)
        {
        page.buffer.storeBytes(of: value, toByteOffset: toByteOffset, as: Float16.self)
        toByteOffset += MemoryLayout<Float16>.size
        }
        
    public override var sizeInBytes: Integer64
        {
        MemoryLayout<Float16>.size
        }
    }
    
public class MOPBoolean: MOPPrimitive
    {
    public init()
        {
        super.init(module: .argonModule,name: "Boolean")
        }
        
    public class func encode(_ value: Boolean,into page: Page,toByteOffset: inout Integer64)
        {
        page.buffer.storeBytes(of: value, toByteOffset: toByteOffset, as: Boolean.self)
        toByteOffset += MemoryLayout<Boolean>.size
        }
        
    public override var sizeInBytes: Integer64
        {
        MemoryLayout<Boolean>.size
        }
    }

public class MOPByte: MOPPrimitive
    {
    public init()
        {
        super.init(module: .argonModule,name: "Byte")
        }
        
    public class func encode(_ value: Byte,into page: Page,toByteOffset: inout Integer64)
        {
        page.buffer.storeBytes(of: value, toByteOffset: toByteOffset, as: Byte.self)
        toByteOffset += MemoryLayout<Byte>.size
        }
        
    public override var sizeInBytes: Integer64
        {
        MemoryLayout<Byte>.size
        }
    }

public class MOPAtom: MOPPrimitive
    {
    public init()
        {
        super.init(module: .argonModule,name: "Atom")
        }
        
    public class func encode(_ value: Atom,into page: Page,toByteOffset: inout Integer64)
        {
        page.buffer.storeBytes(of: value, toByteOffset: toByteOffset, as: Atom.self)
        toByteOffset += MemoryLayout<Atom>.size
        }
        
    public override var sizeInBytes: Integer64
        {
        MemoryLayout<Atom>.size
        }
    }

public class MOPNothing: MOPPrimitive
    {
    public init()
        {
        super.init(module: .argonModule,name: "Nothing")
        }
        
    public class func encode(into page: Page,toByteOffset: inout Integer64)
        {
        page.buffer.storeBytes(of: MOPObject.nothing, toByteOffset: toByteOffset, as: Integer64.self)
        toByteOffset += MemoryLayout<Byte>.size
        }
        
    public override var sizeInBytes: Integer64
        {
        MemoryLayout<Integer64>.size
        }
    }
