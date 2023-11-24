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
    private var klass: MOPClass
    public var offset: Int
    public var keyPath: AnyKeyPath
    
    public init(name: String,klass: MOPClass,offset: Int,keyPath: AnyKeyPath)
        {
        self.name = name
        self.klass = klass
        self.offset = offset
        self.keyPath = keyPath
        }
    }
