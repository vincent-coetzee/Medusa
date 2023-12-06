//
//  Header.swift
//  
//
//  Created by Vincent Coetzee on 06/12/2023.
//

import Foundation

//    SIGN BIT    4 TAG BITS     TYPE
//    ===============================
//            1   0000     Integer64                              = 0     Copy because it's a value
//            0   0001     Float64                                = 1     Copy because it's a value
//            0   0010     Atom                                   = 2     Copy because it's a value
//            0   0011     Header                                 = 3     Copy because it's a value
//            0   0100     Object                                 = 4     Follow since the contents of the address contain an onject structure
//            0   0101     Address                                = 5     Copy since the thing it points to is static and doesn't move like an object which the address can just be copied
//            0   0110     Enumeration                            = 6     Copy because this is an enumeration WITHOUT associated values and this word contains all it's necessary information
//            0   0111     Enumeration WITH Associated Values     = 7     Follow because the object structure contains an enumeration structure
//            0   1000     Boolean                                = 8     Copy because it's a value
//            0   1001     Byte                                   = 9     Copy because it's a value
//            0   1010     UnicodeScalar                          = 10
//            0   1011     Reserved1                              = 11
//            0   1100     Reserved2                              = 12
//            0   1101     Reserved3                              = 13
//            0   1110     Reserved4                              = 14
//            0   1111     Nothing                                = 15    Copy since this is a marker for the nothing value - in Argon it's an instance of the Nothing class

public class Header
    {
    public static let kSignMask: Unsigned64             = 0b10000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000 // 1 bit at at bit  63  -> this is ignored
    public static let kTagMask: Unsigned64              = 0b01111000_00000000_00000000_00000000_00000000_00000000_00000000_00000000 // 4 bits at bit    59  -> this stores the tag defining the base type of the value
    public static let kSizeInWordsMask: Unsigned64      = 0b00000111_11111111_11111111_11111111_11111111_00000000_00000000_00000000 // 36 bits at bit   23  -> this has the size in words of the object, total size = size in words * MemoryLayout<Integer64>.size
    public static let kIndexedMask: Unsigned64          = 0b00000000_00000000_00000000_00000000_00000000_11000000_00000000_00000000 // 1 bit at bit     22  -> does this object have bytes
    public static let kKeyedMask: Unsigned64            = 0b00000000_00000000_00000000_00000000_00000000_00100000_00000000_00000000 // 1 bit at bit     21  -> can this object's contents be accessed via a key
    public static let kFlipCountMask: Unsigned64        = 0b00000000_00000000_00000000_00000000_00000000_000111111_1111111_10000000 // 14 bits at bit    7  -> how many times has this object been flipped by the GC
    public static let kForwardedMask: Unsigned64        = 0b00000000_00000000_00000000_00000000_00000000_00000000_00000000_01000000 // 1 bit at bit      6  -> has this object been moved, if so the new address is found immediately after this header
    public static let kMarkedMask: Unsigned64           = 0b00000000_00000000_00000000_00000000_00000000_00000000_00000000_00100000 // 1 bit at bit      5  -> during the database GC rocess this flag is used to note that we have visited the object
    public static let kAssociatedMask: Unsigned64       = 0b00000000_00000000_00000000_00000000_00000000_00000000_00000000_00010000 // 1 bit at bit      4  -> this is an anumeration that has associated values
    public static let kKindMask: Unsigned64             = 0b00000000_00000000_00000000_00000000_00000000_00000000_00000000_00001111 // 5 bits at bit     0
    
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
    
    public static let kInteger64Mask: Unsigned64                = Tag.integer64.rawValue << 59
    public static let kFloat64Mask: Unsigned64                  = Tag.float64.rawValue << 59
    public static let kAtomMask: Unsigned64                     = Tag.atom.rawValue << 59
    public static let kHeaderMask: Unsigned64                   = Tag.header.rawValue << 59
    public static let kObjectMask: Unsigned64                   = Tag.object.rawValue << 59
    public static let kAddressMask: Unsigned64                  = Tag.address.rawValue << 59
    public static let kEnumerationMask: Unsigned64              = Tag.enumeration.rawValue << 59
    public static let kAssociatedEnumerationMask: Unsigned64    = Tag.associatedEnumeration.rawValue << 59
    public static let kBooleanMask: Unsigned64                  = Tag.boolean.rawValue << 59
    public static let kByteMask: Unsigned64                     = Tag.byte.rawValue << 59
    public static let kUnicodeScalarMask: Unsigned64            = Tag.unicodeScalar.rawValue << 59
    public static let kNothingMask: Unsigned64                  = Tag.nothing.rawValue << 59
    
    public enum Tag: Unsigned64
        {
        case integer64              = 0b0000
        case float64                = 0b0001
        case atom                   = 0b0010
        case header                 = 0b0011
        case object                 = 0b0100
        case address                = 0b0101
        case enumeration            = 0b0110
        case associatedEnumeration  = 0b0111
        case boolean                = 0b1000
        case byte                   = 0b1001
        case unicodeScalar          = 0b1010
        case reserved1              = 0b1011
        case reserved2              = 0b1100
        case reserved3              = 0b1101
        case reserved4              = 0b1110
        case nothing                = 0b1111
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
            Tag(rawValue: self.word & Self.kTagBits >> Self.kTagOffset)!
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
    private var _pointer: RawPointer?
    
    public init(bitPattern: Unsigned64)
        {
        self._word = bitPattern
        }
        
    public init(pointer: RawPointer)
        {
        self._pointer = pointer
        }
    }
