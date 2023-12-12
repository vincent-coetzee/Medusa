//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 09/12/2023.
//

import Foundation
import MedusaCore
    
public class MOMBlock: Object
    {
    
    }

public class MOMBlockHeader
    {
    public static let kSignMask: Unsigned64             = 0b10000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000 // 1 bit at at bit  63  -> this is ignored
    public static let kSizeInSlotsMask: Unsigned64      = 0b00000000_11111111_11111111_00000000_00000000_00000000_00000000_00000000 // 16 bits at bit   39  -> total number of slots in this block
    public static let kSlotCountMask: Unsigned64        = 0b00000000_00000000_00000000_11111111_11111111_00000000_00000000_00000000 // 16 bits at bit   23  -> number of used slots in this block
    public static let kSlotSizeInBytesMask: Unsigned64  = 0b00000000_00000000_00000000_00000000_00000000_11111111_00000000_00000000 // 8 bits at bit    15  -> size of each slot
    public static let kIsLastBlockMask: Unsigned64      = 0b00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000001 // 1 bit at at bit   0  -> Boolean to indicate if this is last block
    
    
    public static let kSignBits: Unsigned64             = 0b1
    public static let kSizeInSlotsBits: Unsigned64      = 0b11111111_11111111
    public static let kSlotCountBits: Unsigned64        = 0b11111111_11111111
    public static let kIsLastBlockBits: Unsigned64      = 0b1
    
    public static let kSignOffset: Unsigned64           = 63
    public static let kSizeInSlotsOffset: Unsigned64    = 39
    public static let kSlotCountOffset: Unsigned64      = 23
    public static let kIsLastBlockOffset: Unsigned64    = 0
    
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
        
    public var sizeInSlots: Unsigned64
        {
        get
            {
            self.word & Self.kSizeInSlotsMask >> Self.kSizeInSlotsOffset
            }
        set
            {
            self.word = (self.word & ~Self.kSizeInSlotsBits) | (Unsigned64(newValue) & Self.kSizeInSlotsBits) << Self.kSizeInSlotsOffset
            }
        }
        
    public var slotCount: Integer64
        {
        get
            {
            Integer64(self.word & Self.kSlotCountMask >> Self.kSlotCountOffset)
            }
        set
            {
            self.word = (self.word & ~Self.kSlotCountBits) | (Unsigned64(newValue) & Self.kSlotCountBits)  << Self.kSlotCountOffset
            }
        }
        
    public var isLastBlock: Boolean
        {
        get
            {
            (self.word & Self.kIsLastBlockMask) == Self.kIsLastBlockMask
            }
        set
            {
            self.word = (self.word & ~Self.kIsLastBlockBits) | (newValue ? Self.kIsLastBlockBits << Self.kIsLastBlockOffset : 0)
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
