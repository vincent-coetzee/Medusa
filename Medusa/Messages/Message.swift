//
//  Message.swift
//  Medusa
//
//  Created by Vincent Coetzee on 16/11/2023.
//

import Foundation
import Socket

public enum MessageType: Int
    {
    case none                   = 0
    
    case ping                   = 100
    case pong                   = 101
    
    case connect                = 200
    case connectConfirm         = 201
    case connectReject          = 202
    
    case disconnect             = 300
    case disconnectConfirm      = 301
    }
    
public class Message
    {
    private static var _klass: MOPClass?

    private static var klass: MOPClass
        {
        if self._klass.isNil
            {
            let someKlass = MOPClass(name: "Message")
            someKlass.addInstanceVariable(name: "messageType", klass: .messageType, offset: 0,keyPath: \Message.messageType)
            someKlass.addInstanceVariable(name: "sequenceNumber", klass: .integer, offset: 0,keyPath: \Message.sequenceNumber)
            someKlass.addInstanceVariable(name: "sourceIP", klass: .ipv6Address, offset: 0,keyPath: \Message.sourceIP)
            someKlass.addInstanceVariable(name: "targetIP", klass: .ipv6Address, offset: 0,keyPath: \Message.targetIP)
            someKlass.addInstanceVariable(name: "totalMessageSize", klass: .integer, offset: 0,keyPath: \Message.totalMessageSize)
            someKlass.addInstanceVariable(name: "payloadSize", klass: .integer, offset: 0,keyPath: \Message.payloadSize)
            someKlass.addInstanceVariable(name: "payloadOffset", klass: .integer, offset: 0,keyPath: \Message.payloadOffset)
            }
        return(self._klass!)
        }
        
    public var klass: MOPClass
        {
        Self.klass
        }
    //
    // Message class state
    //
    public var messageType: MessageType = .none
    public var sequenceNumber: Int!
    public var sourceIP: IPv6Address!
    public var targetIP: IPv6Address!
    public var totalMessageSize: Int!
    public var payloadSize: Int!
    public var payloadOffset: Int!
    
    private static let messageClasses =
        {
        var dictionary = Dictionary<MessageType,Message.Type>()
        dictionary[.ping] = PingMessage.self
        dictionary[.pong] = PongMessage.self
        dictionary[.connect] = ConnectMessage.self
        dictionary[.connectConfirm] = ConnectConfirmMessage.self
        return(dictionary)
        }()
        
        
    public required init()
        {
        self.messageType = .none
        }
        
    public func decode(from socket: Socket) throws -> Message
        {
        let buffer = try MessageBuffer(socket: socket)
        let messageTypeValue = buffer.decodeInteger()
        guard let messageType = MessageType(rawValue: messageTypeValue) else
            {
            throw(SystemIssue(code: .invalidMessageTypeInDecodeMessage,agentKind: .unknown,agentLocation: .unknown))
            }
        guard let messageClass = Self.messageClasses[messageType] else
            {
            throw(SystemIssue(code: .messageDecodingClassNotFound,agentKind: .unknown,agentLocation: .unknown))
            }
        let message = messageClass.init()
        try message.decode(from: buffer)
        return(message)
        }
        
    public func encode(on socket: Socket) throws
        {
        let buffer = MessageBuffer()
        self.encode(on: buffer)
        try buffer.write(to: socket)
        }
        
    public func encode(on buffer: MessageBuffer)
        {
        buffer.encode(self.messageType)
        buffer.encode(self.sequenceNumber)
        buffer.encode(self.sourceIP)
        buffer.encode(self.targetIP)
        buffer.encode(self.payloadSize)
        buffer.encode(self.payloadOffset)
        print("After encode buffer checksum is \(buffer.checksum)")
        }
        
    public func decode(from buffer: MessageBuffer) throws
        {
        self.totalMessageSize = Int(buffer.sizeInBytes)
        self.sequenceNumber = buffer.decodeInteger()
        self.sourceIP = buffer.decodeIPv6Address()
        self.targetIP = buffer.decodeIPv6Address()
        self.payloadSize = buffer.decodeInteger()
        self.payloadOffset = buffer.decodeInteger()
        }
        
    @inlinable
    public func encode(_ byteBuffer: MessageBuffer,on socket: Socket) throws
        {
        try byteBuffer.write(to: socket)
        }
        
    @inlinable
    public func encode<T:RawRepresentable>(_ enumeration: T,on socket: Socket) throws where T.RawValue == Int
        {
        try self.encode(enumeration.rawValue,on: socket)
        }
        
    @inlinable
    public func encode(_ integer: Int,on socket: Socket) throws
        {
        var value = integer
        try socket.write(from: &value,bufSize: MemoryLayout<Int>.size)
        }
        
    @inlinable
    public func encode(_ float: Medusa.Float,on socket: Socket) throws
        {
        var value = float
        try socket.write(from: &value,bufSize: MemoryLayout<Medusa.Float>.size)
        }
        
    @inlinable
    public func encode(_ string: Medusa.String,on socket: Socket) throws
        {
        let length = string.utf8.count
        try self.encode(length,on: socket)
        try socket.write(from: string,bufSize: length)
        }
        
    @inlinable
    public func encode(_ address: IPv6Address,on socket: Socket) throws
        {
        var values = address.bytes
        try socket.write(from: &values,bufSize: IPv6Address.IPv6AddressLength)
        }
        
    @inlinable
    public func decodeInteger(from socket: Socket) throws -> Int
        {
        let intSize = MemoryLayout<Int>.size
        let pointer = UnsafeMutablePointer<CChar>.allocate(capacity: intSize)
        defer
            {
            pointer.deallocate()
            }
        let sizeRead = try socket.read(into: pointer,bufSize: intSize)
        if sizeRead != intSize
            {
            throw(SystemIssue(code: .incorrectReadSizeInDecodeMessage,agentKind: .unknown,agentLocation: .unknown))
            }
        var integerValue: Int!
        pointer.withMemoryRebound(to: Int.self, capacity: 1)
            {
            integerPointer in
            integerValue = integerPointer.pointee
            }
        return(integerValue)
        }
    //
    //
    // Strings are written to the buffer as an integer size ( which includes the zero terminating byte )
    // followed by the characters of the string and finally followed with a terminating zero byte.
    //
    //
    @inlinable
    public func decodeString(from socket: Socket) throws -> Medusa.String
        {
        let stringSize = try self.decodeInteger(from: socket)
        let pointer = UnsafeMutablePointer<CChar>.allocate(capacity: stringSize)
        defer
            {
            pointer.deallocate()
            }
        let sizeRead = try socket.read(into: pointer,bufSize: stringSize)
        if sizeRead != stringSize
            {
            throw(SystemIssue(code: .incorrectReadSizeInDecodeMessage,agentKind: .unknown,agentLocation: .unknown))
            }
        let string = String(cString: pointer)
        return(string)
        }
        
    @inlinable
    public func decodeMessageBuffer(from socket: Socket) throws -> MessageBuffer
        {
        try MessageBuffer(socket: socket)
        }
        
    @inlinable
    public func decodeFloat(from socket: Socket) throws -> Medusa.Float
        {
        let floatSize = MemoryLayout<Float>.size
        let pointer = UnsafeMutablePointer<CChar>.allocate(capacity: floatSize)
        defer
            {
            pointer.deallocate()
            }
        let sizeRead = try socket.read(into: pointer,bufSize: floatSize)
        if sizeRead != floatSize
            {
            throw(SystemIssue(code: .incorrectReadSizeInDecodeMessage,agentKind: .unknown,agentLocation: .unknown))
            }
        var floatValue: Medusa.Float!
        pointer.withMemoryRebound(to: Medusa.Float.self, capacity: 1)
            {
            floatPointer in
            floatValue = floatPointer.pointee
            }
        return(floatValue)
        }
        
    @inlinable
    public func decodeEnumeration<T:RawRepresentable>(of: T.Type,from socket: Socket) throws -> T where T.RawValue == Int
        {
        let integerValue = try self.decodeInteger(from: socket)
        guard let enumerationValue = T(rawValue: integerValue) else
            {
            throw(SystemIssue(code: .enumerationRawValueNotValidInDecodeEnumeration,agentKind: .unknown,agentLocation: .unknown))
            }
        return(enumerationValue)
        }
        
    @inlinable
    public func decodeIPAddress(from socket: Socket) throws -> IPv6Address
        {
        let addressSize = 16
        let pointer = UnsafeMutablePointer<CChar>.allocate(capacity: addressSize)
        defer
            {
            pointer.deallocate()
            }
        let sizeRead = try socket.read(into: pointer,bufSize: addressSize)
        if sizeRead != addressSize
            {
            throw(SystemIssue(code: .incorrectReadSizeInDecodeMessage,agentKind: .unknown,agentLocation: .unknown))
            }
        var bytes = Array<CChar>()
        pointer.withMemoryRebound(to: CChar.self, capacity: addressSize)
            {
            bytePointer in
            for index in 0..<16
                {
                bytes.append((bytePointer + index).pointee)
                }
            }
        return(IPv6Address(bytes: bytes))
        }
    }
