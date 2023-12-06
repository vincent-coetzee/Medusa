//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 06/12/2023.
//

import Foundation

extension ObjectID
    {
    public init(_ boolean: Boolean)
        {
        self = boolean ? 1 : 0
        }
        
    public init(_ float: Float64)
        {
        self = ObjectID(bitPattern: UInt(float.bitPattern))
        }
        
    public init(_ integer64: Integer64)
        {
        self = integer64
        }
    }
