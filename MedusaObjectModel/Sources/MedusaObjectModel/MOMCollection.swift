//
//  File 2.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import MedusaCore
import MedusaStorage
import MedusaPaging

open class MOMCollection: Object
    {
    public override init(inMemorySizeInBytes: Integer64)
        {
        super.init(inMemorySizeInBytes: 0)
        }
        
    public subscript(_ index: Integer64) -> any Instance
        {
        fatalError()
        }
        
    public func insert(_ value: any Instance,at: Integer64)
        {
        fatalError()
        }
        
    public func remove(at: Integer64)
        {
        fatalError()
        }
        
    public func first() -> any Instance
        {
        fatalError()
        }
        
    public func last() -> any Instance
        {
        fatalError()
        }
        
    public func append(_ instance: any Instance)
        {
        fatalError()
        }
        
    public func index(of instance: any Instance) -> Integer64?
        {
//        for slot in self.
        fatalError()
        }
    }
