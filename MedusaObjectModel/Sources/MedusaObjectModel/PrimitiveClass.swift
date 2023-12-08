//
//  File 2.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import MedusaCore
import MedusaStorage

public class PrimitiveClass: Class
    {
    public override func readInstance(from rawPointer: RawPointer,atByteOffset:inout Integer64) -> Instance
        {
        Primitive(from: rawPointer,atByteOffset: &atByteOffset)
        }
        
    public override func write(_ instance: Instance,into rawPointer: RawPointer,atByteOffset:inout Integer64)
        {
        instance.store(into: rawPointer,atByteOffset: &atByteOffset)
        }
    }
