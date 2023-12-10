//
//  File 2.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import MedusaCore
import MedusaStorage

open class MOMCollection: Object,IndexedInstance
    {
    public private(set) var elementClass: Class
    
    public var count: Integer64
        {
        self.slots.count
        }
        
    private var slots: Array<any Instance>

    public init(ofClass: Class,page: Page,objectIndex: Integer64)
        {
        super.init(ofClass: ofClass)
        self.slots = Array<any Instance>()
        }
        
    public subscript(_ index: Integer64) -> any Instance
        {
        get
            {
            if index >= self.slots.count
                {
                fatalError("Index exceeds slot count.")
                }
            return(self.slots[index])
            }
        set
            {
            if index >= self.slots.count
                {
                fatalError("Index exceeds slot count.")
                }
            self.slots[index] = newValue
            }
        }
        
    public func insert(_ value: any Instance,at: Integer64)
        {
        self.slots.insert(value, at: at)
        }
        
    public func remove(at: Integer64)
        {
        self.slots.remove(at: at)
        }
        
    public func first() -> any Instance
        {
        self.slots[0]
        }
        
    public func last() -> any Instance
        {
        self.slots[self.slots.count-1]
        }
        
    public func append(_ instance: any Instance)
        {
        self.slots.append(instance)
        }
        
    public func index(of instance: Instance) -> MedusaCore.Integer64?
        {
        for slot in self.
        }
    }