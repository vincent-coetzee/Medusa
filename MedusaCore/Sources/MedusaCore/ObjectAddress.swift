//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 10/12/2023.
//

import Foundation

public struct ObjectAddress: Hashable,Equatable
    {
    public static let kNothing = ObjectAddress(bitPattern: ObjectAddress.kNothingMask)
    
    private static let kSignMask: Unsigned64                    = 0b10000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    private static let kNothingMask: Unsigned64                 = 0b01000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    private static let kIsObjectMask: Unsigned64                = 0b00100000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    private static let kIsHeaderMask: Unsigned64                = 0b00010000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    private static let kPageOffsetMask: Unsigned64              = 0b00001111_11111111_11111111_11111111_11111111_11111111_11000000_00000000
    private static let kValueMask: Unsigned64                   = 0b00001111_11111111_11111111_11111111_11111111_11111111_11111111_11111111
    private static let kObjectIndexMask: Unsigned64             = 0b00000000_00000000_00000000_00000000_00000000_00000000_00111111_11111111
    
    private static let kFloat64Shift: Unsigned64                = 3
        
    public var address: Unsigned64 = 0
    
    public var isZero: Bool
        {
        self.address == 0
        }
        
    public var sign: Unsigned64
        {
        if self.address & Self.kSignMask == Self.kSignMask
            {
            return(Unsigned64(bitPattern: -1))
            }
        return(Unsigned64(bitPattern: 1))
        }
        
    public var isNothing: Boolean
        {
        get
            {
            self.address & Self.kNothingMask == Self.kNothingMask
            }
        set
            {
            self.address = (self.address & ~Self.kNothingMask) | (newValue ? Self.kNothingMask : 0)
            }
        }
        
    public var isHeader: Boolean
        {
        get
            {
            self.address & Self.kIsHeaderMask ==  Self.kIsHeaderMask
            }
        set
            {
            self.address = (self.address & ~Self.kIsHeaderMask) | (newValue ? Self.kIsHeaderMask : 0)
            }
        }
        
    public var isObject: Boolean
        {
        get
            {
            self.address & Self.kIsObjectMask ==  Self.kIsObjectMask
            }
        set
            {
            self.address = (self.address & ~Self.kIsObjectMask) | (newValue ? Self.kIsObjectMask : 0)
            }
        }
        
    public var bitsValue: Unsigned64
        {
        return(self.address & Self.kValueMask)
        }
        
    public var addressValue: Integer64
        {
        return(Integer64(bitPattern: self.address & Self.kValueMask))
        }
        
    public var headerValue: Header
        {
        get
            {
            Header(bitPattern: self.address & Self.kValueMask)
            }
        }
        
    public var booleanValue: Boolean
        {
        return(self.address & Self.kValueMask == 1)
        }
        
    public var byteValue: Byte
        {
        return(Byte(self.address & Self.kValueMask))
        }
        
    public var unicodeScalarValue: UnicodeScalar
        {
        return(UnicodeScalar(UInt32(self.address & Self.kValueMask))!)
        }
    
    public var pageOffset: Integer64
        {
        get
            {
            Integer64(bitPattern: self.address & Self.kPageOffsetMask)
            }
        set
            {
            self.address = (self.address & ~Self.kPageOffsetMask) | (Unsigned64(newValue) & Self.kPageOffsetMask)
            }
        }
        
    public var objectIndex: Integer64
        {
        get
            {
            Integer64(bitPattern: self.address & Self.kObjectIndexMask)
            }
        set
            {
            self.address = (self.address & ~Self.kObjectIndexMask) | (Unsigned64(newValue) & Self.kObjectIndexMask)
            }
        }
        
    public init(enumerationCaseIndex caseIndex: Integer64,classAddress: Unsigned64)
        {
//        self.init()
//        self.tag = .enumeration
//        self.address = (self.address & ~Self.kAssociatedValuesFlagMask)
//        self.address = (self.address & ~Self.kCaseIndexMask) & ((Unsigned64(caseIndex) & Self.kCaseIndexBits) << Self.kCaseIndexShift)
//        self.address = (self.address & ~Self.kAddressMask) | (classAddress & ~Self.kAddressMask)
        fatalError()
        }
        
    public init(pageOffset: Integer64,objectIndex: Integer64)
        {
        self.address = Unsigned64(bitPattern: pageOffset) | Unsigned64(objectIndex) | Self.kIsObjectMask
        }
        
    public init(bitPattern: Unsigned64)
        {
        self.address = bitPattern
        }
        
    public init(_ integer64: Integer64)
        {
        self.address = UInt64(bitPattern: integer64)
        }
        
    public init(_ float: Float64)
        {
        var value = UInt64(float.bitPattern)
        let signBit = value & Self.kSignMask
        value = (value & ~Self.kSignMask) >> Self.kFloat64Shift
        self.address = value | signBit
        }
        
    public init(_ boolean: Boolean)
        {
        self.address = Unsigned64(boolean ? 1 : 0)
        }
        
    public init(_ byte: Byte)
        {
        self.address = (Unsigned64(byte) & Self.kValueMask)
        }
        
    public init(_ unicodeScalar: UnicodeScalar)
        {
        self.address = (Unsigned64(unicodeScalar) & Self.kValueMask)
        }
        
    public init(address integer: Integer64)
        {
        self.address = (Unsigned64(integer) & Self.kValueMask)
        }
        
    public init(bits: Unsigned64)
        {
        self.address = (bits & Self.kValueMask)
        }
        
    public init(header: Header)
        {
        self.address = (header.word | Self.kIsHeaderMask)
        }
        
    public func hash(into hasher:inout Hasher)
        {
        hasher.combine(self.address)
        }
        
    public static func ==(lhs: ObjectAddress,rhs: ObjectAddress) -> Bool
        {
        lhs.address == rhs.address
        }
    }
