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
// ObjectAddress is declared as a C struct because we pass it back and forth between Swift and C.
// Structs are easier to handle in C when it comes to encoding and decoding because C does not
// impose the safety rules that Swift does. We extend this struct here to add convenience behaviour.
//
extension ObjectAddress
    {
    private static let kAssociatedValuesFlagShift: Unsigned64   = 58
    private static let kAssociatedValuesFlagMask: Unsigned64    = 0b00000100_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    private static let kPageAddressMask: Unsigned64             = 0b00000011_11111111_11111111_11111111_11111111_11111111_11000000_00000000
    private static let kTagMask: Unsigned64                     = 0b01111000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    private static let kAddressMask: Unsigned64                 = 0b00000011_11111111_11111111_11111111_11111111_11111111_11111111_11111111
    private static let kIndexMask: Unsigned64                   = 0b00000000_00000000_00000000_00000000_00000000_00000000_00111111_10000000
    public static let kIndexShift: Unsigned64                   = 7
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
