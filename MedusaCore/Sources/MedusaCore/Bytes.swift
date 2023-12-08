//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 08/12/2023.
//

import Foundation

public class Bytes: Sequence
    {
    public var sizeInBytes: Integer64
    private var bytes: Array<Byte>
    
    public var description: String
        {
        fatalError("Not implemented yet.")
        }
        
    public init(bytes: Array<Byte>,sizeInBytes: Integer64)
        {
        self.bytes = bytes
        self.sizeInBytes = sizeInBytes
        }
        
    public init(sizeInBytes: Integer64)
        {
        self.sizeInBytes = sizeInBytes
        self.bytes = Array<Byte>(repeating: 0, count: sizeInBytes)
        }
        
    public init(from buffer: RawPointer,atByteOffset: Integer64,sizeInBytes: Integer64)
        {
        self.bytes = Array<Byte>()
        for _ in 0..<sizeInBytes
            {
            self.bytes.append(buffer.load(fromByteOffset: atByteOffset, as: Byte.self))
            }
        self.sizeInBytes = sizeInBytes
        }
        
    public func copyBytes(into buffer: RawPointer,atByteOffset: Integer64)
        {
        for index in atByteOffset..<self.sizeInBytes + atByteOffset
            {
            buffer.storeBytes(of: self.bytes[index], toByteOffset: index, as: Byte.self)
            }
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
            return(self.bytes[index])
            }
        set
            {
            guard index < self.sizeInBytes else
                {
                fatalError("subscript \(index) greater than count \(self.sizeInBytes).")
                }
            self.bytes[index] = newValue
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
