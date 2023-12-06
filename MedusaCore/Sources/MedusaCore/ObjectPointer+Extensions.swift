//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 06/12/2023.
//

import Foundation

extension ObjectPointer
    {
    public init(_ integer64: Integer64)
        {
        self = (UInt(bitPattern: integer64) & ~Header.kTagMask) | Header.kInteger64Mask
        }
        
    public init(_ float64: Float64)
        {
        self = (UInt(float64.bitPattern) & ~Header.kTagMask) | Header.kFloat64Mask
        }
        
    public init(_ boolean: Boolean)
        {
        self = (UInt(boolean ? 1 : 0) & ~Header.kTagMask) | Header.kBooleanMask
        }
        
    public init(_ byte: Byte)
        {
        self = (UInt(Int(byte)) & ~Header.kTagMask) | Header.kByteMask
        }
        

    }
