//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 08/12/2023.
//

import Foundation

extension Float64: PrimitiveType,AnnotationValueType
    {
    public var bitString: String
        {
        let floatPointer = UnsafeMutablePointer<Float64>.allocate(capacity: 1)
        floatPointer.pointee = self
        let rawPointer = UnsafeRawPointer(OpaquePointer(floatPointer))
        var string = String()
        for index in 0..<8
            {
            let byte = rawPointer.load(fromByteOffset: index, as: Byte.self)
            let smallString = byte.bitString
            string += smallString + " "
            }
        return(string)
        }
    }
