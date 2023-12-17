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
import Fletcher

open class Class: Instance
{
    public var description: String
    
    public var objectHash: MedusaCore.Integer64
    
    public var _class: Any
    
    public var hasBytes: MedusaCore.Boolean
    
    public var isNothing: MedusaCore.Boolean
    
    public func writeClass(into page: Any, atIndex: MedusaCore.Integer64) throws {
        
    }
    public func write(into page: Any, atIndex: MedusaCore.Integer64) throws {
        fatalError()
    }
    
    public func write(into pointer: MedusaCore.RawPointer, atByteOffset: inout MedusaCore.Integer64) throws {
        fatalError()
    }
    
    public func writeKey(into pointer: MedusaCore.RawPointer, atByteOffset: inout MedusaCore.Integer64) throws {
        fatalError()
    }
    
    public func writeValue(into pointer: MedusaCore.RawPointer, atByteOffset: inout MedusaCore.Integer64) throws {
        fatalError()
    }
    
    public func pack(into buffer: MedusaCore.RawPointer, atByteOffset: inout MedusaCore.Integer64) throws {
        fatalError()
    }
    
    public func value(ofSlotAtKey: String) -> any MedusaCore.Instance {
        fatalError()
    }
    
    public func setValue(_ value: any MedusaCore.Instance, ofSlotAtKey: String) {
        fatalError()
    }
    
    public func isEqual(to: Any) -> Bool {
        fatalError()
    }
    
    public func isLess(than: Any) -> Bool {
        fatalError()
    }
    
    private static let kHeaderSlotOffset        = 0
    private static let kClassSlotOffset         = Class.kHeaderSlotOffset + MemoryLayout<Integer64>.size
    private static let kHandleSlotOffset        = Class.kClassSlotOffset + MemoryLayout<Integer64>.size
    private static let kHashSlotOffset          = Class.kHandleSlotOffset + MemoryLayout<Integer64>.size
    private static let kBlockAddressOffset      = Class.kHashSlotOffset + MemoryLayout<Integer64>.size
    
    private static var nextClassHandle = 1024
    
    public static let kClassSizeInBytes         = 9 * MemoryLayout<Integer64>.size
    public static let kCollectionSizeInBytes    = 8 * MemoryLayout<Integer64>.size
    
    public static func allocateClassHandle() -> Integer64
        {
        let index = Self.nextClassHandle
        Self.nextClassHandle += 1
        return(index)
        }
        
    public var isObjectClass: Bool
        {
        true
        }
        
    public var slotNames: Array<String>
        {
        self._slots.values.map{$0.name}
        }
        
    // Instance variables for Class
    public var staticSlots: Slots
        {
        self._staticSlots
        }
        
    public var totalSlotCount: Integer64
        {
        let count = self._staticSlots.count + self._dynamicSlots.count
        return(self.superclass.isNil ? count : count + self.superclass!.totalSlotCount)
        }
        
    public var dynamicSlots: Slots
        {
        self._dynamicSlots
        }
        
    public var instanceSizeInBytes: Integer64
        {
        self.totalSlotCount * MemoryLayout<Integer64>.size
        }
        
    public var firstInstanceSlotOffset: Integer64
        {
        (self.instanceHasBytes ? Self.kHashSlotOffset : Self.kBlockAddressOffset) + MemoryLayout<Integer64>.size
        }
        
    public var slotSizeInBytes: Integer64
        {
        Integer64.bitWidth / 8
        }
        
    public var objectHandle: ObjectHandle
        {
        ObjectHandle(newWithClass: self)
        }
        
    public var objectAddress: ObjectAddress = ObjectAddress.kNothing
        
    public var sizeInBytes: Integer64
        {
        self.class.instanceSizeInBytes
        }
        
    public var instanceHasBytes = false
    fileprivate var _staticSlots = Array<Slot>()
    fileprivate var _dynamicSlots = Array<Slot>()
    fileprivate var _slots = Dictionary<String,Slot>()
    public let name: String
    public var superclass:Class?
    fileprivate var nextInstanceHandle = 1024
    fileprivate var superOffsetAdjustment = 0
    fileprivate var laidOutSlots = Slots()
    fileprivate var wereSlotsLaidOut = false
    public var instanceClass: Object.Type?
    public var objectWrangler: ObjectWrangler!
    public private(set) var classHandle = Class.allocateClassHandle()
    
    // perhaps should create a Cache class and use that here in place of the Dictionary because it can have extra logic
    private static var classCache = Dictionary<Unsigned64,Class>()
    
    //
    // Constants defined for use in the class
    //
    public static let kSlotOffset: Integer64 = MemoryLayout<Integer64>.size

    private static let kObjectHeaderSlotName              = "__headerSlot"
    private static let kObjectClassSlotName               = "__classSlot"
    private static let kObjectHandleSlotName              = "__handleSlot"
    private static let kObjectHashSlotName                = "__hashSlot"
    private static let kObjectBlockAddressSlotName        = "__blockAddressSlot"
    
    public static let kInitialBlockSlotCount             =  64
        
    public static func <(lhs: Class,rhs: Class) -> Bool
        {
        lhs.name < rhs.name
        }
        
    public static func ==(lhs: Class,rhs: Class) -> Bool
        {
        lhs.objectHandle == rhs.objectHandle
        }
        
    public required init(inMemoryNamed name: String,superclass: Class?,hasBytes: Boolean = false)
        {
        fatalError()
        self.superclass = superclass
        self.name = name
        self.instanceHasBytes = hasBytes
        self.initStaticSlots()
        }

    private func initStaticSlots()
        {
        self.addStaticSlot(named: Self.kObjectHeaderSlotName,class: Class.objectHeaderClass)
        self.addStaticSlot(named: Self.kObjectClassSlotName,class: Class.classClass)
        self.addStaticSlot(named: Self.kObjectHashSlotName,class: Class.integer64Class)
        self.addStaticSlot(named: Self.kObjectHandleSlotName,class: Class.objectHandleClass)
        }
        
    public func copy() -> Self
        {
        let newClass = Self.init(inMemoryNamed: self.name, superclass: self.superclass)
        newClass.instanceHasBytes = self.instanceHasBytes
        newClass._staticSlots = self._staticSlots.map{$0.copy()}
        newClass._dynamicSlots = self._dynamicSlots.map{$0.copy()}
        newClass._slots = Dictionary<String,Slot>()
        newClass.nextInstanceHandle = 1024
        newClass.superOffsetAdjustment = self.superOffsetAdjustment
        newClass.wereSlotsLaidOut = false
        newClass.instanceClass = self.instanceClass
        return(newClass)
        }
        
    private func addStaticSlot(named: String,class: Class)
        {
        let slot = Slot(name: named, class: `class`, atByteOffset: 0,isStaticSlot: true)
        self._staticSlots.append(slot)
        self._slots[named] = slot
        self.wereSlotsLaidOut = false
        }
        
    private func addDynamicSlot(named: String,class: Class)
        {
        let slot = Slot(name: named, class: `class`, atByteOffset: 0)
        self._dynamicSlots.append(slot)
        self._slots[named] = slot
        self.wereSlotsLaidOut = false
        }
        
    @discardableResult
    public func slot(_ name: String,_ klass: Class) -> Self
        {
        self.addSlot(named: name, class: klass)
        return(self)
        }
        
    @discardableResult
    public func slot(_ name: String,_ klass: Class,_ generics: Class...) -> Self
        {
        let newClass = klass.instanciateClass(with: generics)
        self.addSlot(named: name, class: newClass)
        return(self)
        }
        
    public func instanciateClass(with: Classes) -> Class
        {
        fatalError()
        }
        
    public func addSlot(named: String,class: Class)
        {
        self.addDynamicSlot(named: named,class: `class`)
        }
        
    private func layoutSlots()
        {
        self.laidOutSlots = Slots()
        var offset = 0
        self.layoutSlots(in: self,atOffset: &offset)
        self.wereSlotsLaidOut = true
        }
        
    private func layoutSlots(in someClass: Class,atOffset offset: inout Integer64)
        {
        for slot in self._staticSlots
            {
            let newSlot = slot.copy()
            var prefix = ""
            if someClass.name != self.name
                {
                prefix = "__" + self.name
                }
            newSlot.name = prefix + newSlot.name
            newSlot.byteOffset = offset
            offset += MemoryLayout<Integer64>.size
            someClass.laidOutSlots.append(newSlot)
            }
        self.superclass?.layoutSlots(in: someClass,atOffset: &offset)
        for slot in self._dynamicSlots
            {
            let newSlot = slot.copy()
            newSlot.byteOffset = offset
            offset += MemoryLayout<Integer64>.size
            someClass.laidOutSlots.append(newSlot)
            }
        }
        
    public func slotAtName(_ name: String) -> Slot?
        {
        self._slots[name]
        }
        
    public func writeInstance(_ value: any Instance,forSlotNamed name: String,into: RawPointer,atByteOffset: Integer64)
        {
        if !self.wereSlotsLaidOut
            {
            self.layoutSlots()
            }
        }
        
    public func hash(into hasher:inout Hasher)
        {
//        for slot in self.dynamicSlots
//            {
//            hasher.combine(self.value(ofSlot: slot))
//            }
        }
        
    public func allocateInstanceHandle() -> Integer64
        {
        let index = self.nextInstanceHandle
        self.nextInstanceHandle += 1
        return(index)
        }
        
    public func instanceValue(atPointer pointer: RawPointer) -> any Instance
        {
        ObjectFault(objectAddress: ObjectAddress(bitPattern: pointer.load(as: Unsigned64.self)))
        }
        
    public func setInstanceValue(_ value: any Instance,atPointer pointer: RawPointer)
        {
        pointer.storeBytes(of: value.objectAddress.address, as: Unsigned64.self)
        }
    }

extension Class
    {
    //
    // Convenience accessors for the Medusa classes
    //
    
    public static var objectClass: Class
        {
        (SystemDictionary.shared[Atom("Medusa")] as! SystemDictionary)[Atom("Object")] as! Class
        }
        
    public static var arrayClass: Class
        {
        (SystemDictionary.shared[Atom("Medusa")] as! SystemDictionary)[Atom("Array")] as! Class
        }
        
    public static var nothingClass: Class
        {
        (SystemDictionary.shared[Atom("Medusa")] as! SystemDictionary)[Atom("Nothing")] as! Class
        }
        
    public static var integer64Class: Class
        {
        (SystemDictionary.shared[Atom("Medusa")] as! SystemDictionary)[Atom("Integer64")] as! Class
        }
        
    public static var atomClass: Class
        {
        (SystemDictionary.shared[Atom("Medusa")] as! SystemDictionary)[Atom("Atom")] as! Class
        }
        
    public static var float64Class: Class
        {
        (SystemDictionary.shared[Atom("Medusa")] as! SystemDictionary)[Atom("Float64")] as! Class
        }
        
    public static var stringClass: Class
        {
        (SystemDictionary.shared[Atom("Medusa")] as! SystemDictionary)[Atom("String")] as! Class
        }
        
    public static var byteClass: Class
        {
        (SystemDictionary.shared[Atom("Medusa")] as! SystemDictionary)[Atom("Byte")] as! Class
        }
        
        
    public static var booleanClass: Class
        {
        (SystemDictionary.shared[Atom("Medusa")] as! SystemDictionary)[Atom("Boolean")] as! Class
        }
        
    public static var enumerationClass: Class
        {
        (SystemDictionary.shared[Atom("Medusa")] as! SystemDictionary)[Atom("Enumeration")] as! Class
        }
        
    public static var unicodeScalarClass: Class
        {
        (SystemDictionary.shared[Atom("Medusa")] as! SystemDictionary)[Atom("UnicodeScalar")] as! Class
        }
        
    public static var addressClass: Class
        {
        (SystemDictionary.shared[Atom("Medusa")] as! SystemDictionary)[Atom("Address")] as! Class
        }
        
    public static var headerClass: Class
        {
        (SystemDictionary.shared[Atom("Medusa")] as! SystemDictionary)[Atom("Header")] as! Class
        }
        
    public static var blockClass: Class
        {
        (SystemDictionary.shared[Atom("Medusa")] as! SystemDictionary)[Atom("Block")] as! Class
        }
        
    public static var bytesClass: Class
        {
        (SystemDictionary.shared[Atom("Medusa")] as! SystemDictionary)[Atom("Bytes")] as! Class
        }
        
    public static var unsigned64Class: Class
        {
        (SystemDictionary.shared[Atom("Medusa")] as! SystemDictionary)[Atom("Unsigned64")] as! Class
        }
        
    public static var objectHeaderClass: Class
        {
        (SystemDictionary.shared[Atom("Medusa")] as! SystemDictionary)[Atom("ObjectHeader")] as! Class
        }
        
    public static var classClass: Class
        {
        (SystemDictionary.shared[Atom("Medusa")] as! SystemDictionary)[Atom("Class")] as! Class
        }
        
    public static var objectHandleClass: Class
        {
        (SystemDictionary.shared[Atom("Medusa")] as! SystemDictionary)[Atom("ObjectHandle")] as! Class
        }
        
    public static var blockHeaderClass: Class
        {
        (SystemDictionary.shared[Atom("Medusa")] as! SystemDictionary)[Atom("BlockHeader")] as! Class
        }
        
    public static var metaclassClass: Class
        {
        (SystemDictionary.shared[Atom("Medusa")] as! SystemDictionary)[Atom("Metaclass")] as! Class
        }
        
    public static var dictionaryClass: Class
        {
        (SystemDictionary.shared[Atom("Medusa")] as! SystemDictionary)[Atom("Dictionary")] as! Class
        }
        
    public static var identityDictionaryClass: Class
        {
        (SystemDictionary.shared[Atom("Medusa")] as! SystemDictionary)[Atom("IdentityDictionary")] as! Class
        }
        
    public static var systemDictionaryClass: Class
        {
        (SystemDictionary.shared[Atom("Medusa")] as! SystemDictionary)[Atom("SystemDictionary")] as! Class
        }
        
    }

public class ObjectFault: Instance
{
    public static func == (lhs: ObjectFault, rhs: ObjectFault) -> Bool {
        fatalError()
    }
    
    public var description: String
    
    public var objectHandle: MedusaCore.ObjectHandle = ObjectHandle(bitPattern: 0)
    
    public var objectHash: MedusaCore.Integer64 = 0
    
    public var sizeInBytes: MedusaCore.Integer64 = 0
    
    public var _class: Any
    
    public var hasBytes: MedusaCore.Boolean
    
    public var isNothing: MedusaCore.Boolean
    
    public func write(into page: Any, atIndex: MedusaCore.Integer64) throws {
        fatalError()
    }
    
    public func write(into pointer: MedusaCore.RawPointer, atByteOffset: inout MedusaCore.Integer64) throws {
        fatalError()
    }
    
    public func writeKey(into pointer: MedusaCore.RawPointer, atByteOffset: inout MedusaCore.Integer64) throws {
        fatalError()
    }
    
    public func writeValue(into pointer: MedusaCore.RawPointer, atByteOffset: inout MedusaCore.Integer64) throws {
        fatalError()
    }
    
    public func pack(into buffer: MedusaCore.RawPointer, atByteOffset: inout MedusaCore.Integer64) throws {
        fatalError()
    }
    
    public func value(ofSlotAtKey: String) -> any MedusaCore.Instance {
        fatalError()
    }
    
    public func setValue(_ value: any Instance, ofSlotAtKey: String) {
        fatalError()
    }
    
    public func isEqual(to: Any) -> Bool {
        fatalError()
    }
    
    public func isLess(than: Any) -> Bool {
        fatalError()
    }
    
    public static func < (lhs: ObjectFault, rhs: ObjectFault) -> Bool {
        fatalError()
    }
    
    public var objectAddress: ObjectAddress
    
    public init(objectAddress: ObjectAddress)
        {
        fatalError()
        self.objectAddress = objectAddress
        }
        
    public func hash(into hasher:inout Hasher)
        {
        fatalError()
        }
    }

public typealias Classes = Array<Class>
    
public class GenericClass: Class
    {
    public override func instanciateClass(with: Classes) -> Class
        {
        let newName = name + "<" + with.map{$0.name}.joined(separator: ",") + ">"
        let newClass = GenericClassInstance(inMemoryNamed: newName, superclass: self.superclass)
        newClass.instanceHasBytes = self.instanceHasBytes
        newClass._staticSlots = self._staticSlots
        newClass._dynamicSlots = self._dynamicSlots
        newClass.nextInstanceHandle = self.nextInstanceHandle
        newClass.superOffsetAdjustment = self.superOffsetAdjustment
        newClass.laidOutSlots = Slots()
        newClass.wereSlotsLaidOut = false
        newClass.instanceClass = self.instanceClass
        newClass.generics = with
        return(newClass)
        }
    }
    
public class GenericClassInstance: Class
    {
    public var generics = Classes()
    }
