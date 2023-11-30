//
//  MOPObjectValue.swift
//  Medusa
//
//  Created by Vincent Coetzee on 17/11/2023.
//

import Foundation

public class MOPObject: MOPRoot
    {
    public var objectID: Medusa.ObjectID!
    public var values = Dictionary<String,MOPValue>()
    public var klass: MOPClass!
    public var hasBytes: Bool = false
    }
