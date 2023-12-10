//
//  File 2.swift
//  
//
//  Created by Vincent Coetzee on 10/12/2023.
//

import Foundation
import MedusaCore

public class InstanceVector
    {
    public var count: Integer64
        {
        self.slots.count
        }
        
    private var slots: Array<any Instance>

    public init()
        {
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
    }
