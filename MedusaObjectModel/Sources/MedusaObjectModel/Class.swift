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
    // Instance variables for Class
    private var _slots = Dictionary<Atom,Slot>()
    private var nextSlotOffset: Integer64 = MemoryLayout<Integer64>.size + MemoryLayout<Unsigned64>.size // header size + class pointer size
    
    // perhaps should create a Cache class and use that here in place of the Dictionary because it can have extra logic
    private static var classCache = Dictionary<Unsigned64,Class>()
    
    //
    // Constants defined for use in the class
    //
    public static let kSlotOffset: Integer64 = MemoryLayout<Integer64>.size
    //
    // Convenience accessors for the Medusa classes
    //
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
        
    public static func `class`(atPointer: Unsigned64) -> Class
        {
//        if let someClass = Self.classCache[atPointer]
//            {
//            return(someClass)
//            }
//        let newClass = Class(pointer: atPointer)
//        Self.classCache[atPointer] = newClass
//        return(newClass)
        fatalError()
        }
    
    public var slots: Slots
        {
        Array(self._slots.values)
        }
        
//    public init(pointer: Pointer)
//        {
//        fatalError()
//        }
        
    public func slotAtKey(_ atom: Atom) -> Slot?
        {
        self._slots[atom]
        }
        
    public func slotAtName(_ name: String) -> Slot?
        {
        self._slots[Atom(name)]
        }
        
    public func addSlot(named: String,class: Class,atByteOffset: Integer64)
        {
        let nameAtom = Atom(named)
        self._slots[nameAtom] = Slot(name: named, class: `class`, atByteOffset: self.nextSlotOffset)
        self.nextSlotOffset += MemoryLayout<Integer64>.size
        }
        
    public func decodeInstance(from: RawPointer,atByteOffset: Integer64) -> Instance
        {
        fatalError()
        }
        
    public func readInstance(from: RawPointer,atByteOffset:inout Integer64) -> Instance
        {
        fatalError()
        }
        
    public func encode(_ instance: Instance,into page: Page,atByteOffset:inout Integer64)
        {
//        if let primitive = instance as? Primitive
//            {
//            switch(primitive.primitiveValue)
//                {
//                case(.atom(let integer)):
//                    writeInteger64WithOffset(rawPointer,integer,&atByteOffset)
//                case(.object(let pointer)):
//                    writeInteger64WithOffset(rawPointer,pointer,&atByteOffset)
//                case(.nothing):
//                    writeInteger64WithOffset(rawPointer,&atByteOffset)
//                case(.integer64(let integer)):
//                    writeInteger64WithOffset(rawPointer,integer,&atByteOffset)
//                case(.float64(let float)):
//                    writeFloat64WithOffset(rawPointer,float,&atByteOffset)
//                case(.string(let momString)):
//                    writeInteger64WithOffset(rawPointer,momString.objectID,&atByteOffset)
//                case(.boolean(let boolean)):
//                    writeInteger64WithOffset(rawPointer,boolean ? 1 : 0,&atByteOffset)
//                case(.byte(let byte)):
//                    writeInteger64WithOffset(rawPointer,Integer64(bitPattern: byte),&atByteOffset)
//                }
//            }
        }
    }
