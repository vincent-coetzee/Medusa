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
    public static let kIsHeaderMask: Unsigned64         = 0b01000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    public static let kSizeInWordsMask: Unsigned64      = 0b00111111_11111111_11111111_11111111_11111111_10000000_00000000_00000000 // 39 bits at bit   23  -> this has the size in words of the object, total size = size in words * MemoryLayout<Integer64>.size
    public static let kHasBytesMask: Unsigned64         = 0b00000000_00000000_00000000_00000000_00000000_01000000_00000000_00000000 // 1 bit at bit     22  -> does this object have bytes
    public static let kFlipCountMask: Unsigned64        = 0b00000000_00000000_00000000_00000000_00000000_00111111_11111111_00000000 // 14 bits at bit    7  -> how many times has this object been flipped by the GC
    public static let kIsForwardedMask: Unsigned64      = 0b00000000_00000000_00000000_00000000_00000000_00000000_00000000_10000000 // 1 bit at bit      6  -> has this object been moved, if so the new address is found immediately after this header
    public static let kIsMarkedMask: Unsigned64         = 0b00000000_00000000_00000000_00000000_00000000_00000000_00000000_01000000 // 1 bit at bit      5  -> during the database GC rocess this flag is used to note that we have visited the object
    public static let kReservedMask: Unsigned64         = 0b00000000_00000000_00000000_00000000_00000000_00000000_00000000_00111111 // 6 bits at bit     0
    
    public static let kSignBits: Unsigned64             = 0b1
    public static let kIsHeaderBits: Unsigned64         = 0b1
    public static let kSizeInWordsBits: Unsigned64      = 0b111111_11111111_11111111_11111111_11111111_1
    public static let kHasBytesBits: Unsigned64         = 0b1
    public static let kFlipCountBits: Unsigned64        = 0b111111_11111111
    public static let kIsForwardedBits: Unsigned64      = 0b1
    public static let kIsMarkedBits: Unsigned64         = 0b1
    public static let kReservedBits: Unsigned64         = 0b111111
    
    
    public static let kSignOffset: Unsigned64           = 63
    public static let kIsHeaderOffset: Unsigned64       = 62
    public static let kSizeInWordsOffset: Unsigned64    = 23
    public static let kHasBytesOffset: Unsigned64       = 22
    public static let kFlipCountOffset: Unsigned64      = 8
    public static let kIsForwardedOffset: Unsigned64    = 7
    public static let kIsMarkedOffset: Unsigned64       = 6
    public static let kReservedOffset: Unsigned64       = 0

    
    public var sign: Integer64
        {
        get
            {
            Integer64((self.word & Self.kSignMask) >> Self.kSignOffset)
            }
        set
            {
            self.word = (self.word & ~Self.kSignMask) | (newValue == 1 ? Self.kSignMask : 0)
            }
        }
        
    public var sizeInWords: Integer64
        {
        get
            {
            Integer64((self.word & Self.kSizeInWordsMask) >> Self.kSizeInWordsOffset)
            }
        set
            {
            self.word = (self.word & ~Self.kSizeInWordsMask) | ((Unsigned64(newValue) & Self.kSizeInWordsBits) << Self.kSizeInWordsOffset)
            }
        }
        
    public var flipCount: Integer64
        {
        get
            {
            Integer64((self.word & Self.kFlipCountMask) >> Self.kFlipCountOffset)
            }
        set
            {
            self.word = (self.word & ~Self.kFlipCountMask) | ((Unsigned64(newValue) & Self.kFlipCountBits) << Self.kFlipCountOffset)
            }
        }
        
    public var hasBytes: Boolean
        {
        get
            {
            (self.word & Self.kHasBytesMask) == Self.kHasBytesMask
            }
        set
            {
            self.word = (self.word & ~Self.kHasBytesMask) | (newValue ? Self.kHasBytesMask : 0)
            }
        }
        
    public var isForwarded: Boolean
        {
        get
            {
            (self.word & Self.kIsForwardedMask) == Self.kIsForwardedMask
            }
        set
            {
            self.word = (self.word & ~Self.kIsForwardedMask) | (newValue ? Self.kIsForwardedMask : 0)
            }
        }
        
    public var isHeader: Boolean
        {
        get
            {
            (self.word & Self.kIsHeaderMask) == Self.kIsHeaderMask
            }
        set
            {
            self.word = (self.word & ~Self.kIsHeaderMask) | (newValue ? Self.kIsHeaderMask : 0)
            }
        }
        
    public var isMarked: Boolean
        {
        get
            {
            (self.word & Self.kIsMarkedMask) == Self.kIsMarkedMask
            }
        set
            {
            self.word = (self.word & ~Self.kIsMarkedMask) | (newValue ? Self.kIsMarkedMask : 0)
            }
        }
        
        
    public var word: Unsigned64
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
        
    public var bitPattern: Unsigned64
        {
        get
            {
            self.word
            }
        set
            {
            self.word = newValue
            }
        }
        
    private var _word: Unsigned64?
    private var _pointer: RawPointer?
    
    public init(bitPattern: Unsigned64)
        {
        self._word = bitPattern
        self._pointer = nil
        }
        
    public init(pointer: RawPointer)
        {
        self._word = nil
        self._pointer = pointer
        }
    }
