//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 08/12/2023.
//

import Foundation
//
//
// NOTE: When a Bytes is "stored" into a buffer of some kind, it writes
// it's sizeInBytes into the first word of the buffer. This is specifically
// so that it is possible to find the size of an embedded Bytes before
// having read the whole thing. However the buffer that Bytes holds does NOT
// have a sizeInBytes word at the start.
//
//
public class Bytes: Sequence,AnnotationValueType
    {
    public var sizeInBytes: Integer64
    private var bytes: RawPointer
    
    public var bytesPointer: RawPointer
        {
        self.bytes
        }
        
    public var description: String
        {
        fatalError("Not implemented yet.")
        }
        
    public init(from: RawPointer,sizeInBytes: Integer64)
        {
        self.bytes = RawPointer.allocate(byteCount: sizeInBytes, alignment: 1)
        self.bytes.copyMemory(from: from, byteCount: sizeInBytes)
        self.sizeInBytes = sizeInBytes
        }
        
    public init(sizeInBytes: Integer64)
        {
        self.sizeInBytes = sizeInBytes
        self.bytes = RawPointer.allocate(byteCount: sizeInBytes, alignment: 1)
        self.bytes.initializeMemory(as: Byte.self, to: 0)
        }
        
    public init(from buffer: RawPointer,atByteOffset: Integer64,sizeInBytes: Integer64)
        {
        self.bytes = RawPointer.allocate(byteCount: sizeInBytes, alignment: 1)
        self.bytes.copyMemory(from: buffer + atByteOffset, byteCount: sizeInBytes)
        self.sizeInBytes = sizeInBytes
        }
        
    public init(from: Bytes)
        {
        self.sizeInBytes = from.sizeInBytes
        self.bytes = RawPointer.allocate(byteCount: self.sizeInBytes, alignment: 1)
        self.bytes.copyMemory(from: from.bytes, byteCount: self.sizeInBytes)
        }
        
    public init(from: Bytes,atByteOffset: Integer64,sizeInBytes: Integer64)
        {
        self.sizeInBytes = sizeInBytes
        self.bytes = RawPointer.allocate(byteCount: sizeInBytes, alignment: 1)
        self.bytes.copyMemory(from: from.bytes + atByteOffset, byteCount: sizeInBytes)
        }
        
    public func copyBytes(into buffer: RawPointer,atByteOffset: Integer64)
        {
        buffer.copyMemory(from: self.bytes + atByteOffset, byteCount: self.sizeInBytes)
        }
        
    public func copyBytes(into buffer: RawPointer,atByteOffset: Integer64,sizeInBytes: Integer64)
        {
        buffer.copyMemory(from: self.bytes + atByteOffset, byteCount: sizeInBytes)
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
            return(self.bytes.load(fromByteOffset: index, as: Byte.self))
            }
        set
            {
            guard index < self.sizeInBytes else
                {
                fatalError("subscript \(index) greater than count \(self.sizeInBytes).")
                }
            self.bytes.storeBytes(of: newValue, toByteOffset: index, as: Byte.self)
            }
        }
        
    public func fill(atByteOffset: Integer64,with byte: Byte,count: Integer64)
        {
        for index in atByteOffset..<(atByteOffset + count)
            {
            self[index] = byte
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
