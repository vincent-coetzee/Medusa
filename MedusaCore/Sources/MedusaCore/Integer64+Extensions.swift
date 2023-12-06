//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 06/12/2023.
//

import Foundation

extension Integer64
    {
    public init(bitPattern byte: Byte)
        {
        self.init(bitPattern: UInt(byte))
        }
    }
