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
//            1   0000     Integer              = 0
//            0   0001     Object               = 1
//            0   0010     Tuple                = 2
//            0   0011     Boolean              = 3
//            0   0100     String               = 4
//            0   0101     Float16              = 5
//            0   0110     Float32              = 6
//            0   0111     Float64              = 7
//            0   1000     Emnumeration         = 8
//            0   1001     Address              = 9
//            0   1010     Header               = 10
//            0   1011     Bits                 = 11
//            0   1100     Atom                 = 12
//            0   1101     Array                = 13
//            0   1110     Persistent           = 14
//            0   1111     nil                  = 15
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
    public static let argonModule = MOPModule(module: nil,name: "Argon")
    public static let ipv6Address = MOPClass(module: MOPClass.argonModule,name: "IPv6Address",sizeInBytes: 8)
    public static let messageType = MOPEnumerationKind(module: MOPClass.argonModule,name: "MessageType").cases("none","ping","pong","connect","connectAccept","connectReject","disconnect","disconnectAccept","Request","Response")
    public static let integer = MOPInteger(module: MOPClass.argonModule,name: "Integer",sizeInBytes: MemoryLayout<Int>.size)
    public static let string = MOPString(module: MOPClass.argonModule,name: "String")
    public static let boolean = MOPBoolean(module: MOPClass.argonModule,name: "Boolean",sizeInBytes: 1)
    public static let float = MOPInteger(module: MOPClass.argonModule,name: "Float",sizeInBytes: MemoryLayout<Medusa.Float>.size)
    
    public var superklasses = MOPClasses()
    public var instanceVariables = Dictionary<String,MOPInstanceVariable>()
    public let name: String
    private var nextOffset = 8
    public let sizeInBytes: Medusa.Integer64?
    public let module: MOPModule
    
    public var identifier: Identifier
        {
        self.module.identifier + self.name
        }
        
    public init(module: MOPModule,name: String,sizeInBytes: Medusa.Integer64)
        {
        self.module = module
        self.name = name
        self.sizeInBytes = sizeInBytes
        }
        
    public init(module: MOPModule,name: String)
        {
        self.module = module
        self.name = name
        self.sizeInBytes = nil
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
        
    public func instanciate() -> MOPObject
        {
        let object = MOPObject()
        object.klass = self
        return(object)
        }
    }

public typealias MOPClasses = Array<MOPClass>
