//
//  Medusa.swift
//  Medusa
//
//  Created by Vincent Coetzee on 16/11/2023.
//

import Foundation

public struct Medusa
    {
    public typealias Float = Swift.Double
    public typealias Integer = Swift.Int
    public typealias String = Swift.String
    public typealias Byte = Swift.UInt8
    public typealias ObjectID = Swift.UInt64
    public typealias Atom = ObjectID
    public typealias Boolean = Swift.Bool
    public typealias Enumeration = MOPEnumeration
    public typealias MagicNumber = UInt64
    public typealias Offset = Integer
    public typealias Checksum = UInt32
    public typealias PagePointer = Integer
    public typealias Bytes = MedusaBytes
    public typealias PageAddress = Integer
    
    public static let kMedusaServiceType = "_medusa._tcp."
    public static let kHostName = Host.current().localizedName!
    public static let kPrimaryServicePort: Int32 = 52000
    public static let kDefaultBufferSize: Int = 4096
    public static let kSocketReadBufferSize = 16 * 1024
    public static let kPageOffsetBits = 14
    public static let kPageOffsetMask = 0b11111111111111
    public static let kPagePageMask = 9_223_372_036_854_767_616
    public static let kPageBitsMask = 1_125_899_906_842_623
    
    public static let kPageMagicNumberOffset                = 0
    public static let kPageChecksumOffset                   = 8
    public static let kPageFreeByteCountOffset              = 16
    public static let kPageFirstFreeCellOffsetOffset        = 24
    public static let kPageCellCountOffset                  = 32
    public static let kPageFreeCellCountOffset              = 40
    public static let kPageHeaderSizeInBytes                = 48
    
    public static let kBTreePageRightPointerOffset               = 48
    public static let kBTreePageKeyEntryCountOffset              = 56
    public static let kBTreePageHeaderSizeInBytes                = 64
    
    public static let kPageSizeInBytes                           = 16 * 1024
    public static let kBTreePageSizeInBytes                      = Medusa.kPageSizeInBytes
    public static let kBTreePageKeysPerPage                      = 50
    public static let kBTreePageFirstCellOffset                  = 50 * MemoryLayout<Int>.size + Self.kBTreePageHeaderSizeInBytes
    
    public static let kBTreePageMagicNumber: MagicNumber    = 0xFADE0000D00DF00D
    }

extension Medusa.PagePointer
    {
    public init(page: Int,offset: Int)
        {
        var number: Medusa.Integer
        
        number = Medusa.Integer(offset) & Medusa.kPageOffsetMask
        number |= (Medusa.Integer(page) & Medusa.kPageBitsMask) << Medusa.kPageOffsetBits
        self = number
        }
        
    public var pageValue: Int
        {
        Int(self >> Medusa.kPageOffsetBits)
        }
        
    public var offsetValue: Int
        {
        Int(self & Medusa.kPageOffsetMask)
        }
    }

extension Medusa.PageAddress
    {
    public var fileOffset: Int
        {
        Int(self & ~Medusa.kPageOffsetMask)
        }
    }
    
public func bitString(of number: UInt64) -> String
    {
    var bit: UInt64 = 1
    var string = String()
    for _ in 0..<64
        {
        string += (number & bit == bit ? "1" : "0")
        bit <<= 1
        }
    return(String(string.reversed()))
    }

public func bitString(of number: Int) -> String
    {
    var bit: Int = 1
    var string = String()
    for _ in 0..<64
        {
        string += (number & bit == bit ? "1" : "0")
        bit <<= 1
        }
    return(String(string.reversed()))
    }
