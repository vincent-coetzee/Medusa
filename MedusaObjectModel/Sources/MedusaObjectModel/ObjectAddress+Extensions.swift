//
//  File 2.swift
//  
//
//  Created by Vincent Coetzee on 06/12/2023.
//

import Foundation
import MedusaCore
import Fletcher

extension ObjectAddress
    {
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
                let object = Object(from: RawPointer(bitPattern: rawBits)!, atByteOffset: 0)
                return(object.class)
            case(Header.Tag.enumeration.rawValue):
                let rawBits = UInt(self.address & ~Header.kTagBits)
                let object = Enumeration(from: RawPointer(bitPattern: rawBits)!, atByteOffset: 0)
                return(object.class)
            case(Header.Tag.associatedEnumeration.rawValue):
                let rawBits = UInt(self.address & ~Header.kTagBits)
                let object = Enumeration(from: RawPointer(bitPattern: rawBits)!, atByteOffset: 0)
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
        
    public init(_ enumeration: Enumeration)
        {
        self.address = enumeration.wordValue & ~Header.kTagMask | Header.kEnumerationMask
        }
        
    public init(_ object: Object)
        {
        self.address = object.wordValue & ~Header.kTagMask | Header.kObjectMask
        }
        
    public init(_ integer64: Integer64)
        {
        self.address = UInt64(bitPattern: Int64(integer64)) & ~Header.kTagMask | Header.kInteger64Mask
        }
        
    public init(_ float: Float64)
        {
        self.address = float.bitPattern & ~Header.kTagMask | Header.kFloat64Mask
        }
        
    public init(_ boolean: Boolean)
        {
        self.address = UInt64(boolean ? 1 : 0) & ~Header.kTagMask | Header.kBooleanMask
        }
        
    public init(_ byte: Byte)
        {
        self.address = UInt64(byte) & ~Header.kTagMask | Header.kBooleanMask
        }
        
    public init(_ unicodeScalar: UnicodeScalar)
        {
        self.address = UInt64(unicodeScalar) & ~Header.kTagMask | Header.kUnicodeScalarMask
        }
    }
