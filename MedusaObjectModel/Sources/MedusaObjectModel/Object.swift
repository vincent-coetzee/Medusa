//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 05/12/2023.
//

import Foundation

import Foundation
import MedusaCore
import MedusaStorage
import MedusaPaging

open class Object: Instance
    {
    private var _class: Class
    
    public override var `class`: Class
        {
        self._class
        }
        
    private var core: ObjectCore
    
    public init(ofClass: Class)
        {
        self._class = ofClass
        self.core = SlotBasedObjectCore(ofClass: ofClass)
//        super.init(from: <#T##RawPointer#>, atByteOffset: &<#T##Integer64#>
        fatalError()
        }
        
    public init(from page: Page,atByteOffset: Integer64)
        {
        self.core = PageBasedObjectCore(from: page,atByteOffset: atByteOffset)
        self._class = self.core.class
        fatalError()
        }
        
    public required init(from: RawPointer,atByteOffset: inout Integer64)
        {
        fatalError()
        }
        
    open func store(in: RawPointer,atByteOffset: Integer64)
        {
        }
        
    open func store(in: RawPointer,atByteOffset:inout  Integer64)
        {
        }
        
    public func valueOfSlot(named: String) -> Instance
        {
        self.core.valueOfSlot(named: named)
        }
        
    public func setValue(_ value: Instance,ofSlotNamed name: String)
        {
        self.core.setValue(value,ofSlotNamed: name)
        }
        
    public func write(into buffer: RawPointer,atByteOffset: inout Integer64)
        {
        fatalError("Unimplemented")
        }
    }
