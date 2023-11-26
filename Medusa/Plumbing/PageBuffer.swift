//
//  PageBuffer.swift
//  Medusa
//
//  Created by Vincent Coetzee on 23/11/2023.
//

import Foundation

//public class PageBuffer: Buffer
//    {
//    public var unsignedInt32Pointer: UnsafePointer<UInt32>
//        {
//        UnsafePointer<UInt32>(OpaquePointer(self.buffer))
//        }
//        
//    public var count: Medusa.Integer64
//        {
//        self.sizeInBytes
//        }
//        
//    internal var buffer: UnsafeMutableRawPointer
//    public private(set) var sizeInBytes: Medusa.Integer64
//    public var offset: Medusa.Integer64 = 0
//    
//    init(sizeInBytes: Medusa.Integer64)
//        {
//        self.buffer = UnsafeMutableRawPointer.allocate(byteCount: sizeInBytes, alignment: MemoryLayout<Medusa.Byte>.alignment)
//        self.sizeInBytes = sizeInBytes
//        }
//        
//    init(buffer: UnsafeMutableRawPointer,sizeInBytes: Medusa.Integer64)
//        {
//        self.buffer = buffer
//        self.sizeInBytes = sizeInBytes
//        }
//
//    public static func align(_ value: Medusa.Integer64,to alignment: Medusa.Integer64) -> Medusa.Integer64
//        {
//        return((value + alignment - 1) & ~(alignment - 1))
//        }
//        
//    public static func alignDown(_ value: Medusa.Integer64,to alignment: Medusa.Integer64) -> Medusa.Integer64
//        {
//        return(value & ~(alignment - 1))
//        }
//        
//    public func storeBytes<T>(of value: T,atByteOffset byteOffset:inout Medusa.Integer64,as: T.Type)
//        {
//        var alignedOffset = Self.align(byteOffset,to: MemoryLayout<T>.alignment)
//        self.buffer.storeBytes(of: value, toByteOffset: alignedOffset, as: T.self)
//        alignedOffset += MemoryLayout<T>.size
//        byteOffset = alignedOffset
//        }
//        
//    public func storeBytes<T>(of value: T,atByteOffset byteOffset: Medusa.Integer64,as: T.Type)
//        {
//        var alignedOffset = Self.align(byteOffset,to: MemoryLayout<T>.alignment)
//        self.buffer.storeBytes(of: value, toByteOffset: alignedOffset, as: T.self)
//        alignedOffset += MemoryLayout<T>.size
//        }
//        
//    public func store(_ value: Medusa.Integer64,atByteOffset byteOffset:inout Medusa.Integer64)
//        {
//        var alignedOffset = Self.align(byteOffset,to: MemoryLayout<Medusa.Integer64>.alignment)
//        self.buffer.storeBytes(of: value, toByteOffset: alignedOffset, as: Medusa.Integer64.self)
//        alignedOffset += MemoryLayout<Medusa.Integer64>.size
//        byteOffset = alignedOffset
//        }
//        
//    public func store(_ value: Medusa.Unsigned32,atByteOffset byteOffset:inout Medusa.Integer64)
//        {
//        var alignedOffset = Self.align(byteOffset,to: MemoryLayout<Medusa.Unsigned32>.alignment)
//        self.buffer.storeBytes(of: value, toByteOffset: alignedOffset, as: Medusa.Unsigned32.self)
//        alignedOffset += MemoryLayout<Medusa.Unsigned32>.size
//        byteOffset = alignedOffset
//        }
//        
//    public func store(_ value: Medusa.Unsigned32,atByteOffset byteOffset:Medusa.Integer64)
//        {
//        let alignedOffset = Self.align(byteOffset,to: MemoryLayout<Medusa.Unsigned32>.alignment)
//        self.buffer.storeBytes(of: value, toByteOffset: alignedOffset, as: Medusa.Unsigned32.self)
//        }
//        
//    public func store(_ value: Medusa.Integer64,atByteOffset byteOffset:Medusa.Integer64)
//        {
//        let alignedOffset = Self.align(byteOffset,to: MemoryLayout<Medusa.Integer64>.alignment)
//        self.buffer.storeBytes(of: value, toByteOffset: alignedOffset, as: Medusa.Integer64.self)
//        }
//        
//    public func store(_ value: Medusa.Unsigned64,atByteOffset byteOffset:inout Medusa.Integer64)
//        {
//        var alignedOffset = Self.align(byteOffset,to: MemoryLayout<Medusa.Unsigned64>.alignment)
//        self.buffer.storeBytes(of: value, toByteOffset: alignedOffset, as: Medusa.Unsigned64.self)
//        alignedOffset += MemoryLayout<Medusa.Unsigned64>.size
//        byteOffset = alignedOffset
//        }
//        
//    public func store(_ value: Medusa.Unsigned64,atByteOffset byteOffset:Medusa.Integer64)
//        {
//        let alignedOffset = Self.align(byteOffset,to: MemoryLayout<Medusa.Unsigned64>.alignment)
//        self.buffer.storeBytes(of: value, toByteOffset: alignedOffset, as: Medusa.Unsigned64.self)
//        }
//        
//    public func storeBytes<T>(of value: T,as: T.Type)
//        {
//        var alignedOffset = Self.align(self.offset,to: MemoryLayout<T>.alignment)
//        self.buffer.storeBytes(of: value, toByteOffset: alignedOffset, as: T.self)
//        alignedOffset += MemoryLayout<T>.size
//        self.offset = alignedOffset
//        }
//        
//    public func storeBytes(of value: any Fragment,atByteOffset offset:inout Medusa.Integer64)
//        {
//        value.write(to: self,atByteOffset: &offset)
//        }
//        
//    public func loadObjectKind(fromByteOffset:inout Medusa.Integer64) -> ObjectKind
//        {
//        ObjectKind(rawValue: self.load(fromByteOffset: &fromByteOffset, as: Medusa.Integer32.self)) ?? .unknown
//        }
//        
//    public func loadObjectKind(fromByteOffset:Medusa.Integer64) -> ObjectKind
//        {
//        ObjectKind(rawValue: self.load(fromByteOffset: fromByteOffset, as: Medusa.Integer32.self)) ?? .unknown
//        }
//        
//    public func loadElementSize(fromByteOffset:inout Medusa.Integer64) -> Medusa.Integer64
//        {
//        Medusa.Integer64(self.load(fromByteOffset: &fromByteOffset, as: Medusa.Integer32.self))
//        }
//        
//    public func loadElementSize(fromByteOffset:Medusa.Integer64) -> Medusa.Integer64
//        {
//        Medusa.Integer64(self.load(fromByteOffset: fromByteOffset, as: Medusa.Integer32.self))
//        }
//        
//    public func storeElementSize(_ size: Medusa.Integer64,atByteOffset:inout Medusa.Integer64)
//        {
//        self.storeBytes(of: Medusa.Integer32(size), atByteOffset: &atByteOffset,as: Medusa.Integer32.self)
//        }
//        
//   public func storeElementSize(_ size: Medusa.Integer64,atByteOffset:Medusa.Integer64)
//        {
//        self.storeBytes(of: Medusa.Integer32(size), atByteOffset: atByteOffset,as: Medusa.Integer32.self)
//        }
//        
//    public func storeObjectKind(_ kind: ObjectKind,atByteOffset:inout Medusa.Integer64)
//        {
//        self.storeBytes(of: kind.rawValue, atByteOffset: &atByteOffset,as: Medusa.Integer32.self)
//        }
//        
//    public func storeObjectKind(_ kind: ObjectKind,atByteOffset:Medusa.Integer64)
//        {
//        self.storeBytes(of: kind.rawValue, atByteOffset: atByteOffset,as: Medusa.Integer32.self)
//        }
//        
//    public func load<T>(fromByteOffset byteOffset:inout Medusa.Integer64,as: T.Type) -> T where T:Fragment
//        {
//        var alignedOffset = Self.align(byteOffset,to: MemoryLayout<T>.alignment)
//        return(T(from: self,atByteOffset: &alignedOffset))
//        }
//        
//    public func loadInteger64(fromByteOffset byteOffset:inout Medusa.Integer64) -> Medusa.Integer64
//        {
//        var alignedOffset = Self.align(byteOffset,to: MemoryLayout<Medusa.Integer64>.alignment)
//        let value = self.buffer.load(fromByteOffset: alignedOffset, as: Medusa.Integer64.self)
//        alignedOffset += MemoryLayout<Medusa.Integer64>.size
//        byteOffset = alignedOffset
//        return(value)
//        }
//        
//    public func loadInteger64(fromByteOffset byteOffset:Medusa.Integer64) -> Medusa.Integer64
//        {
//        let alignedOffset = Self.align(byteOffset,to: MemoryLayout<Medusa.Integer64>.alignment)
//        let value = self.buffer.load(fromByteOffset: alignedOffset, as: Medusa.Integer64.self)
//        return(value)
//        }
//        
//    public func loadUnsigned64(fromByteOffset byteOffset:inout Medusa.Integer64) -> Medusa.Unsigned64
//        {
//        var alignedOffset = Self.align(byteOffset,to: MemoryLayout<Medusa.Unsigned64>.alignment)
//        let value = self.buffer.load(fromByteOffset: alignedOffset, as: Medusa.Unsigned64.self)
//        alignedOffset += MemoryLayout<Medusa.Unsigned64>.size
//        byteOffset = alignedOffset
//        return(value)
//        }
//        
//    public func loadUnsigned64(fromByteOffset byteOffset:Medusa.Integer64) -> Medusa.Unsigned64
//        {
//        let alignedOffset = Self.align(byteOffset,to: MemoryLayout<Medusa.Unsigned64>.alignment)
//        let value = self.buffer.load(fromByteOffset: alignedOffset, as: Medusa.Unsigned64.self)
//        return(value)
//        }
//        
//    public func loadUnsigned32(fromByteOffset byteOffset:Medusa.Integer64) -> Medusa.Unsigned32
//        {
//        let alignedOffset = Self.align(byteOffset,to: MemoryLayout<Medusa.Unsigned32>.alignment)
//        let value = self.buffer.load(fromByteOffset: alignedOffset, as: Medusa.Unsigned32.self)
//        return(value)
//        }
//        
//    public func load<T>(fromByteOffset byteOffset:inout Medusa.Integer64,as: T.Type) -> T
//        {
//        var alignedOffset = Self.align(byteOffset,to: MemoryLayout<T>.alignment)
//        let value = self.buffer.load(fromByteOffset: alignedOffset, as: T.self)
//        alignedOffset += MemoryLayout<T>.size
//        byteOffset = alignedOffset
//        return(value)
//        }
//        
//    public func load<T>(fromByteOffset byteOffset: Medusa.Integer64,as: T.Type) -> T
//        {
//        let alignedOffset = Self.align(byteOffset,to: MemoryLayout<T>.alignment)
//        let value = self.buffer.load(fromByteOffset: alignedOffset, as: T.self)
//        return(value)
//        }
//        
//    public func load<T>(as: T.Type) -> T
//        {
//        var alignedOffset = Self.align(self.offset,to: MemoryLayout<T>.alignment)
//        let value = self.buffer.load(fromByteOffset: alignedOffset, as: T.self)
//        alignedOffset += MemoryLayout<T>.size
//        self.offset = alignedOffset
//        return(value)
//        }
//        
//    public func loadString(fromByteOffset offset:inout Medusa.Integer64) -> String
//        {
//        let objectKind = self.loadObjectKind(fromByteOffset: &offset)
//        assert(objectKind == .string,"String object kind should == .string but does not.")
//        let count = self.loadInteger64(fromByteOffset: &offset)
//        let size = self.loadElementSize(fromByteOffset: &offset)
//        assert(size == MemoryLayout<Unicode.Scalar>.size,"Size should == MemoryLayout<Unicode.Scalar>.size but does not.")
//        var string = String()
//        for _ in 0..<count
//            {
//            string.append(Character(self.load(fromByteOffset: &offset,as: Unicode.Scalar.self)))
//            }
//        return(string)
//        }
//        
//    public func storeString(_ string: String,atByteOffset offset:inout Medusa.Integer64)
//        {
//        self.storeObjectKind(.string,atByteOffset: &offset)
//        self.store(string.unicodeScalars.count, atByteOffset: &offset)
//        self.storeElementSize(MemoryLayout<Unicode.Scalar>.size, atByteOffset: &offset)
//        var stringIndex = string.unicodeScalars.startIndex
//        for _ in 0..<string.unicodeScalars.count
//            {
//            let character = string.unicodeScalars[stringIndex]
//            self.storeBytes(of: character, atByteOffset: &offset, as: Unicode.Scalar.self)
//            stringIndex = string.unicodeScalars.index(after: stringIndex)
//            }
//        }
//        
////    public func storeBytesUnaligned<T>(_ value: T,atByteOffset: Medusa.Integer64)
////        {
////        let pointer = UnsafeMutablePointer<T>.allocate(capacity: MemoryLayout<T>.size)
////        defer
////            {
////            pointer.deallocate()
////            }
////        pointer.pointee = value
////        let bytePointer = UnsafeRawPointer(OpaquePointer(pointer))
////        var offset = atByteOffset
////        for index in 0..<MemoryLayout<T>.size
////            {
////            self.buffer.storeBytes(of: bytePointer.load(fromByteOffset: index, as: Medusa.Byte.self), toByteOffset: offset, as: Medusa.Byte.self)
////            offset += MemoryLayout<Medusa.Byte>.size
////            }
////        }
//        
//    public func storeBytesUnaligned<T>(_ value: T,atByteOffset: Int)
//        {
//        (self.buffer + atByteOffset).bindMemory(to: T.self,capacity: 1).pointee = value
//        }
//        
//    public func storeUnaligned<T>(_ value: T,atByteOffset: Int)
//        {
//        (self.buffer + atByteOffset).bindMemory(to: T.self,capacity: 1).pointee = value
//        }
//        
//    public func storeUnaligned<T:Fragment>(_ value: T,atByteOffset:inout Int)
//        {
//        value.write(to: self,atByteOffset: &atByteOffset)
//        }
//        
//    public func storeBytesUnaligned<T>(_ value: T,atByteOffset:inout Medusa.Integer64)
//        {
//        let pointer = UnsafeMutablePointer<T>.allocate(capacity: MemoryLayout<T>.size)
//        defer
//            {
//            pointer.deallocate()
//            }
//        pointer.pointee = value
//        let bytePointer = UnsafeRawPointer(OpaquePointer(pointer))
//        for index in 0..<MemoryLayout<T>.size
//            {
//            self.buffer.storeBytes(of: bytePointer.load(fromByteOffset: index, as: Medusa.Byte.self), toByteOffset: atByteOffset, as: Medusa.Byte.self)
//            atByteOffset += MemoryLayout<Medusa.Byte>.size
//            }
//        }
//        
//    public subscript(_ index: Medusa.Integer64) -> Medusa.Byte
//        {
//        get
//            {
//            self.buffer.load(fromByteOffset: index, as: Medusa.Byte.self)
//            }
//        set
//            {
//            self.buffer.storeBytes(of: newValue, toByteOffset: index, as: Medusa.Byte.self)
//            }
//        }
//    }
