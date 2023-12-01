//
//  MOPString.swift
//  Medusa
//
//  Created by Vincent Coetzee on 01/12/2023.
//

import Foundation

public class MOPStringPrimitive: MOPPrimitive
    {
    public init()
        {
        super.init(module: MOPClass.argonModule,name: "String")
        }
        
    public class func encode(_ value: String,into buffer: RawBuffer,toByteOffset: inout Integer64)
        {
        buffer.storeBytes(of: value.count,toByteOffset: toByteOffset,as: Integer64.self)
        toByteOffset += MemoryLayout<Integer64>.size
        for scalar in value.unicodeScalars
            {
            buffer.storeBytes(of: scalar,toByteOffset: toByteOffset,as: UnicodeScalar.self)
            toByteOffset += MemoryLayout<UnicodeScalar>.size
            }
        }
        
    public override var sizeInBytes: Integer64
        {
        get
            {
            MemoryLayout<Medusa.Byte>.size
            }
        set
            {
            }
        }
    }
