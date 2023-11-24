//
//  MOPEnumerationKind.swift
//  Medusa
//
//  Created by Vincent Coetzee on 17/11/2023.
//

import Foundation

public class MOPEnumerationKind: MOPClass
    {
    public var cases: Array<MOPEnumerationCase>
    
    public init(name: String,cases: Array<MOPEnumerationCase> = Array())
        {
        self.cases = cases
        super.init(name: name)
        }
        
    public func `case`(name: String) -> MOPEnumerationKind
        {
        self.cases.append(MOPEnumerationCase(name: name,index: 0))
        return(self)
        }
        
    public func cases(_ names: String...) -> MOPEnumerationKind
        {
        for name in names
            {
            self.cases.append(MOPEnumerationCase(name: name,index: 0))
            }
        return(self)
        }
    }
