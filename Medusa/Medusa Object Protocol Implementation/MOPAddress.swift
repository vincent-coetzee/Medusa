//
//  MOPAddress.swift
//  Medusa
//
//  Created by Vincent Coetzee on 04/12/2023.
//

import Foundation

//                                     Address:
//                                               Sign ( 1 bit )         0
//                                               Tag ( 3 bits )          101
//                                               Reserved ( 10 bits)        0000 000000
//                                     Page offset ( 40 bits )                         PP PPPPPPPP PPPPPPPP PPPPPPPP PPPP
//                                     Intra page offset ( 14 bits )                                                     PPPP PPPPPPII IIIIIIII
//

public struct MOPAddress
    {
    public static let kPageIndexMask: Unsigned64    = 0b00000000_00000011_11111111_11111111_11111111_11111111_11111100_00000000
    public static let kOffsetMask: Unsigned64       = 0b00000000_00000000_00000000_00000000_00000000_00000000_00111111_11111111
    public static let kAddressTagMask: Unsigned64   = 0b01010000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    
    public static let kPageIndexBits: Unsigned64    = 0b00000000_00000000_00000000_11111111_11111111_11111111_11111111_11111111
    public static let kOffsetBits: Unsigned64       = 0b00000000_00000000_00000000_00000000_00000000_00000000_00111111_11111111
    
    public static let kPageIndexShift: Unsigned64   = 14
    public static let kOffsetShift: Unsigned64      = 0
    
    private let _pageIndex: Unsigned64
    private let _offset: Unsigned64
    
    public var pageIndex: Integer64
        {
        Integer64(self._pageIndex)
        }

    public var offset: Integer64
        {
        Integer64(self._offset)
        }
        
    
    public var address: Address
        {
        Integer64(bitPattern: Unsigned64(self.pageIndex) | Self.kAddressTagMask | Unsigned64(self.offset))
        }

    public init(address: Address)
        {
        self._pageIndex = Unsigned64(bitPattern: address) & Self.kPageIndexMask
        self._offset = Unsigned64(bitPattern: address) & Self.kOffsetMask
        }
    }
