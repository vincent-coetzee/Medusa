//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 06/12/2023.
//

import Foundation

extension Integer64: PrimitiveType
    {
    public init(bitPattern byte: Byte)
        {
        self.init(bitPattern: UInt(byte))
        }
        
    public init(bitPattern pattern: Unsigned64)
        {
        self.init(bitPattern: UInt(pattern))
        }
    }
