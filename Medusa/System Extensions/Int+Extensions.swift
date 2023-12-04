//
//  Int+Extensions.swift
//  Medusa
//
//  Created by Vincent Coetzee on 04/12/2023.
//

import Foundation

extension Int
    {
    public init(bitPattern someFloat: Float64)
        {
        self.init(bitPattern: UInt(someFloat.bitPattern))
        }
        
    public init(bitPattern unsigned: Unsigned64)
        {
        self.init(bitPattern: UInt(unsigned))
        }
    }
