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

open class Class: Object
    {
    private static let kHeaderSlotOffset        = 0
    private static let kClassSlotOffset         = Class.kHeaderSlotOffset + MemoryLayout<Integer64>.size
    private static let kHandleSlotOffset        = Class.kClassSlotOffset + MemoryLayout<Integer64>.size
    private static let kHashSlotOffset          = Class.kHandleSlotOffset + MemoryLayout<Integer64>.size
    private static let kFirstInstanceSlotOffset = Class.kHashSlotOffset + MemoryLayout<Integer64>.size
    
    private static let kFixedSizeInBytes        = Class.kFirstInstanceSlotOffset
    
    public var slotNames: Array<String>
        {
        self._slots.values.map{$0.name}
        }
        
    // Instance variables for Class
    public var systemSlots: Slots
        {
        Array(self._slots.values.filter{$0.isSystemSlot})
        }
        
    public var instanceSlots: Slots
        {
        Array(self._slots.values.filter{!$0.isSystemSlot})
        }
        
    public var instanceSizeInBytes: Integer64
        {
        self._slots.count * MemoryLayout<Integer64>.size
        }
        
    public var  isInstanceIndexed: Boolean
    private var nextSlotOffset: Integer64 = Class.kFirstInstanceSlotOffset
    private var _slots = Dictionary<String,Slot>()
    public let name: String
    public var superclasses = Array<Class>()
    
    // perhaps should create a Cache class and use that here in place of the Dictionary because it can have extra logic
    private static var classCache = Dictionary<Unsigned64,Class>()
    
    //
    // Constants defined for use in the class
    //
    public static let kSlotOffset: Integer64 = MemoryLayout<Integer64>.size
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
        
    private static let kObjectHeaderSlotName              = "__headerSlot"
    private static let kObjectClassSlotName               = "__classSlot"
    private static let kObjectHandleSlotName              = "__handleSlot"
    private static let kObjectHashSlotName                = "__hashSlot"
    private static let kObjectBlockHeaderSlotName         = "__blockHeaderSlot"
    private static let kObjectNextBlockAddressSlotName    = "__nextBlockAddressSlot"
    
    public static let kInitialBlockSlotCount             =  64
        
    public init(name: String,superclasses: Array<Class> = [],isInstanceIndexed: Boolean = false)
        {
        self.superclasses = superclasses
        self.name = name
        self.isInstanceIndexed = isInstanceIndexed
        super.init(ofClass: Self.metaclassClass)
        self.addSlot(named: Self.kObjectHeaderSlotName,class: Class.objectHeaderClass,isSystemSlot: true)
        self.addSlot(named: Self.kObjectClassSlotName,class: Class.classClass,isSystemSlot: true)
        self.addSlot(named: Self.kObjectHashSlotName,class: Class.integer64Class,isSystemSlot: true)
        self.addSlot(named: Self.kObjectHandleSlotName,class: Class.objectHandleClass,isSystemSlot: true)

        if isInstanceIndexed
            {
            self.addSlot(named: Self.kObjectBlockHeaderSlotName,class: Class.blockHeaderClass,isSystemSlot: true)
            self.addSlot(named: Self.kObjectNextBlockAddressSlotName,class: Class.addressClass,isSystemSlot: true)
            }
        }
        
    public func slotAtName(_ name: String) -> Slot?
        {
        self._slots[name]
        }
        
    public func addSlot(named name: String,class: Class,isSystemSlot: Boolean = false)
        {
        self._slots[name] = Slot(name: name, class: `class`, atByteOffset: self.nextSlotOffset,isSystemSlot: isSystemSlot)
        self.nextSlotOffset += MemoryLayout<Integer64>.size
        }
        
    public func writeInstance(_ value: any Instance,forSlotNamed name: String,into: RawPointer,atByteOffset: Integer64)
        {
        guard let slot = self._slots[name] else
            {
            fatalError("Invalid slot name. \(#file) \(#function):\(#line).")
            }
//        slot.class.writeInstance
        }
        
    public override func hash(into hasher:inout Hasher)
        {
        for slot in self.instanceSlots
            {
            hasher.combine(self.value(ofSlot: slot))
            }
        }
    }

public class MetaclassClass: Class
    {
    private static let kClassSlotsSlotName      = "slots"
    private static let kClassNameSlotName       = "name"
    private static let kClassIsIndexedSlotName  = "isIndexed"
    
    public init(name: String)
        {
        super.init(name: name,isInstanceIndexed: false)
        self.addSlot(named: Self.kClassNameSlotName, class: .stringClass)
        self.addSlot(named: Self.kClassSlotsSlotName, class: .arrayClass)
        self.addSlot(named: Self.kClassIsIndexedSlotName, class: .booleanClass)
        }
    }
