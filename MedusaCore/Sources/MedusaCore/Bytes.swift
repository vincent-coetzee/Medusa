//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 08/12/2023.
//

import Foundation

//
//
// Bytes is collection of bytes that can be manipulated as a single thing.
// Bytes keeps a collection of bytes which is sizeInBytes + 8 long. The first
// 8 bytes of the collection of bytes is the size of the Bytes in bytes. Rememeber
// when you move Bytes around that they always have that first 8 bytes with the
// sizeInBytes otherwise you'll be unable to figure out why your results ar eoff by 8.
//
//
public class Bytes: Sequence
    {
    public var sizeInBytes: Integer64
    private var bytes: RawPointer
    
    public var description: String
        {
        fatalError("Not implemented yet.")
        }
        
    public init(from: RawPointer,sizeInBytes: Integer64)
        {
        self.bytes = RawPointer.allocate(byteCount: sizeInBytes + MemoryLayout<Integer64>.size, alignment: 1)
        self.bytes.copyMemory(from: from, byteCount: sizeInBytes)
        self.sizeInBytes = sizeInBytes
        self.bytes.storeBytes(of: sizeInBytes, toByteOffset: 0, as: Integer64.self)
        }
        
    public init(sizeInBytes: Integer64)
        {
        self.sizeInBytes = sizeInBytes
        self.bytes = RawPointer.allocate(byteCount: sizeInBytes + MemoryLayout<Integer64>.size, alignment: 1)
        self.bytes.initializeMemory(as: Byte.self, to: 0)
        self.bytes.storeBytes(of: sizeInBytes, toByteOffset: 0, as: Integer64.self)
        }
        
    public init(from buffer: RawPointer,atByteOffset: Integer64,sizeInBytes: Integer64)
        {
        self.bytes = RawPointer.allocate(byteCount: sizeInBytes + MemoryLayout<Integer64>.size, alignment: 1)
        self.bytes.copyMemory(from: buffer + atByteOffset + MemoryLayout<Integer64>.size, byteCount: sizeInBytes)
        self.sizeInBytes = sizeInBytes
        self.bytes.storeBytes(of: sizeInBytes, toByteOffset: 0, as: Integer64.self)
        }
        
    public init(from: Bytes)
        {
        self.sizeInBytes = from.sizeInBytes
        self.bytes = RawPointer.allocate(byteCount: self.sizeInBytes + MemoryLayout<Integer64>.size, alignment: 1)
        from.copyBytes(into: self.bytes,atByteOffset: 0)
        }
        
    public func copyBytes(into buffer: RawPointer,atByteOffset: Integer64)
        {
        buffer.copyMemory(from: self.bytes + atByteOffset, byteCount: self.sizeInBytes + MemoryLayout<Integer64>.size)
        }
        
    public func makeIterator() -> BytesIterator
        {
        BytesIterator(bytes: self)
        }
        
    public subscript(_ index: Integer64) -> Byte
        {
        get
            {
            guard index < self.sizeInBytes else
                {
                fatalError("subscript \(index) greater than count \(self.sizeInBytes).")
                }
            return(self.bytes.load(fromByteOffset: index + MemoryLayout<Integer64>.size, as: Byte.self))
            }
        set
            {
            guard index < self.sizeInBytes else
                {
                fatalError("subscript \(index) greater than count \(self.sizeInBytes).")
                }
            self.bytes.storeBytes(of: newValue, toByteOffset: index + MemoryLayout<Integer64>.size, as: Byte.self)
            }
        }
    }

public struct BytesIterator: IteratorProtocol
    {
    private let bytes: Bytes
    private var index: Int = 0
    
    public init(bytes: Bytes)
        {
        self.bytes = bytes
        }
        
    public mutating func next() -> Byte?
        {
        if index < self.bytes.sizeInBytes
            {
            let value = self.bytes[index]
            self.index = index + 1
            return(value)
            }
        return(nil)
        }
    }
