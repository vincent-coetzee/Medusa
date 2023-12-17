//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 16/12/2023.
//

import Foundation

@propertyWrapper
public struct LockedAccess<Value>
    {
    var value: Value
    private var lock = NSRecursiveLock()
    
    public var wrappedValue: Value
        {
        get
            {
            self.lock.lock()
            defer
                {
                self.lock.unlock()
                }
            return(value)
            }
        set
            {
            self.lock.lock()
            defer
                {
                self.lock.unlock()
                }
            self.value = newValue
            }
        }
        
    public init(value: Value)
        {
        self.value = value
        }
    }
