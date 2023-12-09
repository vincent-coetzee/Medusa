//
//  File 2.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import MedusaCore
import MedusaStorage

open class BufferObjectCore: ObjectCore
    {
    private var _class: Class
    private var buffer: RawPointer
    private var bufferSizeInBytes: Integer64
    
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
        self.bufferSizeInBytes = ofClass.sizeInBytes
        self.buffer = RawPointer.allocate(byteCount: ofClass.sizeInBytes, alignment: 1)
        self.buffer.initializeMemory(as: Byte.self, to: 0)
        super.init()
        }
    
    private func initBuffer()
        {
//        for slot in self._class.slots
//            {
////            self.slotValues[slot.
//            }
        }
        
    public override func valueOfSlot(named: String) -> Instance
        {
        guard let slot = self.class.slotAtName(named) else
            {
            fatalError("Invalid slot name")
            }
        return(slot.class.decodeInstance(from: self.buffer,atByteOffset: slot.byteOffset))
        }
        
    public override func setValue(_ value: Instance,ofSlotNamed slotName: String)
        {
        guard let slot = self.class.slotAtName(slotName) else
            {
            fatalError("Invalid slot name")
            }
        value.encode(into: self.buffer,atByteOffset: slot.byteOffset)
        }
        
    public override func valueOfSlot(_ slot: Slot) -> Instance
        {
        return(slot.class.decodeInstance(from: self.buffer,atByteOffset: slot.byteOffset))
        }
        
    public override func setValue(_ value: Instance,ofSlot slot: Slot)
        {
        value.encode(into: self.buffer,atByteOffset: slot.byteOffset)
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
