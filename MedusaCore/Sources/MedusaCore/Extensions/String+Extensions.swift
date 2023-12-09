//
//  String+Extensions.swift
//  Medusa
//
//  Created by Vincent Coetzee on 19/11/2023.
//

import Foundation

extension String: AnnotationValueType
    {
    public var standardHash: Int
        {
        // this is a PolynomialRollingHash hacked to work with Unicode.Scalars, not sure how correct it is
        let p:Int64 = Int64(Int32.max) // there are Int32.max possible Unicode.Scalar values
        let m:Int64 = Int64(1e9) + 9
        var powerOfP:Int64 = 1
        var hashValue:Int64 = 0
        for char in self.unicodeScalars
            {
            hashValue = (hashValue + Int64(char.value) * powerOfP) % m
            powerOfP = (powerOfP * p) % m
            }
        return(Int(hashValue) & Integer64.maximum)
        }

    public var polynomialRollingHash:Int
        {
        self.standardHash
        }
    }
