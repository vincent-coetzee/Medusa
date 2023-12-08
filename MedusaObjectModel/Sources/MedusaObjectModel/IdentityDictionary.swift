//
//  File 2.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import MedusaCore
import MedusaStorage

open class IdentityDictionary: MOMDictionary
    {
    public subscript(_ atom: Atom) -> Instance
        {
        get
            {
            fatalError()
            }
        set
            {
            fatalError()
            }
        }
    }
