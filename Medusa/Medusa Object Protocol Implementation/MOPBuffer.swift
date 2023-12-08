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
    
    public func nextPut(_ integer: Integer64,atByteOffset: inout Int)
        {
        self.pointer.storeBytes(of: integer, toByteOffset: atByteOffset, as: Integer64.self)
        atByteOffset += MemoryLayout<Integer64>.size
        self.byteCounter += MemoryLayout<Integer64>.size
        }
        
    public func nextPut(_ string: Medusa.String,atByteOffset: inout Int)
        {
        self.pointer.storeBytes(of: string.unicodeScalars.count, toByteOffset: atByteOffset, as: Integer64.self)
        atByteOffset += MemoryLayout<Integer64>.size
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
        
    public func nextPut(_ boolean: Boolean,atByteOffset:inout Int)
        {
        self.pointer.storeBytes(of: boolean, toByteOffset: atByteOffset, as: Boolean.self)
        atByteOffset += MemoryLayout<Boolean>.size
        self.byteCounter += MemoryLayout<Boolean>.size
        }
        
    public func nextPut(_ float: Float64,atByteOffset:inout Int)
        {
        self.pointer.storeBytes(of: float, toByteOffset: atByteOffset, as: Float64.self)
        atByteOffset += MemoryLayout<Float64>.size
        self.byteCounter += MemoryLayout<Float64>.size
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
        
    public func nextPut(_ enumeration: MOPEnumeration,caseIndex: Integer64,atByteOffset:inout Int)
        {
        self.nextPut(enumeration.identifier,atByteOffset: &atByteOffset)
        self.nextPut(caseIndex,atByteOffset: &atByteOffset)
        }
    }
