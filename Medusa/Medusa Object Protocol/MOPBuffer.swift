//
//  MOPContainer.swift
//  Medusa
//
//  Created by Vincent Coetzee on 17/11/2023.
//

import Foundation

public class MOPBuffer
    {
    public let sizeInBytes: Int
    public let pointer: UnsafeMutableRawPointer
    private var byteCounter = 0
    
    init(sizeInBytes: Int)
        {
        self.sizeInBytes = sizeInBytes
        self.pointer = Medusa.RawBuffer.allocate(byteCount: self.sizeInBytes, alignment: 1)
        }
    
    public func nextPut(_ integer: Medusa.Integer64,atByteOffset: inout Int)
        {
        self.pointer.storeBytes(of: integer, toByteOffset: atByteOffset, as: Medusa.Integer64.self)
        atByteOffset += MemoryLayout<Medusa.Integer64>.size
        self.byteCounter += MemoryLayout<Medusa.Integer64>.size
        }
        
    public func nextPut(_ string: Medusa.String,atByteOffset: inout Int)
        {
        self.pointer.storeBytes(of: string.unicodeScalars.count, toByteOffset: atByteOffset, as: Medusa.Integer64.self)
        atByteOffset += MemoryLayout<Medusa.Integer64>.size
        for scalar in string.unicodeScalars
            {
            self.pointer.storeBytes(of: scalar,toByteOffset: atByteOffset,as: Unicode.Scalar.self)
            atByteOffset += MemoryLayout<Unicode.Scalar>.size
            self.byteCounter += MemoryLayout<Unicode.Scalar>.size
            }
        }
        
    public func nextPut(_ byte: Medusa.Byte,atByteOffset:inout Int)
        {
        self.pointer.storeBytes(of: byte, toByteOffset: atByteOffset, as: Medusa.Byte.self)
        atByteOffset += MemoryLayout<Medusa.Byte>.size
        self.byteCounter += MemoryLayout<Medusa.Byte>.size
        }
        
    public func nextPut(_ boolean: Medusa.Boolean,atByteOffset:inout Int)
        {
        self.pointer.storeBytes(of: boolean, toByteOffset: atByteOffset, as: Medusa.Boolean.self)
        atByteOffset += MemoryLayout<Medusa.Boolean>.size
        self.byteCounter += MemoryLayout<Medusa.Boolean>.size
        }
        
    public func nextPut(_ float: Medusa.Float,atByteOffset:inout Int)
        {
        self.pointer.storeBytes(of: float, toByteOffset: atByteOffset, as: Medusa.Float.self)
        atByteOffset += MemoryLayout<Medusa.Float>.size
        self.byteCounter += MemoryLayout<Medusa.Float>.size
        }
        
    public func nextPut(_ identifier: Identifier,atByteOffset:inout Int)
        {
        var offset = atByteOffset
        self.nextPut(identifier.count,atByteOffset: &offset)
        for string in identifier
            {
            self.nextPut(string,atByteOffset: &offset)
            }
        }
        
    public func nextPut<R:RawRepresentable>(_ raw: R,atByteOffset: inout Int) where R.RawValue == Int
        {
        self.nextPut(raw.rawValue,atByteOffset: &atByteOffset)
        }
        
    public func nextPut(_ object: MOPObject,atByteOffset: inout Int)
        {
        self.nextPut(Medusa.endian,atByteOffset: &atByteOffset)
        self.nextPut(0,atByteOffset: &atByteOffset)
        self.resetByteCounter()
        let klass = object.klass!
        self.nextPut(klass.identifier,atByteOffset: &atByteOffset)

        }
        
    private func resetByteCounter()
        {
        self.byteCounter = 0
        }
        
    public func nextPut(_ enumeration: MOPEnumeration,atByteOffset:inout Int)
        {
        self.nextPut(enumeration.enumerationKind!.identifier,atByteOffset: &atByteOffset)
        self.nextPut(enumeration.caseIndex,atByteOffset: &atByteOffset)
        }
    }
