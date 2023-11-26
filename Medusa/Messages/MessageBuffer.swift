//
//  MessageBuffer.swift
//  Medusa
//
//  Created by Vincent Coetzee on 16/11/2023.
//

import Foundation
import Socket

public class MessageBuffer: Buffer
    {
    public var fieldSets: FieldSetList
        {
        FieldSetList()
        }
        
    public var count: Int
        {
        self.bufferSize
        }
        
    public enum SizeKind
        {
        case none
        case floating
        case fixed(Int)
        }
        
    public var checksum: Int
        {
        var sum1 = 0
        var sum2 = 0
        for index in 0..<self.bufferSize
            {
            sum1 = (sum1 + Int(self.bytes.load(fromByteOffset: index, as: UInt8.self))) % 255
            sum2 = (sum2 + sum1) % 255
            }
        return(sum2 << 8 | sum1)
        }
        
    public var sizeInBytes: Int
        {
        switch(self.sizeKind)
            {
            case .floating:
                return(Int(self.offset))
            case .fixed(let aSize):
                return(Int(aSize))
            case .none:
                fatalError()
            }
        }
        
    public var maximumSizeInBytes: Int
        {
        self.bufferSize
        }
        
    private var bytes: UnsafeMutableRawPointer
    private var offset = 16
    private var bufferSize: Int = 0
    private var sizeKind: SizeKind = .none
    
    public init(sizeKind: SizeKind = .floating)
        {
        self.bufferSize = Medusa.kDefaultBufferSize
        self.bytes = UnsafeMutableRawPointer.allocate(byteCount: self.bufferSize, alignment: MemoryLayout<Int>.alignment)
        self.offset = 0
        self.sizeKind = sizeKind
        }
        
    public init(socket: Socket) throws
        {
        let intSize = MemoryLayout<Int>.size
        let sizePointer = UnsafeMutablePointer<CChar>.allocate(capacity: intSize)
        defer
            {
            sizePointer.deallocate()
            }
        if try socket.read(into: sizePointer, bufSize: intSize) != intSize
            {
            throw(SystemIssue(code: .incorrectReadSizeInDecodeMessage,agentKind: .unknown,agentLocation: .unknown))
            }
        var integerValue:Int = 0
        sizePointer.withMemoryRebound(to: Int.self, capacity: 1)
            {
            integer in
            integerValue = integer.pointee
            }
        let bytePointer = UnsafeMutablePointer<CChar>.allocate(capacity: integerValue)
        if try socket.read(into: bytePointer, bufSize: integerValue) != integerValue
            {
            throw(SystemIssue(code: .incorrectReadSizeInDecodeMessage,agentKind: .unknown,agentLocation: .unknown))
            }
        self.bytes = UnsafeMutableRawPointer(bytePointer)
        self.bufferSize = integerValue
        self.offset = integerValue
        self.sizeKind = .fixed(integerValue)
        }
        
    public func write(to socket: Socket) throws
        {
        try socket.write(from: &self.offset, bufSize: MemoryLayout<Int>.size)
        try socket.write(from: self.bytes,bufSize: self.offset)
        }
        
    deinit
        {
        self.bytes.deallocate()
        }
        
    public subscript(_ index: Int) -> Medusa.Byte
        {
        get
            {
            if index < self.bufferSize && index >= 0
                {
                return(self.bytes.load(fromByteOffset: index, as: UInt8.self))
                }
            fatalError("Invalid index passed to subscript on MessageBuffer")
            }
        set
            {
            if index < self.bufferSize && index >= 0
                {
                self.bytes.storeBytes(of: newValue,as: UInt8.self)
                return
                }
            fatalError("Invalid index passed to subscript on MessageBuffer")
            }
        }
        
    private func grow()
        {
        let newSize = self.bufferSize * 5 / 3
        let newBuffer = UnsafeMutableRawPointer.allocate(byteCount: newSize, alignment: 8)
        newBuffer.copyMemory(from: self.bytes, byteCount: self.bufferSize)
        self.bufferSize = newSize
        self.bytes.deallocate()
        self.bytes = newBuffer
        }
        
    private func alignOffset<T>(to someType: T.Type)
        {
        if someType == Int8.self
            {
            print("halt")
            }
        let oldOffset = self.offset
        let someAlignment = MemoryLayout<T>.alignment
        if self.offset % someAlignment != 0
            {
            let mask = Int(someAlignment - 1)
            self.offset = Int((self.offset + (-self.offset & mask)) + Int(someAlignment))
            }
        print("Aligned \(oldOffset) to \(T.self) = \(self.offset)")
        }
        
    public func encode(_ permissionsToken: PermissionsToken)
        {
        if self.offset + MemoryLayout<Int>.size >= self.bufferSize
            {
            self.grow()
            }
        permissionsToken.encode(on: self)
        }
        
    public func encode(_ integer: Int)
        {
        if self.offset + MemoryLayout<Int>.size >= self.bufferSize
            {
            self.grow()
            }
        self.alignOffset(to: Int.self)
        self.bytes.storeBytes(of: integer, toByteOffset: self.offset, as: Int.self)
        self.offset += MemoryLayout<Int>.size
        print("wrote \(integer) to buffer at offset \(self.offset)")
        }
        
    public func encode(_ integer: Medusa.ObjectID)
        {
        if self.offset + MemoryLayout<Medusa.ObjectID>.size >= self.bufferSize
            {
            self.grow()
            }
        self.alignOffset(to: Medusa.ObjectID.self)
        self.bytes.storeBytes(of: integer, toByteOffset: self.offset, as: Medusa.ObjectID.self)
        self.offset += MemoryLayout<Medusa.ObjectID>.size
        }
        
    public func encode(_ date: Date)
        {
        if self.offset + MemoryLayout<Int>.size >= self.bufferSize
            {
            self.grow()
            }
        let double = date.timeIntervalSinceReferenceDate
        self.alignOffset(to: Medusa.Float.self)
        self.bytes.storeBytes(of: double, toByteOffset: self.offset,as: Medusa.Float.self)
        self.offset += MemoryLayout<Medusa.Float>.size
        }
        
    public func encode(_ boolean: Bool)
        {
        if self.offset + MemoryLayout<Bool>.size >= self.bufferSize
            {
            self.grow()
            }
        self.alignOffset(to: Bool.self)
        self.bytes.storeBytes(of: boolean,toByteOffset: self.offset,as: Bool.self)
        self.offset += MemoryLayout<Bool>.size
        }
        
    public func encode(_ float: Medusa.Float)
        {
        if self.offset + MemoryLayout<Medusa.Float>.size >= self.bufferSize
            {
            self.grow()
            }
        self.alignOffset(to: Medusa.Float.self)
        self.bytes.storeBytes(of: float,toByteOffset: self.offset,as: Medusa.Float.self)
        self.offset += MemoryLayout<Medusa.Float>.size
        }
        
    public func encode(_ string: String)
        {
        if self.offset + MemoryLayout<Int>.size + string.count * MemoryLayout<Unicode.Scalar>.size >= self.bufferSize
            {
            self.grow()
            }
        self.encode(string.count)
        for scalar in string.unicodeScalars
            {
            self.alignOffset(to: Unicode.Scalar.self)
            self.bytes.storeBytes(of: scalar,toByteOffset: self.offset,as: Unicode.Scalar.self)
            self.offset += MemoryLayout<Unicode.Scalar>.size
            }
        }
        
    public func encode<T:RawRepresentable>(_ enumeration: T) where T.RawValue == Int
        {
        if self.offset + MemoryLayout<Int>.size >= self.bufferSize
            {
            self.grow()
            }
        self.alignOffset(to: Int.self)
        self.bytes.storeBytes(of: enumeration.rawValue,toByteOffset: self.offset, as: Int.self)
        self.offset += MemoryLayout<Int>.size
        }
        
    public func encode(_ address: IPv6Address)
        {
        if self.offset + 16 >= self.bufferSize
            {
            self.grow()
            }
        for byte in address.bytes
            {
            self.alignOffset(to: CChar.self)
            self.bytes.storeBytes(of: byte,toByteOffset: self.offset,as: CChar.self)
            self.offset += MemoryLayout<CChar>.size
            }
        }
        
    public func decodeInteger() -> Int
        {
        let value = self.bytes.load(fromByteOffset: self.offset, as: Int.self)
        self.offset += MemoryLayout<Int>.size
        return(value)
        }
        
    public func decodeFloat() -> Medusa.Float
        {
        let value = self.bytes.load(fromByteOffset: self.offset, as: Medusa.Float.self)
        self.offset += MemoryLayout<Medusa.Float>.size
        return(value)
        }
        
    public func decodeEnumeration<T:RawRepresentable>() -> T? where T.RawValue == Int
        {
        let integer = self.bytes.load(fromByteOffset: self.offset, as: Int.self)
        self.offset += MemoryLayout<Int>.size
        guard let value = T(rawValue: integer) else
            {
            return(nil)
            }
        return(value)
        }
        
    public func decodeString() -> String
        {
        let length = self.decodeInteger()
        var string = String()
        for _ in 0..<length
            {
            string.append(Character(Unicode.Scalar(self.bytes.load(fromByteOffset: self.offset,as: Unicode.Scalar.self))))
            self.offset += MemoryLayout<Unicode.Scalar>.size
            }
        return(string)
        }
        
    public func decodeIPv6Address() -> IPv6Address
        {
        var bytes = Array<CChar>()
        for _ in 0..<16
            {
            bytes.append(self.bytes.load(fromByteOffset: self.offset,as: CChar.self))
            self.offset += MemoryLayout<CChar>.size
            }
        return(IPv6Address(bytes: bytes))
        }

    public func decodeBoolean() -> Bool
        {
        let value = self.bytes.load(fromByteOffset: self.offset, as: Bool.self)
        self.offset += MemoryLayout<Bool>.size
        return(value)
        }
    }
