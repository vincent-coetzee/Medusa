//
//  File 2.swift
//  
//
//  Created by Vincent Coetzee on 06/12/2023.
//

import Foundation
import MedusaCore
import MedusaStorage
import Fletcher

extension ObjectAddress
    {
    public var enumerationValue: Enumeration
        {
        fatalError("Not yet implemented.")
        }
        
    public init(enumeration: Enumeration)
        {
        self.init(bitPattern: 0)
        }
        
    public var tupleValue: Tuple
        {
        fatalError("Not yet implemented.")
        }
        
    public init(tuple: Tuple)
        {
        fatalError("Not yet implemented.")
        }
        
    public var atomValue: Atom
        {
        Atom(rawValue: Integer64(self.address))
        }
        
    public init(atom: Atom)
        {
        self.init(bitPattern: Unsigned64(atom.rawValue))
        }
    }
