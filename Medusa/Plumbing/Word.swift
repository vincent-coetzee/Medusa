//
//  Word.swift
//  Medusa
//
//  Created by Vincent Coetzee on 25/11/2023.
//

import Foundation

//    SIGN BIT    4 TAG BITS     TYPE
//    ===============================
//            1   0000     Integer              = 0
//            0   0001     Object               = 1
//            0   0010     Tuple                = 2
//            0   0011     Boolean              = 3
//            0   0100     String               = 4
//            0   0101     Float16              = 5
//            0   0110     Float32              = 6
//            0   0111     Float64              = 7
//            0   1000     Emnumeration         = 8
//            0   1001     Address              = 9
//            0   1010     Header               = 10
//            0   1011     Bits                 = 11
//            0   1100     Atom                 = 12
//            0   1101     Array                = 13
//            0   1110     Persistent           = 14
//            0   1111     zilch                = 15

public typealias Word = UInt64

public enum Tag: Word
    {
    public static let kTagShift: Word     = 59
    public static let kSignShift: Word    = 63
    public static let kTagBits: Word      = 0b1111 << Tag.kTagShift
    public static let kSignBits: Word     = 0b1 << Tag.kSignShift
    
    case integer        = 0b00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    case object         = 0b00001000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    case tuple          = 0b00010000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    case boolean        = 0b00011000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    case string         = 0b00100000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    case float16        = 0b00101000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    case float32        = 0b00110000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    case float64        = 0b00111000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    case enumeration    = 0b01000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    case address        = 0b01001000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    case header         = 0b01010000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    case bits           = 0b01011000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    case atom           = 0b01100000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    case array          = 0b01101000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    case persistent     = 0b01110000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    case zilch          = 0b01111000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    }
    
extension Word
    {
    public var tag: Tag
        {
        get
            {
            Tag(rawValue: (self & Tag.zilch.rawValue))!
            }
        set
            {
            self = (self & ~Tag.kTagBits) | newValue.rawValue
            }
        }
        
    public init(bitPattern: Int)
        {
        self = UInt64(Int64(bitPattern.magnitude)) | (bitPattern.signum() == -1 ? Word(1) : Word(0)) << Tag.kSignShift
        }
        
    public init(object: Int)
        {
        let address = Word(object.magnitude) & ~Tag.kTagBits
        self = Tag.object.rawValue | address
        }
        
    public init(boolean: Bool)
        {
        let value = Word(boolean ? 1 : 0) & ~Tag.kTagBits
        self = Tag.boolean.rawValue | value
        }
        
    public init(enumeration: Int)
        {
        let value = Word(enumeration.magnitude) & ~Tag.kTagBits
        self = Tag.enumeration.rawValue | value
        }
        
    public var payload: Int
        {
        let remainder = Int(self & ~Tag.kSignBits & ~Tag.kTagBits)
        return(self & Tag.kSignBits == Tag.kSignBits ? -remainder : remainder)
        }
        
    public var sign: Int
        {
        self & Tag.kSignBits == Tag.kSignBits ? -1 : 1
        }
    }
