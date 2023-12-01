//
//  MedusaBytes.swift
//  Medusa
//
//  Created by Vincent Coetzee on 22/11/2023.
//

import Foundation
import Fletcher

public class Bytes: Buffer,Fragment
    {
    // WARNING: This value alloctaes memory but does not free it, do not use this for production purposes
    public var rawPointer: UnsafeMutableRawPointer
        {
        let pointer = UnsafeMutableRawPointer.allocate(byteCount: self.sizeInBytes, alignment: 1)
        var offset = 0
        for index in 0..<self.sizeInBytes
            {
            pointer.storeBytes(of: self.bytes[index], toByteOffset: offset, as: Medusa.Byte.self)
            offset += MemoryLayout<Medusa.Byte>.size
            }
        return(pointer)
        }
        
    public var fields: CompositeField
        {
        let composite = CompositeField(name: "Bytes Fields")
        composite.append(Field(name: "Medsua.Bytes", value: .bytes(self), offset: 0))
        return(composite)
        }
        
    public func flush()
        {
        }
        
    public var count: Medusa.Integer64
        {
        self.sizeInBytes
        }
    
    public var djb2Hash: Medusa.Integer64
        {
        var hash = UInt64(5381)
        for byte in self.bytes
            {
            hash = ((hash << 5) + hash) + UInt64(byte)
            }
        return(Medusa.Integer64(hash))
        }
        
    public var description: String
        {
        var string = String()
        let pointer = UnsafeMutableRawPointer.from(byteArray: self.bytes, sizeInBytes: self.sizeInBytes)
        defer
            {
            pointer.deallocate()
            }
        var offset = 0
        for _ in 0..<self.sizeInBytes / MemoryLayout<Unicode.Scalar>.size
            {
            let character = Character(pointer.load(fromByteOffset: offset, as: Unicode.Scalar.self))
            string.append(character)
            offset += MemoryLayout<Unicode.Scalar>.size
            }
        return(string)
        }
        
    public private(set) var sizeInBytes: Medusa.Integer64
    public private(set) var bytes: Array<Medusa.Byte>
    
    public static func <(lhs: Bytes, rhs: Bytes) -> Bool
        {
        lhs.djb2Hash < rhs.djb2Hash
        }
        
    public static func ==(lhs: Bytes,rhs: Bytes) -> Bool
        {
        lhs.djb2Hash == rhs.djb2Hash
        }

    public func compact() throws
        {
        }
        
    public func fill(atByteOffset: Medusa.Integer64,with: Medusa.Byte,count: Medusa.Integer64)
        {
        for index in atByteOffset..<min(atByteOffset + count,self.bytes.count)
            {
            self.bytes[index] = with
            }
        for _ in min(atByteOffset + count,self.bytes.count)..<(atByteOffset + count)
            {
            self.bytes.append(with)
            }
        }
        
    public required init(from page: UnsafeMutableRawPointer,atByteOffset offset: Medusa.Integer64)
        {
        var localOffset = offset
        self.sizeInBytes = readIntegerWithOffset(page,&localOffset)
        self.bytes = Array<Medusa.Byte>()
        for _ in 0..<self.sizeInBytes
            {
            let byte = readByteWithOffset(page,&localOffset)
            self.bytes.append(byte)
            }
        }
        
    public required init(from page: UnsafeMutableRawPointer,atByteOffset offset:inout Medusa.Integer64)
        {
        self.sizeInBytes = readIntegerWithOffset(page,&offset)
        self.bytes = Array<Medusa.Byte>()
        for _ in 0..<self.sizeInBytes
            {
            let byte = readByteWithOffset(page,&offset)
            self.bytes.append(byte)
            }
        self.bytes = Array(self.bytes.reversed())
        }
        
    public func allocate(sizeInBytes: Medusa.Integer64) -> Medusa.Integer64
        {
        fatalError("Not yet implemented.")
        }
        
    public func deallocate(at: Medusa.Integer64)
        {
        fatalError("Not yet implemented.")
        }
        
    public init(bytes: Array<Medusa.Byte>)
        {
        self.sizeInBytes = bytes.count
        self.bytes = bytes
        }
        
    public init(sizeInBytes: Medusa.Integer64)
        {
        self.sizeInBytes = sizeInBytes
        self.bytes = Array<Medusa.Byte>()
        }
        
    public subscript(_ index: Medusa.Integer64) -> Medusa.Byte
        {
        get
            {
            self.bytes[index]
            }
        set
            {
            self.bytes[index] = newValue
            }
        }
        
    public func write(to buffer: UnsafeMutableRawPointer, atByteOffset: inout Medusa.Integer64)
        {
        var localOffset = atByteOffset
        writeIntegerWithOffset(buffer,self.sizeInBytes,&localOffset)
        for byte in self.bytes
            {
            writeByteWithOffset(buffer,byte,&localOffset)
            }
        atByteOffset = localOffset
        }
    }
