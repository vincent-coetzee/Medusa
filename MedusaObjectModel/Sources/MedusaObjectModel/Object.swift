//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 05/12/2023.
//

import Foundation

import Foundation
import MedusaCore
import MedusaStorage
import MedusaPaging

//
//
// Objects in pages are laid out as follows
//
//
//          Header:  ( see Header struct for specifics ) -> 8 bytes
//          Class pointer: ObjectAddress that points to the class of this object -> 8 bytes
//          ObjectHandle: ObjectHandle that uniquely identifies this object in the database. If two objects are copies of the same object, the ObjectHandles will always be identical. -> 8 bytes
//          HashValue: Integer64 hash value for this object, it's a function of the values of all the slots in this object -> 8 bytes
//          Slot 0 -> 8 bytes per slot, slots contain either pritimive values or the ObjectAddress of an object
//          ...
//          ...
//          ...
//          Slot N
//          Block pointer: ObjectAddress of the first CollectionBlock for this object if and only if this object is an instance of or instance of a sublcass of MOMCollection ( i.e. Argon Collection class )
//
//
open class Object: Instance
    {
    public static let kHeaderOffset             = 0
    public static let kClassAddressOffset       = Object.kHeaderOffset + MemoryLayout<Integer64>.size
    public static let kHandleOffset             = Object.kClassAddressOffset + MemoryLayout<Integer64>.size
    public static let kHashOffset               = Object.kHandleOffset + MemoryLayout<Integer64>.size
    
    public var hasBytes: Boolean
        {
        self.class.instanceHasBytes
        }
        
    public var isNothing: Boolean
        {
        false
        }
    
    public var description: String
        {
        fatalError()
        }
        
    public var _class: Any = ObjectAddress.kNothing
    
    
    public func isEqual(to: Any) -> Bool {
                fatalError()    
    }
    
    public func isLess(than: Any) -> Bool {
                fatalError()    
    }
    
    public var objectAddress: ObjectAddress = ObjectAddress.kNothing
    
    public var objectIndex: Integer64
        {
        self.objectAddress.objectIndex
        }
        
    public var classAddress: ObjectAddress
        {
        ObjectAddress(bitPattern: self.pointer.load(fromByteOffset: Self.kClassAddressOffset, as: Unsigned64.self))
        }
        
    public var sizeInBytes: Integer64
        {
        self.class.instanceSizeInBytes
        }
        
    public var header: Header
        {
        Header(pointer: self.pointer)
        }
        
    public var objectHash: Integer64
        {
        self.pointer.load(fromByteOffset: Self.kHashOffset, as: Integer64.self)
        }
        
    public var objectHandle: ObjectHandle
        {
        ObjectHandle(bitPattern: self.pointer.load(fromByteOffset: Self.kHashOffset, as: Unsigned64.self))
        }
        
    public private(set) var pointer: RawPointer!
    private var buffer: RawPointer?
    private var ownsBuffer = false
    
    public init(inMemorySizeInBytes: Integer64)
        {
        self.buffer = RawPointer.allocate(byteCount: inMemorySizeInBytes, alignment: 1)
        self.ownsBuffer = true
        self.pointer = buffer!
        }
        
    public init(objectAddress: ObjectAddress,pointer: RawPointer)
        {
        self.objectAddress = objectAddress
        self.pointer = pointer
        self._class = Nothing.kNothing
        }
        
    deinit
        {
        if self.ownsBuffer
            {
            self.buffer?.deallocate()
            }
        }
        
    public init(address: ObjectAddress)
        {
        self.objectAddress = address
        
        }
        
    public static func ==(lhs: Object,rhs: Object) -> Bool
        {
        false
        }
        
    public static func <(lhs: Object,rhs: Object) -> Bool
        {
        false
        }
        
    public func hash(into hasher:inout Hasher)
        {
        for slot in self.class.dynamicSlots
            {
            hasher.combine(self.value(ofSlot: slot))
            }
        }
        
    public func value(ofSlot slot: Slot) -> any Instance
        {
        slot.value(in: self.pointer)
        }
        
    public func value(ofSlotNamed name: String) -> any Instance
        {
        self.class.slotAtName(name)!.value(in: self.pointer)
        }
        
    public func value(ofSlotAtKey: String) -> any Instance
        {
        Nothing.kNothing
        }
        
    public func setValue(_ value: any Instance,ofSlotAtKey: String)
        {
        }
        
    public func write(into somePage: Any, atIndex: MedusaCore.Integer64) throws
        {
        let page = somePage as! ObjectPage
        var offset = page.objectOffset(at: atIndex)
        var pointer = page.buffer + offset
        let header = Header(pointer: pointer)
        pointer += MemoryLayout<Integer64>.size
        var address = self.class.objectAddress
        if address.isNothing
            {
            let wrangler = Thread.current.threadDictionary["ObjectWrangler"] as! ObjectWrangler
            address = wrangler.store(self.class)
            }
        pointer.storeBytes(of: self.class.objectAddress.address, as: Unsigned64.self)
        pointer += MemoryLayout<Integer64>.size
        pointer.storeBytes(of: self.objectHandle.handle, as: Unsigned64.self)
        pointer += MemoryLayout<Integer64>.size
        pointer.storeBytes(of: self.objectHandle.handle, as: Unsigned64.self)
        for slot in self.class.dynamicSlots
            {
            slot.writeValue(from: self.buffer!,into: pointer)
            }
        }
    
    public func write(into pointer: MedusaCore.RawPointer, atByteOffset: inout MedusaCore.Integer64) throws{
        
    }
    
    public func writeKey(into pointer: MedusaCore.RawPointer, atByteOffset: inout MedusaCore.Integer64) throws {
        
    }
    
    public func writeValue(into pointer: MedusaCore.RawPointer, atByteOffset: inout MedusaCore.Integer64) throws {
        
    }
    
    public func pack(into buffer: MedusaCore.RawPointer, atByteOffset: inout MedusaCore.Integer64) throws{
        
    }
    }

