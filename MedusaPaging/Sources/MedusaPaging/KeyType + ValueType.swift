//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 10/12/2023.
//

import Foundation
import MedusaCore

public protocol KeyType
    {
    func makeKey(from: RawPointer,atByteOffset: Integer64) -> any Instance
    func write(into: RawPointer,atByteOffset: Integer64)
    func write(into: RawPointer,atByteOffset:inout Integer64)
    func pack(into: RawPointer,atByteOffset: Integer64)
    }
    
public protocol ValueType
    {
    func makeValue(from: RawPointer,atByteOffset: Integer64) -> any Instance
    func write(into: RawPointer,atByteOffset: Integer64)
    func write(into: RawPointer,atByteOffset:inout Integer64)
    func pack(into: RawPointer,atByteOffset: Integer64)
    }

public struct KeyValue
    {
    public let key: any Instance
    public let value: any Instance
    }
