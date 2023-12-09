//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 09/12/2023.
//

import Foundation

extension Integer16: AnnotationValueType,PrimitiveType
    {
    public var bitString: String
        {
        let little = self.littleEndian
        var bit: Integer16 = 1
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
