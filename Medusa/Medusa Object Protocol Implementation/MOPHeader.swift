//
//  MOPHeader.swift
//  Medusa
//
//  Created by Vincent Coetzee on 04/12/2023.
//

import Foundation

//    SIGN BIT    4 TAG BITS     TYPE
//    ===============================
//            1   000     Integer64            = 0     Copy
//            0   001     Float64              = 1     Copy
//            0   010     Atom                 = 2     Copy
//            0   011     Header               = 3     Copy
//            0   100     Object               = 4     Follow
//            0   101     Address              = 5     Follow
//            0   110     Enumeration          = 6     Follow
//            0   111     Nothing              = 7     Copy

//Object Structure
//
//            Header 64 Bits           Sign ( 1 bit )                   0                                                                          0   1
//                                     Tag ( 3 bits )                    000                                                                       1   4
//                                     SizeInWords ( 36 bits )              0000 00000000 00000000 00000000 0000000                                4  40
//                                     HasBytes ( 1 bit )                                                          0                              40  41
//                                     FlipCount ( 13 bits = 8191 )                                                  00000000 000000              41  54
//                                     IsForwarded ( 1 bit )                                                                        0             54  55
//                                     IsMarked   ( 1 bit )                                                                          0            55  56
//                                     Reserved ( 8 bits = 512 )                                                                       RESERVED   56  64

public class MOPHeader
    {
    public static let kSignMask: Unsigned64             = 0b10000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000 // 1 bit at at bit  63
    public static let kTagMask: Unsigned64              = 0b01110000_00000000_00000000_00000000_00000000_00000000_00000000_00000000 // 3 bits at bit    60
    public static let kSizeInWordsMask: Unsigned64      = 0b00001111_11111111_11111111_11111111_11111111_00000000_00000000_00000000 // 36 bits at bit   24
    public static let kIndexedMask: Unsigned64          = 0b00000000_00000000_00000000_00000000_00000000_10000000_00000000_00000000 // 1 bit at bit     23
    public static let kKeyedMask: Unsigned64            = 0b00000000_00000000_00000000_00000000_00000000_01000000_00000000_00000000 // 1 bit at bit     22
    public static let kFlipCountMask: Unsigned64        = 0b00000000_00000000_00000000_00000000_00000000_00111111_11111111_00000000 // 14 bits at bit    8
    public static let kForwardedMask: Unsigned64        = 0b00000000_00000000_00000000_00000000_00000000_00000000_00000000_10000000 // 1 bit at bit      7
    public static let kMarkedMask: Unsigned64           = 0b00000000_00000000_00000000_00000000_00000000_00000000_00000000_01000000 // 1 bit at bit      6
    
    public static let kSignBits: Unsigned64             = 0b1
    public static let kTagBits: Unsigned64              = 0b111
    public static let kSizeInWordsBits: Unsigned64      = 0b1111_11111111_11111111_11111111_11111111
    public static let kIndexedBits: Unsigned64          = 0b1
    public static let kKeyedBits: Unsigned64            = 0b1
    public static let kFlipCountBits: Unsigned64        = 0b1
    public static let kForwardedBits: Unsigned64        = 0b1
    public static let kMarkedBits: Unsigned64           = 0b111111_11111111
    
    public static let kSignOffset: Unsigned64           = 63
    public static let kTagOffset: Unsigned64            = 60
    public static let kSizeInWordsOffset: Unsigned64    = 24
    public static let kIndexedOffset: Unsigned64        = 23
    public static let kKeyedOffset: Unsigned64          = 22
    public static let kFlipCountOffset: Unsigned64      = 8
    public static let kForwardedOffset: Unsigned64      = 7
    public static let kMarkedOffset: Unsigned64         = 6
    
    public enum Tag: Unsigned64
        {
        case integer64   = 0b000
        case float64     = 0b001
        case atom        = 0b010
        case header      = 0b011
        case object      = 0b100
        case address     = 0b101
        case enumeration = 0b110
        case nothing     = 0b111
        }
        
    public var sign: Integer64
        {
        get
            {
            Integer64(self.word & Self.kSignMask >> Self.kSignOffset)
            }
        set
            {
            self.word = (self.word & ~Self.kSignBits) | (Unsigned64(newValue) & Self.kSignBits) << Self.kSignOffset
            }
        }
        
    public var tag: Tag
        {
        get
            {
            Tag(rawValue: self.word & Self.kTagMask >> Self.kTagOffset)!
            }
        set
            {
            self.word = (self.word & ~Self.kTagBits) | newValue.rawValue << Self.kTagOffset
            }
        }
        
    public var sizeInWords: Unsigned64
        {
        get
            {
            self.word & Self.kSizeInWordsMask >> Self.kSizeInWordsOffset
            }
        set
            {
            self.word = (self.word & ~Self.kSizeInWordsBits) | (Unsigned64(newValue) & Self.kSizeInWordsBits) << Self.kSizeInWordsOffset
            }
        }
        
    public var flipCount: Integer64
        {
        get
            {
            Integer64(self.word & Self.kFlipCountMask >> Self.kFlipCountOffset)
            }
        set
            {
            self.word = (self.word & ~Self.kFlipCountBits) | (Unsigned64(newValue) & Self.kFlipCountBits)  << Self.kFlipCountOffset
            }
        }
        
    public var isIndexed: Boolean
        {
        get
            {
            (self.word & Self.kIndexedMask) == Self.kIndexedMask
            }
        set
            {
            self.word = (self.word & ~Self.kIndexedBits) | (newValue ? Self.kIndexedBits << Self.kSizeInWordsOffset : 0)
            }
        }
        
    public var isKeyed: Boolean
        {
        get
            {
            (self.word & Self.kKeyedMask) == Self.kKeyedMask
            }
        set
            {
            self.word = (self.word & ~Self.kKeyedBits) | (newValue ? Self.kKeyedBits << Self.kKeyedOffset : 0)
            }
        }
        
    public var isForwarded: Boolean
        {
        get
            {
            (self.word & Self.kForwardedMask) == Self.kForwardedMask
            }
        set
            {
            self.word = (self.word & ~Self.kForwardedBits) | (newValue ? Self.kForwardedBits << Self.kForwardedOffset : 0)
            }
        }
        
    public var isMarked: Boolean
        {
        get
            {
            (self.word & Self.kMarkedMask) == Self.kMarkedMask
            }
        set
            {
            self.word = (self.word & ~Self.kMarkedBits) | (newValue ? Self.kMarkedBits << Self.kMarkedOffset : 0)
            }
        }
        
        
    private var word: Unsigned64
        {
        get
            {
            self._word.isNil ? self._pointer!.load(fromByteOffset: 0, as: Unsigned64.self) :  self._word!
            }
        set
            {
            if self._word.isNil
                {
                self._pointer?.storeBytes(of: newValue, toByteOffset: 0, as: Unsigned64.self)
                }
            else
                {
                self._word = newValue
                }
            }
        }
        
    private var _word: Unsigned64?
    private var _pointer: RawBuffer?
    
    public init(bitPattern: Unsigned64)
        {
        self._word = bitPattern
        }
        
    public init(pointer: RawBuffer)
        {
        self._pointer = pointer
        }
    }
