//
//  File 2.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import MedusaCore

open class Slot
    {
    public let name: String
    public let key: Atom
    public let `class`: Class
    public let byteOffset: Integer64
    
    init(name: String,class: Class,atByteOffset: Integer64)
        {
        self.name = name
        self.key = Atom(name)
        self.class = `class`
        self.byteOffset = atByteOffset
        }
    }

public typealias Slots = Array<Slot>
