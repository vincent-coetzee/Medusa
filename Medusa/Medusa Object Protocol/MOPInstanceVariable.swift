//
//  MOPInstanceVariable.swift
//  Medusa
//
//  Created by Vincent Coetzee on 17/11/2023.
//

import Foundation

public class MOPInstanceVariable
    {
    private var name: String
    public var klass: MOPClass
    public var offset: Int
    
    public var sizeInBytes: Medusa.Integer
        {
        self.klass.sizeInBytes!
        }
        
    public init(name: String,klass: MOPClass,offset: Int)
        {
        self.name = name
        self.klass = klass
        self.offset = offset
        }
    }
