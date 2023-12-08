//
//  File 2.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import MedusaCore
import MedusaStorage

open class ObjectCore
    {
    open var hashValue: Integer64
        {
        fatalError("This should have been overriden in a subclass.")
        }
        
    open var `class`: Class
        {
        fatalError("This should have been overriden in a subclass.")
        }
        
    open var elementClass: Class?
        {
        fatalError("This should have been overriden in a subclass.")
        }
        
    open var isIndexed: Bool
        {
        fatalError("This should have been overriden in a subclass.")
        }
        
    open var isKeyed: Bool
        {
        fatalError("This should have been overriden in a subclass.")
        }
        
    public init()
        {
        }
    
    init(from: RawPointer,atByteOffset: Integer64)
        {
        fatalError("This should have been overriden in a subclass.")
        }
    
    func valueOfSlot(named: String) -> Instance
        {
        fatalError("This should have been overriden in a subclass.")
        }
        
    func setValue(_ value: Instance,ofSlotNamed: String)
        {
        fatalError("This should have been overriden in a subclass.")
        }
        
    func valueOfSlot(_ slot: Slot) -> Instance
        {
        fatalError("This should have been overriden in a subclass.")
        }
        
    func setValue(_ value: Instance,ofSlot: Slot)
        {
        fatalError("This should have been overriden in a subclass.")
        }
        
    subscript(_ index: Integer64) -> Instance
        {
        get
            {
            fatalError("This should have been overriden in a subclass.")
            }
        set
            {
            fatalError("This should have been overriden in a subclass.") 
            }
        }
        
    subscript(_ key: Instance) -> Instance
        {
        get
            {
            fatalError("This should have been overriden in a subclass.") 
            }
        set
            {
            fatalError("This should have been overriden in a subclass.") 
            }
        }
    }
