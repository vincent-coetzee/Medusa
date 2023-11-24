//
//  PageBuffer.swift
//  Medusa
//
//  Created by Vincent Coetzee on 23/11/2023.
//

import Foundation

public class PageBuffer: Buffer
    {
    public var unsignedInt16Pointer: UnsafePointer<UInt16>
        {
        UnsafePointer<UInt16>(OpaquePointer(self.buffer))
        }
        
    public var count: Medusa.Integer
        {
        self.sizeInBytes
        }
        
    internal var buffer: UnsafeMutableRawPointer
    public private(set) var sizeInBytes: Medusa.Integer
    public var offset: Medusa.Integer = 0
    
    init(sizeInBytes: Medusa.Integer)
        {
        self.buffer = UnsafeMutableRawPointer.allocate(byteCount: sizeInBytes, alignment: MemoryLayout<Medusa.Byte>.alignment)
        self.sizeInBytes = sizeInBytes
        }
        
    init(buffer: UnsafeMutableRawPointer,sizeInBytes: Medusa.Integer)
        {
        self.buffer = buffer
        self.sizeInBytes = sizeInBytes
        }

    public static func align(_ value: Medusa.Integer,to alignment: Medusa.Integer) -> Medusa.Integer
        {
        return((value + alignment - 1) & ~(alignment - 1))
        }
        
    public func storeBytes<T>(of value: T,atByteOffset byteOffset:inout Medusa.Integer,as: T.Type)
        {
        var alignedOffset = Self.align(byteOffset,to: MemoryLayout<T>.alignment)
        self.buffer.storeBytes(of: value, toByteOffset: alignedOffset, as: T.self)
        alignedOffset += MemoryLayout<T>.size
        byteOffset = alignedOffset
        }
        
    public func storeBytes<T>(of value: T,atByteOffset byteOffset: Medusa.Integer,as: T.Type)
        {
        var alignedOffset = Self.align(byteOffset,to: MemoryLayout<T>.alignment)
        self.buffer.storeBytes(of: value, toByteOffset: alignedOffset, as: T.self)
        alignedOffset += MemoryLayout<T>.size
        }
        
    public func storeBytes<T>(of value: T,as: T.Type)
        {
        var alignedOffset = Self.align(self.offset,to: MemoryLayout<T>.alignment)
        self.buffer.storeBytes(of: value, toByteOffset: alignedOffset, as: T.self)
        alignedOffset += MemoryLayout<T>.size
        self.offset = alignedOffset
        }
        
    public func storeBytes(of value: any Fragment,atByteOffset offset:inout Medusa.Integer)
        {
        value.write(to: self,atByteOffset: &offset)
        }
        
    public func load<T>(fromByteOffset byteOffset:inout Medusa.Integer,as: T.Type) -> T where T:Fragment
        {
        T(from: self,atByteOffset: &byteOffset)
        }
        
    public func load<T>(fromByteOffset byteOffset:inout Medusa.Integer,as: T.Type) -> T
        {
        var alignedOffset = Self.align(byteOffset,to: MemoryLayout<T>.alignment)
        let value = self.buffer.load(fromByteOffset: alignedOffset, as: T.self)
        alignedOffset += MemoryLayout<T>.size
        byteOffset = alignedOffset
        return(value)
        }
        
    public func load<T>(fromByteOffset byteOffset: Medusa.Integer,as: T.Type) -> T
        {
        let alignedOffset = Self.align(byteOffset,to: MemoryLayout<T>.alignment)
        let value = self.buffer.load(fromByteOffset: alignedOffset, as: T.self)
        return(value)
        }
        
    public func load<T>(as: T.Type) -> T
        {
        var alignedOffset = Self.align(self.offset,to: MemoryLayout<T>.alignment)
        let value = self.buffer.load(fromByteOffset: alignedOffset, as: T.self)
        alignedOffset += MemoryLayout<T>.size
        self.offset = alignedOffset
        return(value)
        }
        
    public func loadString(fromByteOffset offset:inout Medusa.Integer) -> String
        {
        let count = self.load(fromByteOffset: &offset, as: Medusa.Integer.self)
        let size = self.load(fromByteOffset: &offset, as: Medusa.Integer.self)
        assert(size == MemoryLayout<Unicode.Scalar>.size,"Size should == MemoryLayout<Unicode.Scalar>.size but does not.")
        var string = String()
        for _ in 0..<count
            {
            string.append(Character(self.load(fromByteOffset: &offset,as: Unicode.Scalar.self)))
            }
        return(string)
        }
        
    public func storeString(_ string: String,atByteOffset offset:inout Medusa.Integer)
        {
        self.storeBytes(of: string.unicodeScalars.count, atByteOffset: &offset, as: Medusa.Integer.self)
        self.storeBytes(of: MemoryLayout<Unicode.Scalar>.size, atByteOffset: &offset, as: Medusa.Integer.self)
        var stringIndex = string.unicodeScalars.startIndex
        for _ in 0..<string.unicodeScalars.count
            {
            let character = string.unicodeScalars[stringIndex]
            self.storeBytes(of: character, atByteOffset: &offset, as: Unicode.Scalar.self)
            stringIndex = string.unicodeScalars.index(after: stringIndex)
            }
        }
        
    public func storeBytesUnaligned<T>(_ value: T,atByteOffset: Medusa.Integer)
        {
        let pointer = UnsafeMutablePointer<T>.allocate(capacity: MemoryLayout<T>.size)
        defer
            {
            pointer.deallocate()
            }
        pointer.pointee = value
        let bytePointer = UnsafeRawPointer(OpaquePointer(pointer))
        var offset = atByteOffset
        for index in 0..<MemoryLayout<T>.size
            {
            self.buffer.storeBytes(of: bytePointer.load(fromByteOffset: index, as: Medusa.Byte.self), toByteOffset: offset, as: Medusa.Byte.self)
            offset += MemoryLayout<Medusa.Byte>.size
            }
        }
        
    public func storeBytesUnaligned<T>(_ value: T,atByteOffset:inout Medusa.Integer)
        {
        let pointer = UnsafeMutablePointer<T>.allocate(capacity: MemoryLayout<T>.size)
        defer
            {
            pointer.deallocate()
            }
        pointer.pointee = value
        let bytePointer = UnsafeRawPointer(OpaquePointer(pointer))
        for index in 0..<MemoryLayout<T>.size
            {
            self.buffer.storeBytes(of: bytePointer.load(fromByteOffset: index, as: Medusa.Byte.self), toByteOffset: atByteOffset, as: Medusa.Byte.self)
            atByteOffset += MemoryLayout<Medusa.Byte>.size
            }
        }
        
    public subscript(_ index: Medusa.Integer) -> Medusa.Byte
        {
        get
            {
            self.buffer.load(fromByteOffset: index, as: Medusa.Byte.self)
            }
        set
            {
            self.buffer.storeBytes(of: newValue, toByteOffset: index, as: Medusa.Byte.self)
            }
        }
    }
