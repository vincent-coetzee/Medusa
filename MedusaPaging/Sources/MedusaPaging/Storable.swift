//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 05/12/2023.
//

import Foundation
import MedusaCore
import MedusaStorage
    
public protocol Storable
    {
    var sizeInBytes: Integer64 { get }
    init(from: RawPointer,atByteOffset:inout Integer64)
    func store(into: RawPointer,atByteOffset: inout Integer64)
    }
    

    

    

    

    

    

    

    

