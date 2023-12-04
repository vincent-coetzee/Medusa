//
//  MOPStringObject.swift
//  Medusa
//
//  Created by Vincent Coetzee on 04/12/2023.
//

import Foundation

public class MOPStringObject: MOPObject
    {
    public var string: String
    
    public init(string: String)
        {
        self.string = string
        super.init(ofClass: .stringClass,elementOfClass: .unicodeScalarClass)
        }
    }
