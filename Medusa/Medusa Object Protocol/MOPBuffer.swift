//
//  MOPContainer.swift
//  Medusa
//
//  Created by Vincent Coetzee on 17/11/2023.
//

import Foundation

public protocol MOPBuffer
    {
    var offset: Int { get set }
    
    func readInteger64(fromByteOffset: Int) -> Medusa.Integer64
    func readFloat(fromByteOffset: Int) -> Medusa.Float
    func readByte(fromByteOffset: Int) -> Medusa.Byte
    func readString(fromByteOffset: Int) -> Medusa.String
    func readBoolean(atOfffromByteOffsetset: Int) -> Medusa.Boolean
    func readAtom(fromByteOffset: Int) -> Medusa.Atom
    func readEnumeration(fromByteOffset: Int) -> Medusa.Enumeration
    func readObject(atOfffromByteOffsetset: Int) -> MOPObject
    
    func write(_ integer: Medusa.Integer64,atByteOffset: Int)
    func write(_ float: Medusa.Float,atByteOffset: Int)
    func write(_ byte: Medusa.Byte,atByteOffset: Int)
    func write(_ string: Medusa.String,atByteOffset: Int)
    func write(_ boolean: Medusa.Boolean,atByteOffset: Int)
    func write(_ boolean: Medusa.Atom,atByteOffset: Int)
    func write(_ object: MOPObject,atByteOffset: Int)
    func write(_ enumeration: Medusa.Enumeration,atByteOffset: Int)
    }
