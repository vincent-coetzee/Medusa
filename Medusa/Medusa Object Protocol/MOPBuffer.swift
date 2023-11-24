//
//  MOPContainer.swift
//  Medusa
//
//  Created by Vincent Coetzee on 17/11/2023.
//

import Foundation

public protocol MOPBuffer
    {
    var currentOffset: Int { get set }
    
    func readInteger(atOffset: Int) -> Medusa.Integer
    func readFloat(atOffset: Int) -> Medusa.Float
    func readByte(atOffset: Int) -> Medusa.Byte
    func readString(atOffset: Int) -> Medusa.String
    func readBoolean(atOffset: Int) -> Medusa.Boolean
    func readAtom(atOffset: Int) -> Medusa.Atom
    func readEnumeration(atOffset: Int) -> Medusa.Enumeration
    func readObject(atOffset: Int) -> MOPObject
    
    func write(_ integer: Medusa.Integer,atOffset: Int)
    func write(_ float: Medusa.Float,atOffset: Int)
    func write(_ byte: Medusa.Byte,atOffset: Int)
    func write(_ string: Medusa.String,atOffset: Int)
    func write(_ boolean: Medusa.Boolean,atOffset: Int)
    func write(_ boolean: Medusa.Atom,atOffset: Int)
    func write(_ object: MOPObject,atOffset: Int)
    func write(_ enumeration: Medusa.Enumeration,atOffset: Int)
    }
