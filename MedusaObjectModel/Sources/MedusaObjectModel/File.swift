//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 05/12/2023.
//

import Foundation
import MedusaCore
import MedusaStorage
import Fletcher
    
public protocol Readable
    {
    var sizeInBytes: Integer64 { get }
    init(readFrom: RawPointer,atByteOffset:inout Integer64)
    }
    
public protocol Writable: Readable
    {
    func write(into: RawPointer,atByteOffset: inout Integer64)
    }
    
public protocol Reader
    {
    func readInteger64(from: RawPointer,atByteOffset:inout Integer64) -> Integer64
    func readFloat64(from: RawPointer,atByteOffset:inout Integer64) -> Float64
    func readString(from: RawPointer,atByteOffset:inout Integer64) -> MOMString
    func readBoolean(from: RawPointer,atByteOffset:inout Integer64) -> Boolean
    func readEnumeration(from: RawPointer,atByteOffset:inout Integer64) -> Enumeration
    }
    
public protocol Writer
    {
    }
    
public protocol KeyPart: Comparable,Equatable,Hashable,Writable
    {

    }
    
public enum PrimitiveValue
    {
    case nothing
    case integer64(Integer64)
    case float64(Float64)
    case string(MOMString)
    case atom(Atom)
    case boolean(Boolean)
    case byte(Byte)
    case object(Pointer)
    
    public var sizeInBytes: Integer64
        {
        switch(self)
            {
            case .nothing:
                return(MemoryLayout<Pointer>.size)
            case .atom:
                return(MemoryLayout<Pointer>.size)
            case .integer64:
                return(MemoryLayout<Integer64>.size)
            case .float64:
                return(MemoryLayout<Float64>.size)
            case .string:
                return(MemoryLayout<Pointer>.size)
            case .boolean:
                return(MemoryLayout<Pointer>.size)
            case .byte:
                return(MemoryLayout<Pointer>.size)
            case .object:
                return(MemoryLayout<Pointer>.size)
            }
        }
        
    public var `class`: Class
        {
        switch(self)
            {
            case .nothing:
                return(.nothingClass)
            case .atom:
                return(.atomClass)
            case .integer64:
                return(.integer64Class)
            case .float64:
                return(.float64Class)
            case .byte:
                return(.byteClass)
            case .boolean:
                return(.booleanClass)
            case .string:
                return(.stringClass)
            case .object(let pointer):
                return(pointer.class)
            }
        }
    }
    
open class Instance: Equatable,Comparable
    {
    open var objectPointer: ObjectPointer
        {
        }
        
    open var objectID: ObjectID
        {
        fatalError()
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
        fatalError("Unimplemented")
        }
        
    public static func <(lhs: Instance,rhs: Instance) -> Bool
        {
        fatalError("Unimplemented")
        }
    }


open class Object: Instance
    {
    public var wordValue: Word
        {
        0
        }
        
    private var core: ObjectCore
    
    init(from: RawPointer,atByteOffset: Integer64)
        {
        fatalError()
        }
        
    init(from: Pointer)
        {
        fatalError()
        }
        
    init(from: Page)
        {
        fatalError()
        }
    }
    
open class Primitive: Instance
    {
    public let primitiveValue: PrimitiveValue
    
    open override var `class`: Class
        {
        fatalError()
        }
        
    open override var elementClass: Class?
        {
        fatalError()
        }
    
    open override var isIndexed: Bool
        {
        return(false)
        }
        
    open override var isKeyed: Bool
        {
        return(false)
        }
        
    open override var sizeInBytes: Integer64
        {
        self.primitiveValue.sizeInBytes
        }
        
    public init(from: RawPointer,atByteOffset: Integer64)
        {
        fatalError()
        }
        
    public init(from: RawPointer,atByteOffset: inout Integer64)
        {
        fatalError()
        }
        
    open func write(to: RawPointer,atByteOffset: Integer64)
        {
        }
        
    open func write(to: RawPointer,atByteOffset:inout  Integer64)
        {
        }
    }
    
    
open class Slot
    {
    public let name: String
    public let `class`: Class
    public let byteOffset: Integer64
    
    init(name: String,class: Class,atByteOffset: Integer64)
        {
        self.name = name
        self.class = `class`
        self.byteOffset = atByteOffset
        }
    }
    
open class MOMCollection: Object
    {
    }
    
open class MOMModule: MOMCollection
    {
    }
    
open class MOMArray: MOMCollection
    {
    }
    
open class MOMString: MOMCollection
    {
    }
    
open class ObjectCore
    {
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
    
    init(from: RawPointer,atByteOffset: Integer64)
        {
        fatalError()
        }
        
    init(pointer: Pointer)
        {
        fatalError()
        }
    
    func valueOfSlot(named: String) -> Instance
        {
        fatalError()
        }
        
    func setValue(_ value: Instance,ofSlotNamed: String)
        {
        }
        
    func valueOfSlot(_ slot: Slot) -> Instance
        {
        fatalError()
        }
        
    func setValue(_ value: Instance,ofSlot: Slot)
        {
        }
        
        
    func setInteger64Value(_ integer: Integer64,ofSlotNamed: String)
        {
        }
        
    func setFloat64Value(_ integer: Float64,ofSlotNamed: String)
        {
        }
        
    func setStringValue(_ integer: String,ofSlotNamed: String)
        {
        }
        
    func setAtomValue(_ atom: Atom,ofSlotNamed: String)
        {
        }
        
    func integer64ValueOfSlot(named: String) -> Integer64
        {
        fatalError()
        }
        
    func float64ValueOfSlot(named: String) -> Float64
        {
        fatalError()
        }
        
    func atomValueOfSlot(named: String) -> Atom
        {
        fatalError()
        }
        
    func stringValueOfSlot(named: String) -> String
        {
        fatalError()
        }
        
    subscript(_ index: Integer64) -> Instance
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
        
    subscript(_ key: Instance) -> Instance
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
    }



extension Pointer
    {
    public var `class`: Class
        {
        Class.class(atPointer: RawPointer(bitPattern: self)!.load(fromByteOffset: Class.kSlotOffset, as: Pointer.self))
        }
    }


open class HashDictionary: MOMCollection
    {
    
    }
    
open class IdentityDictionary: HashDictionary
    {
    public subscript(_ atom: Atom) -> Instance
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
    }
    
open class SystemDictionary: IdentityDictionary
    {
    public static var shared: SystemDictionary!
    }

extension Atom
    {
    init(_ string: String)
        {
        fatalError()
        }
    }


    
public class Enumeration: Primitive
    {
    public var wordValue: Word
        {
        0
        }
    }
    
public class PrimitiveClass: Class
    {
    public override func readInstance(from rawPointer: RawPointer,atByteOffset:inout Integer64) -> Instance
        {
        Primitive(readFrom: rawPointer,atByteOffset: &atByteOffset)
        }
        
    public override func write(_ instance: Instance,into rawPointer: RawPointer,atByteOffset:inout Integer64)
        {
        instance.write(into: rawPointer,atByteOffset: &atByteOffset)
        }
    }
