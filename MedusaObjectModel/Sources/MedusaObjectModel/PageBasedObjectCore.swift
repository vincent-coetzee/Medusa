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

public class PageBasedObjectCore: ObjectCore
    {
    private var page: Page
    private var pageBuffer: RawPointer
        
    open override var hashValue: Integer64
        {
        fatalError("This should have been overriden in a subclass.")
        }
        
    open override var `class`: Class
        {
        fatalError("This should have been overriden in a subclass.")
        }
        
    open override var elementClass: Class?
        {
        fatalError("This should have been overriden in a subclass.")
        }
        
    open override var isIndexed: Bool
        {
        fatalError("This should have been overriden in a subclass.")
        }
        
    open override var isKeyed: Bool
        {
        fatalError("This should have been overriden in a subclass.")
        }
    
    public init(from page: Page,atByteOffset: Integer64)
        {
        self.page = page
        self.pageBuffer = page.buffer
        super.init()
        }
    
    public override func valueOfSlot(named: String) -> Instance
        {
        fatalError("This should have been overriden in a subclass.")
        }
        
    public override func setValue(_ value: Instance,ofSlotNamed: String)
        {
        fatalError("This should have been overriden in a subclass.")
        }
        
    public override func valueOfSlot(_ slot: Slot) -> Instance
        {
        fatalError("This should have been overriden in a subclass.")
        }
        
    public override func setValue(_ value: Instance,ofSlot: Slot)
        {
        fatalError("This should have been overriden in a subclass.")
        }
        
    public override subscript(_ index: Integer64) -> Instance
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
        
    public override subscript(_ key: Instance) -> Instance
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
