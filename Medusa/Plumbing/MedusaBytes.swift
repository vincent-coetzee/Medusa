//
//  MedusaBytes.swift
//  Medusa
//
//  Created by Vincent Coetzee on 22/11/2023.
//

import Foundation

public class MedusaBytes: Buffer,Fragment
    {
    public var count: Medusa.Integer
        {
        self._count
        }
    
    public var djb2Hash: Medusa.Integer
        {
        var hash = UInt64(5381)
        for byte in self.bytes
            {
            hash = ((hash << 5) + hash) + UInt64(byte)
            }
        return(Medusa.Integer(hash))
        }
        
    public var description: String
        {
        var string = String()
        for byte in self.bytes
            {
            string += String(format: "%02X",byte) + " "
            }
        return(string)
        }
        
    public private(set) var sizeInBytes: Medusa.Integer
    public private(set) var bytes: Array<Medusa.Byte>
    public let elementSizeInBytes: Medusa.Integer
    private var _count: Medusa.Integer = 0
    
    public static func <(lhs: MedusaBytes, rhs: MedusaBytes) -> Bool
        {
        lhs.djb2Hash < rhs.djb2Hash
        }
        
    public static func ==(lhs: MedusaBytes,rhs: MedusaBytes) -> Bool
        {
        lhs.djb2Hash == rhs.djb2Hash
        }

    public required init(from page: PageBuffer,atByteOffset offset: Medusa.Integer)
        {
        var localOffset = offset
        var size = 0
        self._count = page.load(fromByteOffset: &localOffset, as: Medusa.Integer.self)
        if self._count > 10000
            {
            print("halt")
            }
        size = page.load(fromByteOffset: &localOffset, as: Medusa.Integer.self)
        self.elementSizeInBytes = size
        self.sizeInBytes = self._count * self.elementSizeInBytes
        self.bytes = Array<Medusa.Byte>()
        for _ in 0..<self.sizeInBytes
            {
            self.bytes.append(page.load(fromByteOffset: &localOffset, as: Medusa.Byte.self))
            }
        }
        
    public required init(from page: PageBuffer,atByteOffset offset:inout Medusa.Integer)
        {
        var size = 0
        self._count = page.load(fromByteOffset: &offset, as: Medusa.Integer.self)
        if self._count > 10000
            {
            print("halt")
            }
        size = page.load(fromByteOffset: &offset, as: Medusa.Integer.self)
        self.elementSizeInBytes = size
        self.sizeInBytes = self._count * self.elementSizeInBytes
        self.bytes = Array<Medusa.Byte>()
        for _ in 0..<self.sizeInBytes
            {
            self.bytes.append(page.load(fromByteOffset: &offset, as: Medusa.Byte.self))
            }
        }
        
    public init(bytes: Array<Medusa.Byte>)
        {
        self.sizeInBytes = bytes.count
        self._count = bytes.count
        self.bytes = bytes
        self.elementSizeInBytes = MemoryLayout<Medusa.Byte>.size
        }
        
    public init(sizeInBytes: Medusa.Integer)
        {
        self._count = sizeInBytes
        self.sizeInBytes = sizeInBytes
        self.bytes = Array<Medusa.Byte>()
        self.elementSizeInBytes = MemoryLayout<Medusa.Byte>.size
        }
        
    public subscript(_ index: Medusa.Integer) -> Medusa.Byte
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
        
    public func write(to buffer: PageBuffer, atByteOffset: inout Medusa.Integer)
        {
        var localOffset = atByteOffset
        buffer.storeBytes(of: self._count,atByteOffset: &localOffset, as: Medusa.Integer.self)
        buffer.storeBytes(of: self.elementSizeInBytes,atByteOffset: &localOffset, as: Int.self)
        for byte in self.bytes
            {
            buffer.storeBytes(of: byte,atByteOffset: &localOffset, as: Medusa.Byte.self)
            }
        atByteOffset = localOffset
        }
    }
