//
//  File 2.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import MedusaCore
import MedusaStorage

open class MOMString: MOMCollection
    {
    private static let kStaticSizeInBytes = 5 * MemoryLayout<Integer64>.size
    
    private var string: String
    
    public override var sizeInBytes: Integer64
        {
        Self.kStaticSizeInBytes + (self.string.unicodeScalars.count / 2 + 1)
        }
        
    public init(string: String)
        {
        self.string = string
        super.init(inMemorySizeInBytes: MOMString.stringSizeInBytes(string: string))
        }
        
    private static func stringSizeInBytes(string someString: String) -> Integer64
        {
        Self.kStaticSizeInBytes + (someString.unicodeScalars.count / 2 + 1)
        }
    }
