//
//  MOPClass.swift
//  Medusa
//
//  Created by Vincent Coetzee on 17/11/2023.
//

import Foundation

//Values:
//    SIGN BIT    4 TAG BITS     TYPE
//    ===============================
//            1   0000     Integer64            = 0     Don't follow
//            0   0001     Integer32            = 1     Don't follow
//            0   0010     Integer16            = 2     Follow
//            0   0011     Float64              = 3     Don't follow
//            0   0100     Float32              = 4     Don't follow
//            0   0101     Float16              = 5     Don't follow
//            0   0110     Array                = 6     Follow
//            0   0111     Atom                 = 7     Don't follow
//            0   1000     Bits                 = 8     Don't follow
//            0   1001     Header               = 9     Don't follow
//            0   1010     True                 = 10    Don't follow
//            0   1011     False                = 11    Don't follow
//            0   1100     Object               = 12    Follow
//            0   1101     Address              = 13    Follow
//            0   1110     Class                = 14    Follow
//            0   1111     Nothing              = 15    Don't follow
//
//            
//Object Structure
//
//            Header 64 Bits           Sign ( 1 bit )      0                                                                                  1
//                                     Tag ( 4 bits )       0000                                                                              5
//                                     SizeInWords ( 36 bits )  000 00000000 00000000 00000000 000000000 0                                   41
//                                     HasBytes ( 1 bit )                                                 0                                  42
//                                     FlipCount ( 13 bits = 8191 )                                        000000 0000000                    55
//                                     IsForwarded ( 1 bit )                                                             0                   56
//                                     Kind ( 8 bits = 256 )                                                               00000000          64
//
//            Class Pointer                                00000000 00000000 00000000 00000000 000000000 00000000 00000000 00000000
//            Slot 0                                       00000000 00000000 00000000 00000000 000000000 00000000 00000000 00000000
//            
//            Slot N                                       00000000 00000000 00000000 00000000 000000000 00000000 00000000 00000000
//            Bytes
//

public class MOPClass: MOPObject
    {

    public static let ipv6Address = MOPIPv6AddressPrimitive(module: .argonModule,name: "IPv6Address").initialize()
    public static let messageType = MOPEnumerationPrimitive(module: .argonModule,name: "MessageType",caseNames: "none","ping","pong","connect","connectAccept","connectReject","disconnect","disconnectAccept","Request","Response").initialize()
    public static let integer64 = MOPInteger64Primitive()
    public static let string = MOPStringPrimitive()
    public static let boolean = MOPBooleanPrimitive()
    public static let float64 = MOPFloat64Primitive()
    public static let byte = MOPBytePrimitive()
    public static let unsigned64 = MOPUnsigned64Primitive()
    public static let module = MOPModuleClass(module: .argonModule, name: "Module").initialize()
    
    public var superklasses = MOPClasses()
    public var instanceVariables = Dictionary<String,MOPInstanceVariable>()
    public let name: String
    private var nextOffset = 8
    public let module: MOPModule
    private var _sizeInBytes: Integer64 = 0
    
    public override var sizeInBytes: Integer64
        {
        self._sizeInBytes
        }
        
    public var identifier: Identifier
        {
        self.module.identifier + self.name
        }
        
    public init(module: MOPModule,name: String)
        {
        self.module = module
        self.name = name
        }
        
    public func addInstanceVariable(name: String,klass: MOPClass)
        {
        let instanceVariable = MOPInstanceVariable(name: name,klass: klass,offset: self.nextOffset)
        self.instanceVariables[name] = instanceVariable
        self.nextOffset += instanceVariable.sizeInBytes
        }
        
    public func addPrimitiveInstanceVariable<R,T>(name: String,klass: MOPClass,keyPath: KeyPath<R,T>)
        {
        let instanceVariable = MOPPrimitiveInstanceVariable(name: name,klass: klass,offset: self.nextOffset,keyPath: keyPath)
        self.instanceVariables[name] = instanceVariable
        self.nextOffset += instanceVariable.sizeInBytes
        }
        
    @discardableResult
    public func initialize() -> Self
        {
        self
        }
        
    public func instanciate() -> MOPObject
        {
        let object = MOPObject()
        object.klass = self
        return(object)
        }
        
    public func encode<T>(_ value: T,into rawBuffer: RawBuffer,toByteOffset:inout Integer64) throws
        {
        if T.self == Integer64.self
            {
            MOPInteger64.encode(value as! Integer64,into: rawBuffer,toByteOffset: &toByteOffset)
            }
        else if T.self == Float64.self
            {
            MOPFloat64.encode(value as! Float64,into: rawBuffer,toByteOffset: &toByteOffset)
            }
        else if T.self == String.self
            {
            MOPString.encode(value as! String,into: rawBuffer,toByteOffset: &toByteOffset)
            }
        else if T.self == Boolean.self
            {
            MOPBoolean.encode(value as! String,into: rawBuffer,toByteOffset: &toByteOffset)
            }
        else if T.self == Byte.self
            {
            MOPByte.encode(value as! String,into: rawBuffer,toByteOffset: &toByteOffset)
            }
        else if T.self == Enumeration.self
            {
            MOPEnumeration.encode(value as! String,into: rawBuffer,toByteOffset: &toByteOffset)
            }
        }
        
    public func decode<T>(from: RawBuffer,atByteOffset: Integer64) throws -> T
        {
        }
    }

public typealias MOPClasses = Array<MOPClass>

public class MOPModuleClass: MOPClass
    {
    }
