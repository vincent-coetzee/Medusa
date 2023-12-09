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

public protocol Instance: Equatable,Hashable,Comparable
    {
    var objectAddress: ObjectAddress { get set }
    var sizeInBytes: Integer64 { get }
    var `class`: Class { get }
    var elementClass: Class? { get }
    var isIndexed: Boolean { get }
    
    static func makeInstance(from: ObjectAddress) -> any Instance
    
    init(from: RawPointer,atByteOffset: Integer64)
    init(from: Page,atByteOffset: Integer64)
    
    func encode(into: Page)
    func encode(into: RawPointer)
    func value(ofSlotAtKey: String) -> any Instance
    func setValue(_ value: any Instance,ofSlotAtKey: String)
    
    subscript(_ index: Integer64) -> any Instance { get set }
    }
    
open class InstanceA: KeyPart
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
        
    //
    // This encodes the instance into the specified buffer. This means
    // that 
    public func encode(into buffer: RawPointer,atByteOffset: Integer64)
        {
        }
        
    public func encode(into page: Page,atByteOffset: inout Integer64)
        {
        self.encodeIntoPage(atByteOffset: atByteOffset)
        }
        
    public func hash(into:inout Hasher)
        {
        fatalError()
        }
    }

public typealias Instances = Array<Instance>
