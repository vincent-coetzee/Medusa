//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 06/12/2023.
//

import Foundation
import MedusaStorage
import MedusaCore

extension Boolean
    {
    public var objectAddress: ObjectAddress
        {
        ObjectAddress(self)
        }
    }
