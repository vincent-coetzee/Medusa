//
//  MOPIPv6AddressPrimitive.swift
//  Medusa
//
//  Created by Vincent Coetzee on 01/12/2023.
//

import Foundation

public class MOPIPv6Address: MOPPrimitive
    {
    public override func initialize() -> Self
        {
        _ = super.initialize()
        self.addInstanceVariable(name: "network", klass: MOPBits(module: .argonModule,name: "Bits64", sizeInBits: 64))
        self.addInstanceVariable(name: "node", klass: MOPBits(module: .argonModule,name: "Bits64", sizeInBits: 64))
        return(self)
        }
    }
