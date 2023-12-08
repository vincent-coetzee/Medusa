//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 05/12/2023.
//

import Foundation
import MedusaCore
import MedusaStorage
import MedusaPaging

open class Instance: KeyPart
    {
    open var objectAddress: ObjectAddress
        {
        get
            {
            fatalError()
            }
        set
            {
            fatalError()
            }
        }
        
    open var sizeInBytes: Integer64
        {
        fatalError("Should be overriden")
        }
        
    open var `class`: Class
        {
        fatalError()
        }
        
    open var elementClass: Class?
        {
        fatalError()
        }
    
    open var isIndexed: Bool
        {
        fatalError()
        }
        
    open var isKeyed: Bool
        {
        fatalError()
        }
        
    public static func ==(lhs: Instance,rhs: Instance) -> Bool
        {
        fatalError("This should have been overidden in a subclass.")
        }
        
    public static func <(lhs: Instance,rhs: Instance) -> Bool
        {
        fatalError("This should have been overidden in a subclass.")
        }
        
    public static func makeInstance(from address: ObjectAddress) -> Instance
        {
        switch(address.tag)
            {
            case .nothing:
                return(Primitive(objectAddress: address,kind: Primitive.Kind.nothing))
            case .integer64:
                return(Primitive(objectAddress: address,kind: Primitive.Kind.integer64))
            case .float64:
                return(Primitive(objectAddress: address,kind: Primitive.Kind.float64))
            case .byte:
                return(Primitive(objectAddress: address,kind: Primitive.Kind.byte))
            case .boolean:
                return(Primitive(objectAddress: address,kind: Primitive.Kind.boolean))
            case .object:
                return(Primitive(objectAddress: address,kind: Primitive.Kind.object))
            case .unicodeScalar:
                return(Primitive(objectAddress: address,kind: Primitive.Kind.unicodeScalar))
            case .enumeration:
//                return(Enumeration(objectAddress: address))
                fatalError()
            default:
                fatalError()
            }
        }
        
    public required init(from: RawPointer,atByteOffset: inout Integer64)
        {
        }
        
    public func store(into: RawPointer,atByteOffset: inout Integer64)
        {
        }
        
    public func hash(into:inout Hasher)
        {
        fatalError()
        }
    }

public typealias Instances = Array<Instance>
