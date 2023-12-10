//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 10/12/2023.
//

import Foundation

public struct ObjectAddress
    {
    public static let kNothing = ObjectAddress(bitPattern: ObjectAddress.kIsNothingMask)
    
    private static let kSignMask: Unsigned64                    = 0b10000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    private static let kIsFollowedMask: Unsigned64              = 0b01000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    private static let kFlagsMask: Unsigned64                   = 0b01110000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    private static let kIsHeaderMask: Unsigned64                = 0b00100000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    private static let kIsNothingMask: Unsigned64               = 0b00010000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    private static let kPageOffsetMask: Unsigned64              = 0b00001111_11111111_11111111_11111111_11111111_11111111_11000000_00000000
    private static let kObjectIndexMask: Unsigned64             = 0b00000000_00000000_00000000_00000000_00000000_00000000_00111111_11111111
    private static let kValueMask: Unsigned64                   = 0b10001111_11111111_11111111_11111111_11111111_11111111_11111111_11111111
    private static let kFloat64ValueShift: Unsigned64           = 2
            
    public var address: Unsigned64 = 0
    
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
        self.address & Self.kIsNothingMask == Self.kIsNothingMask
        }
        
    public var float64Value: Float64
        {
        let valueSign = self.sign
        var value = (self.address & ~Self.kSignMask) << Self.kFloat64ValueShift
        value |= valueSign
        return(Float64(bitPattern: value))
        }
        
    public var integer64Value: Integer64
        {
        return(Integer64(bitPattern: self.address & Self.kValueMask))
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
        self.address = Self.kIsFollowedMask | Unsigned64(bitPattern: pageOffset) | Unsigned64(objectIndex)
        }
        
    public init(bitPattern: Unsigned64)
        {
        self.address = bitPattern
        }
        
    public init(_ integer64: Integer64)
        {
        self.address = UInt64(bitPattern: Int64(integer64)) & ~Header.kTagMask | Header.kInteger64Mask
        }
        
    public init(_ float: Float64)
        {
        var value = UInt64(float.bitPattern)
        let signBit = value & Self.kSignMask
        value = (value & ~Self.kSignMask) >> Self.kFloat64ValueShift
        self.address = (value & ~Self.kFlagsMask) | signBit
        }
        
    public init(_ boolean: Boolean)
        {
        self.address = Unsigned64(boolean ? 1 : 0) & ~Self.kFlagsMask
        }
        
    public init(_ byte: Byte)
        {
        self.address = (Unsigned64(byte) & Self.kValueMask) & ~Self.kFlagsMask
        }
        
    public init(_ unicodeScalar: UnicodeScalar)
        {
        self.address = (Unsigned64(unicodeScalar) & Self.kValueMask) & ~Self.kFlagsMask
        }
    }
