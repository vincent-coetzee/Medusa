//
//  File 2.swift
//  
//
//  Created by Vincent Coetzee on 08/12/2023.
//

import Foundation
import MedusaObjectModel
import MedusaCore
import MedusaStorage
import MedusaPaging
import Fletcher

public typealias Messages = Array<Message>

public class Message
    {
    public struct MessageField
        {
        public let key: String
        public let byteOffset: Integer64
        public let value: FieldValue
        }
    
    public typealias MessageFields = Dictionary<String,MessageField>
    
    public static let kLengthFieldOffset        = 0
    public static let kKindFieldOffset          = MemoryLayout<Integer64>.size
    
    public enum MessageKind: Byte
        {
        case connectRequest     = 1
        case connectResponse    = 2
        case disconnect         = 3
        case acknowledgement    = 4
        case objectRequest      = 5
        case objectResponse     = 6
        case executeRequest     = 7
        case executeResponse    = 8
        case ping               = 9
        case pong               = 10
        }
        
    public enum FieldValue
        {
        public static let kNothing: Byte          = 0
        public static let kInteger64: Byte        = 1
        public static let kFloat64: Byte          = 2
        public static let kBoolean: Byte          = 3
        public static let kBytes: Byte            = 4
        public static let kByte: Byte             = 5
        public static let kObject: Byte           = 6
        public static let kEnumeration: Byte      = 7
        public static let kString: Byte           = 8
        public static let kObjectAddress: Byte    = 9
        public static let kBuffer: Byte           = 10
        
        case nothing
        case integer64(Integer64)
        case float64(Float64)
        case boolean(Boolean)
        case bytes(Bytes)
        case byte(Byte)
        case object(Object)
        case enumeration(Enumeration)
        case string(String)
        case objectAddress(ObjectAddress)
        case buffer(RawPointer,Integer64)
        
        public var rawValue: Byte
            {
            switch(self)
                {
                case .nothing:
                    return(Self.kNothing)
                case .integer64:
                    return(Self.kInteger64)
                case .float64:
                    return(Self.kFloat64)
                case .boolean:
                    return(Self.kBoolean)
                case .bytes:
                    return(Self.kBytes)
                case .byte:
                    return(Self.kByte)
                case .object:
                    return(Self.kObject)
                case .enumeration:
                    return(Self.kEnumeration)
                case .string:
                    return(Self.kString)
                case .objectAddress:
                    return(Self.kObjectAddress)
                case .buffer:
                    return(Self.kBuffer)
                }
            }
            
        public init(rawValue: Byte,from message: Message)
            {
            let kind = message.readByte()
            switch(kind)
                {
                case(Self.kNothing):
                    self = .nothing
                case(Self.kInteger64):
                    let value = message.buffer.load(fromByteOffset: message.offset, as: Integer64.self)
                    message.offset += MemoryLayout<Integer64>.size
                    self = .integer64(value)
                case(Self.kFloat64):
                    let value = message.buffer.load(fromByteOffset: message.offset, as: Float64.self)
                    message.offset += MemoryLayout<Float64>.size
                    self = .float64(value)
                case(Self.kBoolean):
                    let value = message.buffer.load(fromByteOffset: message.offset, as: Boolean.self)
                    message.offset += MemoryLayout<Boolean>.size
                    self = .boolean(value)
                case(Self.kBytes):
                    let count = message.buffer.load(fromByteOffset: message.offset, as: Integer64.self)
                    message.offset += MemoryLayout<Integer64>.size
                    let bytes = Bytes(sizeInBytes: count)
                    for index in 0..<count
                        {
                        bytes[index] = message.buffer.load(fromByteOffset: message.offset, as: Byte.self)
                        message.offset += MemoryLayout<Byte>.size
                        }
                    self = .bytes(bytes)
                case(Self.kByte):
                    let value = message.buffer.load(fromByteOffset: message.offset, as: Byte.self)
                    message.offset += MemoryLayout<Byte>.size
                    self = .byte(value)
                case(Self.kObject):
                    let object = Object(from: message.buffer,atByteOffset: &message.offset)
                    self = .object(object)
                case(Self.kEnumeration):
                    let object = Enumeration(from: message.buffer,atByteOffset: &message.offset)
                    self = .enumeration(object)
                case(Self.kObjectAddress):
                    let value = message.buffer.load(fromByteOffset: message.offset, as: Unsigned64.self)
                    message.offset += MemoryLayout<Unsigned64>.size
                    self = .objectAddress(ObjectAddress(address: value))
                case(Self.kBytes):
                    let count = message.buffer.load(fromByteOffset: message.offset, as: Integer64.self)
                    message.offset += MemoryLayout<Integer64>.size
                    let pointer = RawPointer.allocate(byteCount: count, alignment: 1)
                    pointer.copyMemory(from: message.buffer + message.offset, byteCount: count)
                    message.offset += count
                    self = .buffer(pointer,count)
                default:
                    fatalError("This should not have happened.")
                }
            }
            
        public func write(into message: Message)
            {
            switch(self)
                {
                case .nothing:
                    message.buffer.storeBytes(of: self.rawValue, toByteOffset: message.offset, as: Byte.self)
                    message.offset += MemoryLayout<Byte>.size
                    message.buffer.storeBytes(of: 0, toByteOffset: message.offset, as: Byte.self)
                    message.offset += MemoryLayout<Integer64>.size
                case .objectAddress(let address):
                    message.buffer.storeBytes(of: self.rawValue, toByteOffset: message.offset, as: Byte.self)
                    message.offset += MemoryLayout<Byte>.size
                    message.buffer.storeBytes(of: address.address, toByteOffset: message.offset, as: Unsigned64.self)
                    message.offset += MemoryLayout<Integer64>.size
                case .integer64(let integer):
                    message.buffer.storeBytes(of: self.rawValue, toByteOffset: message.offset, as: Byte.self)
                    message.offset += MemoryLayout<Byte>.size
                    message.buffer.storeBytes(of: integer, toByteOffset: message.offset, as: Integer64.self)
                    message.offset += MemoryLayout<Integer64>.size
                case .float64(let float):
                    message.buffer.storeBytes(of: self.rawValue, toByteOffset: message.offset, as: Byte.self)
                    message.offset += MemoryLayout<Byte>.size
                    message.buffer.storeBytes(of: float, toByteOffset: message.offset, as: Float64.self)
                    message.offset += MemoryLayout<Float64>.size
                case .boolean(let boolean):
                    message.buffer.storeBytes(of: self.rawValue, toByteOffset: message.offset, as: Byte.self)
                    message.offset += MemoryLayout<Byte>.size
                    message.buffer.storeBytes(of: boolean, toByteOffset: message.offset, as: Boolean.self)
                    message.offset += MemoryLayout<Boolean>.size
                case .byte(let byte):
                    message.buffer.storeBytes(of: self.rawValue, toByteOffset: message.offset, as: Byte.self)
                    message.offset += MemoryLayout<Byte>.size
                    message.buffer.storeBytes(of: byte, toByteOffset: message.offset, as: Byte.self)
                    message.offset += MemoryLayout<Byte>.size
                case .bytes(let bytes):
                    message.buffer.storeBytes(of: self.rawValue, toByteOffset: message.offset, as: Byte.self)
                    message.offset += MemoryLayout<Byte>.size
                    message.buffer.storeBytes(of: bytes.sizeInBytes, toByteOffset: message.offset, as: Integer64.self)
                    message.offset += MemoryLayout<Integer64>.size
                    for byte in bytes
                        {
                        message.buffer.storeBytes(of: byte, toByteOffset: message.offset, as: Byte.self)
                        message.offset += MemoryLayout<Byte>.size
                        }
                case .object(let object):
                    message.buffer.storeBytes(of: self.rawValue, toByteOffset: message.offset, as: Byte.self)
                    message.offset += MemoryLayout<Byte>.size
                    object.write(into: message.buffer,atByteOffset: &message.offset)
                case .enumeration(let enumeration):
                    message.buffer.storeBytes(of: self.rawValue, toByteOffset: message.offset, as: Byte.self)
                    message.offset += MemoryLayout<Byte>.size
                    enumeration.write(into: message.buffer,atByteOffset: &message.offset)
                case .string(let string):
                    message.buffer.storeBytes(of: self.rawValue, toByteOffset: message.offset, as: Byte.self)
                    message.offset += MemoryLayout<Byte>.size
                    message.buffer.storeBytes(of: string.unicodeScalars.count, toByteOffset: message.offset, as: Integer64.self)
                    message.offset += MemoryLayout<Integer64>.size
                    for scalar in string.unicodeScalars
                        {
                        message.buffer.storeBytes(of: scalar, toByteOffset: message.offset, as: UnicodeScalar.self)
                        message.offset += MemoryLayout<UnicodeScalar>.size
                        }
                case .buffer(let pointer,let size):
                    message.buffer.storeBytes(of: self.rawValue, toByteOffset: message.offset, as: Byte.self)
                    message.offset += MemoryLayout<Byte>.size
                    message.buffer.storeBytes(of: size, toByteOffset: message.offset, as: Integer64.self)
                    message.offset += MemoryLayout<Integer64>.size
                    for index in 0..<size
                        {
                        message.buffer.storeBytes(of: pointer.load(fromByteOffset: index, as: Byte.self),toByteOffset: message.offset, as: Byte.self)
                        message.offset += MemoryLayout<Byte>.size
                        }
                }
            }
        }
        
    public var kind: MessageKind
        {
        fatalError("Should have been overridden in a subclass.")
        }
        
    private var buffer: RawPointer
    private var bufferSizeInBytes: Integer64
    private var offset = 0
    private var fields = MessageFields()
    public var fieldCount: Integer64 = 0
    public var sizeInBytes = 0
    
    public var sequenceNumber: Integer64
        {
        get
            {
            self.buffer.load(fromByteOffset: MemoryLayout<Integer64>.size, as: Integer64.self)
            }
        set
            {
            self.buffer.storeBytes(of: newValue, toByteOffset: MemoryLayout<Integer64>.size, as: Integer64.self)
            }
        }
    
    public static func readMessage(from buffer: RawPointer) -> Message
        {
        var sizeInBytes = buffer.load(fromByteOffset: 0, as: Integer64.self)
        let kind = MessageKind(rawValue: buffer.load(fromByteOffset: MemoryLayout<Integer64>.size, as: Byte.self))!
        let offset = MemoryLayout<Integer64>.size + MemoryLayout<Byte>.size
        let pointer = buffer + offset
        sizeInBytes -= offset
        switch(kind)
            {
            case(.connectRequest):
                return(ConnectRequestMessage(from: pointer,sizeInBytes: sizeInBytes))
            case(.connectResponse):
                return(ConnectResponseMessage(from: pointer,sizeInBytes: sizeInBytes))
            case(.disconnect):
                return(DisconnectMessage(from: pointer,sizeInBytes: sizeInBytes))
            case(.acknowledgement):
                return(AcknowledgementMessage(from: pointer,sizeInBytes: sizeInBytes))
            case(.objectRequest):
                return(DisconnectMessage(from: pointer,sizeInBytes: sizeInBytes))
            case(.objectResponse):
                return(AcknowledgementMessage(from: pointer,sizeInBytes: sizeInBytes))
            case(.executeRequest):
                return(ExecuteRequestMessage(from: pointer,sizeInBytes: sizeInBytes))
            case(.executeResponse):
                return(ExecuteResponseMessage(from: pointer,sizeInBytes: sizeInBytes))
            case(.ping):
                return(PingMessage(from: pointer,sizeInBytes: sizeInBytes))
            case(.pong):
                return(PongMessage(from: pointer,sizeInBytes: sizeInBytes))
            }
        }
        
    public init(initialBufferSizeInBytes: Integer64)
        {
        self.bufferSizeInBytes = initialBufferSizeInBytes
        self.buffer = RawPointer.allocate(byteCount: self.bufferSizeInBytes, alignment: 1)
        }
        
    public init(from buffer: RawPointer,sizeInBytes: Integer64)
        {
        self.bufferSizeInBytes = sizeInBytes
        self.buffer = buffer
        self.sequenceNumber = self.readInteger64()
        self.fieldCount = self.readInteger64()
        self.readFields()
        }
        
    private func readFields()
        {
        for _ in 0..<self.fieldCount
            {
            let field = self.readField()
            self.fields[field.key] = field
            }
        }
        
    //
    // This method must be invoked before any writing is done because it sets
    // the buffer up correctly to be written into. The write methods all update
    // the message's offset value so order is important for the few statis fields
    // at the start of the message ( size, sequence number, kind, checksum and field count ).
    // Once writing has been completed the closeForWriting method must be invoked
    // to backpatch some fields and to update the sizeInBytes value.
    public func openForWriting()
        {
        self.offset = 0
        self.write(0)                      // write 0 as the buffer length, it will be patched later
        self.write(0)                      // write a 0 for the sequence number, it will be patched from outside the message using the "sequenceNumber" accessor
        self.write(self.kind.rawValue)     // write kind of message as a byte
        self.write(Unsigned64(0))          // write a zero checksum out, it will be patched later
        self.write(0)                      // write 0 as the number of fields because we don't know the count yet, it will be patched later
        }
    //
    // After this method has been executed the buffer is in a state to be
    // sent via a socket. The method updates the sizeInBytes value to reflect
    // the total size of the buffer including it's length, sequenceNumber,kind,checksum and field count.
    // It can be transmitted just as it is exzcept the sequence number needs to be backpatched using
    // the sequenceNumber accessor because the sequence number is tracked in the MessageBroker not here.
    //
    public func closeForWriting()
        {
        self.sizeInBytes = self.offset
        let checksum = fletcher64(UnsafePointer<UInt32>(OpaquePointer(self.buffer)),self.sizeInBytes)
        // now fill in the blanks
        self.offset = 0
        self.write(self.sizeInBytes)                                                // write the total size of the buffer out
        self.offset += MemoryLayout<Integer64>.size + MemoryLayout<Byte>.size       // slip over sequence number and kind
        self.write(checksum)                                                        // patch the checksum
        self.write(self.fieldCount)                                                 // patch the number of fields
        }
        
    private func readField() -> MessageField
        {
        let key = self.readString()
        let fieldKind = self.readByte()
        let valueOffset = self.offset
        let value = FieldValue(rawValue: fieldKind,from: self)
        let field = MessageField(key: key,byteOffset: valueOffset,value: value)
        return(field)
        }
        
    private func readInteger64() -> Integer64
        {
        let value = self.buffer.load(fromByteOffset: self.offset, as: Integer64.self)
        self.offset += MemoryLayout<Integer64>.size
        return(value)
        }
        
    private func readString() -> String
        {
        let count = self.buffer.load(fromByteOffset: self.offset, as: Integer64.self)
        self.offset += MemoryLayout<Integer64>.size
        var string = String()
        for _ in 0..<count
            {
            string.append(Character(self.buffer.load(fromByteOffset: self.offset, as: UnicodeScalar.self)))
            self.offset += MemoryLayout<UnicodeScalar>.size
            }
        return(string)
        }
        
    private func readByte() -> Byte
        {
        let value = self.buffer.load(fromByteOffset: self.offset, as: Byte.self)
        self.offset += MemoryLayout<Byte>.size
        return(value)
        }
        
    public func writeField(_ value: FieldValue,atKey: String)
        {
        self.write(atKey)
        value.write(into: self)
        }
        
    private func write(_ string: String)
        {
        self.buffer.storeBytes(of: string.unicodeScalars.count, toByteOffset: self.offset, as: Integer64.self)
        self.offset += MemoryLayout<Integer64>.size
        for scalar in string.unicodeScalars
            {
            self.buffer.storeBytes(of: scalar, toByteOffset: self.offset, as: UnicodeScalar.self)
            self.offset += MemoryLayout<UnicodeScalar>.size
            }
        }
        
    private func write(_ integer: Integer64)
        {
        self.buffer.storeBytes(of: integer, toByteOffset: self.offset, as: Integer64.self)
        self.offset += MemoryLayout<Integer64>.size
        }
        
    private func write(_ byte: Byte)
        {
        self.buffer.storeBytes(of: byte, toByteOffset: self.offset, as: Byte.self)
        self.offset += MemoryLayout<Byte>.size
        }
        
    private func write(_ byte: Unsigned64)
        {
        self.buffer.storeBytes(of: byte, toByteOffset: self.offset, as: Unsigned64.self)
        self.offset += MemoryLayout<Unsigned64>.size
        }
    }

public class ConnectRequestMessage: Message
    {
    public override var kind: MessageKind
        {
        .connectRequest
        }
    }

public class ConnectResponseMessage: Message
    {
    public override var kind: MessageKind
        {
        .connectResponse
        }
    }
    
public class DisconnectMessage: Message
    {
    public override var kind: MessageKind
        {
        .disconnect
        }
    }

public class AcknowledgementMessage: Message
    {
    public override var kind: MessageKind
        {
        .acknowledgement
        }
    }
    
public class ObjectRequestMessage: Message
    {
    public override var kind: MessageKind
        {
        .objectRequest
        }
    }

public class ObjectResponseMessage: Message
    {
    public override var kind: MessageKind
        {
        .objectResponse
        }
    }
    
public class ExecuteRequestMessage: Message
    {
    public override var kind: MessageKind
        {
        .executeRequest
        }
    }

public class ExecuteResponseMessage: Message
    {
    public override var kind: MessageKind
        {
        .executeResponse
        }
    }
    
public class PingMessage: Message
    {
    public override var kind: MessageKind
        {
        .ping
        }
    }

public class PongMessage: Message
    {
    public override var kind: MessageKind
        {
        .pong
        }
    }
