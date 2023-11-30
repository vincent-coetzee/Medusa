//
//  MOPModule.swift
//  Medusa
//
//  Created by Vincent Coetzee on 28/11/2023.
//

import Foundation

public class MOPModule: MOPObject
    {
    public let module: MOPModule?
    public let name: String
    
    public var identifier: Identifier
        {
        (self.module?.identifier ?? Identifier()) + self.name
        }
        
    public init(module:MOPModule?,name: String)
        {
        self.module = module
        self.name = name
        super.init()
        }
    }
