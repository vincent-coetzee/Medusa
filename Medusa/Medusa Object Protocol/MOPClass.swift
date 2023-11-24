//
//  MOPClass.swift
//  Medusa
//
//  Created by Vincent Coetzee on 17/11/2023.
//

import Foundation

public class MOPClass: MOPObject
    {
    public static let ipv6Address = MOPClass(name: "IPv6Address")
    public static let messageType = MOPEnumerationKind(name: "MessageType").cases("none","ping","pong","connect","connectAccept","connectReject","disconnect","disconnectAccept","Request","Response")
    public static let integer = MOPInteger(name: "Integer")
    public static let string = MOPString(name: "String")
    public static let boolean = MOPBoolean(name: "Boolean")
    public static let float = MOPInteger(name: "Float")
    
    public var superklasses = MOPClasses()
    public var instanceVariables = Dictionary<String,MOPInstanceVariable>()
    public let name: String
    
    public init(name: String)
        {
        self.name = name
        }
        
    public func addInstanceVariable(name: String,klass: MOPClass,offset: Int,keyPath: AnyKeyPath)
        {
        self.instanceVariables[name] = MOPInstanceVariable(name: name,klass: klass,offset: offset,keyPath: keyPath)
        }
        
    public func instanciate() -> MOPObject
        {
        let object = MOPObject()
        object.klass = self
        return(object)
        }
        
    public func encode(into: Buffer,at: Int)
        {
        }
    }

public typealias MOPClasses = Array<MOPClass>
