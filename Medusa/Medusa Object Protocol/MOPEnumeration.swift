//
//  MOPEnumeration.swift
//  Medusa
//
//  Created by Vincent Coetzee on 17/11/2023.
//

import Foundation

public class MOPEnumeration: MOPPrimitive
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
        
    public init()
        {
        super.init(module: .argonModule,name: "Integer64")
        }
        
    public override var sizeInBytes: Integer64
        {
        get
            {
            MemoryLayout<Medusa.Byte>.size
            }
        set
            {
            }
        }
    }


public struct MOPEnumerationInstance
    {
    public let enumeration: MOPEnumeration
    public let caseIndex: Integer64
    public var associatedValues: Instances
    }
