//
//  File 2.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import MedusaCore
import MedusaStorage

open class SlotBasedObjectCore: ObjectCore
    {
    private var slotValues = Dictionary<Atom,Instance>()
    private var _class: Class
    
    open override var hashValue: Integer64
        {
        fatalError("This should have been overriden in a subclass.")
        }
        
    open override var `class`: Class
        {
        self._class
        }
        
    open override var elementClass: Class?
        {
        self._class.elementClass
        }
        
    open override var isIndexed: Bool
        {
        self._class.isIndexed
        }
        
    open override var isKeyed: Bool
        {
        self._class.isKeyed
        }
        
    public init(ofClass: Class)
        {
        self._class = ofClass
        super.init()
        self.initSlots()
        }
    
    private func initSlots()
        {
//        for slot in self._class.slots
//            {
////            self.slotValues[slot.
//            }
        }
        
    public override func valueOfSlot(named: String) -> Instance
        {
        fatalError()
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
