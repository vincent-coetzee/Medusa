//
//  MOPEnumeration.swift
//  Medusa
//
//  Created by Vincent Coetzee on 17/11/2023.
//

import Foundation

public class MOPEnumeration: MOPPrimitive
    {
    public weak var enumerationKind: MOPEnumerationKind?
    public var enumerationKindID: Medusa.ObjectID
    public var caseIndex: Int
    
    public init(module: MOPModule,name: String,enumerationKind: MOPEnumerationKind,caseIndex: Int)
        {
        self.enumerationKindID = enumerationKind.objectID
        self.enumerationKind = enumerationKind
        self.caseIndex = caseIndex
        super.init(module: module,name: name)
        }
    }
