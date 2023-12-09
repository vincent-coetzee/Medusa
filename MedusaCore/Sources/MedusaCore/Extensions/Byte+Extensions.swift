//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 08/12/2023.
//

import Foundation

extension Byte: PrimitiveType,AnnotationValueType
    {
    public var bitString: String
        {
        let little = self.littleEndian
        var bit: Byte = 1
        var string = String()
        for index in 0..<8
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
