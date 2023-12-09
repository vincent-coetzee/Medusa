//
//  File 2.swift
//  
//
//  Created by Vincent Coetzee on 06/12/2023.
//

import Foundation
import MedusaCore
import MedusaStorage
import Fletcher

//
//
// WHY ObjectAddress IS A C STRUCT
// ===============================
//
// ObjectAddress is declared as a C struct because we pass it back and forth between Swift and C.
// Structs are easier to handle in C when it comes to encoding and decoding because C does not
// impose the safety rules that Swift does. We extend this struct here to add convenience behaviour.
//
//
// OBJECT ADDRESSES AND TAGGING
// ============================
//
// An object address is a tagged integer. The top bit of the address is reserved for the sign bit and it is
// never used by Medusa so that Swift can set is as needed. There is a 4 bit tag at bit 59 which inidcates the type of
// the value in the remianing bits of the integer. Tags are listed in the MedusaCore.Header file. According to the
// tag, the value can be an integer64, a float64, a boolean, an enumeration value, a byte, a unicode scalar, an instance of
// nothing, an atom or a pointer to an object. The tags are very important when it comes to the Garbage Collector because the
// tag on a slot tells the GC what to do with the slot. If the tag is an object or an enumeration with associated values,
// the GC will follow the pointer contained in the slot amd recursivey copy all it's slots and so on. If the tag indicates
// that the value is a scalar of some sort ( i.e. not an object or enumeration pointer ) then it will merely copy the
// slot value to wherever it's writing to at that point in time. If an object or enumeration value is followed, the GC
// will leave the header of the object or enumeration instance intact but it will flip the isForwarded bit on and write
// the new address of the followed and copied object into the old object's class slot. This allows object references to be
// updated later as and when they are referenced rather than having to go around and change all the references every time it copies an object
// - apart from the fact it would be hideously complex and time consuming to track all the references to an object unless an extra
// level of indirection was introduced by means of an object table of some sort. We don't want an object table because we want
// our object handles to be actual pointers to the objects themselves not some arbitary value that has to look up an address
// before it can do anything.
//
// HOW OBJECT POINTERS/ADDRESSES WORK
// ==================================
//
// In the case of an object or enumeration pointer, the value ( sans sign bit and tag ) in the slot contains an object pointer.
// In Medusa's case the object pointer consists of a 40 bit page address which is the address in the data file of the page
// that contains this object and an 8 bit object index which is the index of the object in the page. We want to be able to rewrite
// object pages when a page needs to be defragmented and the page is short on space, that means we need a way of locating the object in a
// page that does not change even if the object is rewritted within the page. We achieve this by having a "catalogue" of the objects in
// an ObjectPage that has a slot for every object stored on the page with the offset of the object from the start of the page. We then use
// the index of the slot as the object locator within the page. We store the object slot index rather than the offset of the object
// in the object pointer. When we need to access an object we load the page using the page offset in the pointer/address, then we load the offset of the
// object within the page by retrieving the offset of the object from the "catalogue" according to the index stored in the address/pointer.
// This means we can safeky rewrite an object in the page by updating the offset stored in the slot indexed by the index stored in the
// address/pointer.
//
//
///
extension ObjectAddress
    {
    private static let kAssociatedValuesFlagShift: Unsigned64   = 58
    private static let kAssociatedValuesFlagMask: Unsigned64    = 0b00000100_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    private static let kPageAddressMask: Unsigned64             = 0b00000000_00000000_11111111_11111111_11111111_11111111_11111111_00000000
    private static let kObjectIndexMask: Unsigned64             = 0b00000000_00000000_00000000_00000000_00000000_00000000_00000000_11111111
    private static let kTagMask: Unsigned64                     = 0b01111000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    private static let kAddressMask: Unsigned64                 = 0b00000011_11111111_11111111_11111111_11111111_11111111_11111111_11111111
    public static let kObjectIndexShift: Unsigned64             = 0
    private static let kCaseIndexBits: Unsigned64               = 0b11111111
    private static let kCaseIndexShift: Unsigned64              = 50
    private static let kCaseIndexMask: Unsigned64               = 0b00000011_11111100_00000000_00000000_00000000_00000000_00000000_00000000
    private static let kSignMask: Unsigned64                    = 1 << 63
    private static let kInteger64Mask: Unsigned64               = 0b10000111_11111111_11111111_11111111_11111111_11111111_11111111_11111111
    private static let kBooleanMask: Unsigned64                 = 0b00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000001
    private static let kByteMask: Unsigned64                    = 0b00000000_00000000_00000000_00000000_00000000_00000000_00000000_11111111
    private static let kUnicodeScalarMask: Unsigned64           = 0b00000000_00000000_00000000_00000000_11111111_11111111_11111111_11111111
            
    public var float64Value: Float64
        {
        let signBit = self.address & Self.kSignMask
        var rawValue = self.address & ~Self.kTagMask * ~Self.kSignMask
        rawValue = rawValue << 4 | signBit
        return(Float64(bitPattern: rawValue))
        }
        
    public var integer64Value: Integer64
        {
        return(Integer64(bitPattern: self.address & Self.kInteger64Mask))
        }
        
    public var booleanValue: Boolean
        {
        return(self.address & Self.kBooleanMask == 1)
        }
        
    public var byteValue: Byte
        {
        return(Byte(self.address & Self.kByteMask))
        }
        
    public var unicodeScalarValue: UnicodeScalar
        {
        return(UnicodeScalar(UInt32(self.address & Self.kUnicodeScalarMask))!)
        }
        
    public var enumerationValue: Instance
        {
        fatalError("Not yet implemented.")
        }
        
    public var pageAddress: Integer64
        {
        get
            {
            Integer64(bitPattern: self.address & Self.kPageAddressMask)
            }
        set
            {
            self.address = (self.address & ~Self.kPageAddressMask) | (Unsigned64(newValue) & Self.kPageAddressMask)
            }
        }
        
    public var objectIndex: Integer64
        {
        get
            {
            Integer64(bitPattern: self.address & Self.kIndexMask >> Self.kIndexShift)
            }
        set
            {
            self.address = (self.address & ~Self.kIndexMask) | ((Unsigned64(newValue) << Self.kIndexShift) & Self.kIndexMask)
            }
        }
        
    public var tag: Header.Tag
        {
        get
            {
            Header.Tag(rawValue: self.address & Header.kTagBits >> Header.kTagOffset)!
            }
        set
            {
            self.address = (self.address & ~Header.kTagBits) | newValue.rawValue << Header.kTagOffset
            }
        }
        
    public var elementClass: Class?
        {
        if self.tag != .object
            {
            return(nil)
            }
        return(nil)
//        let objectClass = ObjectPage(atAddress: self.pageAddress).object(atIndex: self.objectIndex)
        }
        
    public var `class`: Class
        {
        switch(self.address & Header.kTagBits >> Header.kTagOffset)
            {
            case(Header.Tag.integer64.rawValue):
                return(Class.integer64Class)
            case(Header.Tag.float64.rawValue):
                return(Class.float64Class)
            case(Header.Tag.boolean.rawValue):
                return(Class.booleanClass)
            case(Header.Tag.byte.rawValue):
                return(Class.byteClass)
            case(Header.Tag.atom.rawValue):
                return(Class.atomClass)
            case(Header.Tag.object.rawValue):
                let rawBits = UInt(self.address & ~Header.kTagBits)
                var offset = 0
                let object = Object(from: RawPointer(bitPattern: rawBits)!, atByteOffset: &offset)
                return(object.class)
            case(Header.Tag.enumeration.rawValue):
                let rawBits = UInt(self.address & ~Header.kTagBits)
                var offset = 0
                let object = Enumeration(from: RawPointer(bitPattern: rawBits)!, atByteOffset: &offset)
                return(object.class)
            case(Header.Tag.associatedEnumeration.rawValue):
                let rawBits = UInt(self.address & ~Header.kTagBits)
                var offset = 0
                let object = Enumeration(from: RawPointer(bitPattern: rawBits)!, atByteOffset: &offset)
                return(object.class)
            case(Header.Tag.unicodeScalar.rawValue):
                return(Class.unicodeScalarClass)
            case(Header.Tag.address.rawValue):
                return(Class.addressClass)
            case(Header.Tag.header.rawValue):
                return(Class.headerClass)
            case(Header.Tag.nothing.rawValue):
                return(Class.nothingClass)
            default:
                fatalError("This should not happen.")
            }
        }
        
    public init(enumerationInstanceAddress someAddress: ObjectAddress)
        {
        self.init()
        self.tag = .enumeration
        self.address = (self.address | Self.kAssociatedValuesFlagMask) | (someAddress.address & Self.kAddressMask)
        }
        
    public init(enumerationCaseIndex caseIndex: Integer64,classAddress: Unsigned64)
        {
        self.init()
        self.tag = .enumeration
        self.address = (self.address & ~Self.kAssociatedValuesFlagMask)
        self.address = (self.address & ~Self.kCaseIndexMask) & ((Unsigned64(caseIndex) & Self.kCaseIndexBits) << Self.kCaseIndexShift)
        self.address = (self.address & ~Self.kAddressMask) | (classAddress & ~Self.kAddressMask)
        }
        
    public init(_ enumeration: Enumeration)
        {
//        self.address = enumeration.wordValue & ~Header.kTagMask | Header.kEnumerationMask
        fatalError()
        }
        
    public init(_ object: Object)
        {
//        self.address = object.wordValue & ~Header.kTagMask | Header.kObjectMask
        fatalError()
        }
        
    public init(_ integer64: Integer64)
        {
        self.init()
        self.address = UInt64(bitPattern: Int64(integer64)) & ~Header.kTagMask | Header.kInteger64Mask
        }
        
    public init(_ float: Float64)
        {
        self.init()
        var value = UInt64(float.bitPattern)
        let signBit = value & Self.kSignMask
        value = (value & ~Self.kSignMask & Self.kTagMask) >> 4
        self.address = (value & ~Header.kTagMask) | Header.kFloat64Mask | signBit
        }
        
    public init(_ boolean: Boolean)
        {
        self.init()
        self.address = UInt64(boolean ? 1 : 0) & ~Header.kTagMask | Header.kBooleanMask
        }
        
    public init(_ byte: Byte)
        {
        self.init()
        self.address = UInt64(byte) & ~Header.kTagMask | Header.kBooleanMask
        }
        
    public init(_ unicodeScalar: UnicodeScalar)
        {
        self.init()
        self.address = UInt64(unicodeScalar) & ~Header.kTagMask | Header.kUnicodeScalarMask
        }
    }
