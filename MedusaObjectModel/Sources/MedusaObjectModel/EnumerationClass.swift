//
//  File 2.swift
//  
//
//  Created by Vincent Coetzee on 06/12/2023.
//

import Foundation
import MedusaCore
import MedusaStorage

open class EnumerationClass: Class
    {
    public override func readInstance(from rawPointer: RawPointer,atByteOffset:inout Integer64) -> Instance
        {
        Enumeration(from: rawPointer,atByteOffset: &atByteOffset)
        }
        
    public override func write(_ instance: Instance,into rawPointer: RawPointer,atByteOffset:inout Integer64)
        {
        (instance as! Enumeration).write(into: rawPointer,atByteOffset: &atByteOffset)
        }
    }
