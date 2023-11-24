//
//  MOPObjectValue.swift
//  Medusa
//
//  Created by Vincent Coetzee on 17/11/2023.
//

import Foundation

public class MOPObject: MOPValue
    {
    public var objectID: Medusa.ObjectID!
    public var values = Dictionary<String,ValueBox>()
    public var klass: MOPClass!
    public var hasBytes: Bool = false
    
    public func setValue(_ value: ValueBox,of name: String) throws
        {
//        guard let instanceVariable = self.klass.instanceVariables[name] else
//            {
//            fatalError()
//            }
//        self.values[name] = value
        }
    }
