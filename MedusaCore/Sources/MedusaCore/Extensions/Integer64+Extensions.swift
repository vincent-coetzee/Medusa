//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 06/12/2023.
//

import Foundation

public protocol AnnotationValueType
    {
    }
    
extension Integer64: PrimitiveType,AnnotationValueType
    {
    public init(bitPattern byte: Byte)
        {
        self.init(bitPattern: UInt(byte))
        }
        
    public init(bitPattern pattern: Unsigned64)
        {
        self.init(bitPattern: UInt(pattern))
        }
        
    public var bitString: String
        {
        let little = self.littleEndian
        var bit: Int = 1
        var string = String()
        for index in 0..<64
            {
            if index % 8 == 0 && index != 0
                {
                string += " "
                }
            string += (little & bit == bit ? "1" : "0")
            bit <<= 1
            }
        return(String(string.reversed()))
        }
    }
