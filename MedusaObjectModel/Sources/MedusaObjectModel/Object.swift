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
    public var objectAddress: ObjectAddress
    public private(set) var objectHandle: ObjectHandle
    public private(set) var `class`: Class
    public var page: Page
    public var objectIndex: Integer64
    
    public var isIndexed: Boolean
        {
        self.class.isInstanceIndexed
        }
        
    public var sizeInBytes: Integer64
        {
        self.class.instanceSizeInBytes
        }
        
    public init(ofClass: Class,page: Page,objectIndex: Integer64,objectHandle: ObjectHandle)
        {
        self.page = page
        self.objectIndex = objectIndex
        self.objectAddress = ObjectAddress(pageOffset: page.pageOffset,objectIndex: objectIndex)
        self.class = ofClass
        self.objectHandle = objectHandle
        }
        
    public static func ==(lhs: Object,rhs: Object) -> Bool
        {
        false
        }
        
    public static func <(lhs: Object,rhs: Object) -> Bool
        {
        false
        }
        
    public func hash(into hasher:inout Hasher)
        {
        for slot in self.class.instanceSlots
            {
            hasher.combine(self.value(ofSlot: slot))
            }
        }
        
    public func value(ofSlot: Slot) -> any Instance
        {
        Nothing.kNothing
        }
        
    public func value(ofSlotAtKey: String) -> any Instance
        {
        Nothing.kNothing
        }
        
    public func setValue(_ value: any Instance,ofSlotAtKey: String)
        {
        }
    }

