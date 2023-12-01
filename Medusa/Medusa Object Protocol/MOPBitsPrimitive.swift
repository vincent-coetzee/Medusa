//
//  MOPBitsPrimitive.swift
//  Medusa
//
//  Created by Vincent Coetzee on 01/12/2023.
//

import Foundation

public class MOPBitsPrimitive: MOPPrimitive
    {
    public let sizeInBits: Integer64
    
    public override var sizeInBytes: Integer64
        {
        self.sizeInBits / 8
        }
        
    public init(module: MOPModule,name: String,sizeInBits: Integer64)
        {
        self.sizeInBits = sizeInBits
        super.init(module: module,name: name)
        }
    }
