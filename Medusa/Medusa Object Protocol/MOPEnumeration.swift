//
//  MOPEnumeration.swift
//  Medusa
//
//  Created by Vincent Coetzee on 17/11/2023.
//

import Foundation

public class MOPEnumerationPrimitive: MOPPrimitive
    {
    public var cases = Array<MOPEnumerationCase>()
    
    public init(module: MOPModule,name: String,caseNames: String...)
        {
        var index = 0
        for caseName in caseNames
            {
            self.cases.append(MOPEnumerationCase(name: caseName, index: index))
            index += 1
            }
        super.init(module: module,name: name)
        }
    }
