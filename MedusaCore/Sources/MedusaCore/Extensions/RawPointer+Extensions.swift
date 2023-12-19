//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 18/12/2023.
//

import Foundation

infix operator ++

extension RawPointer
    {
    public static func ++<T>(lhs: inout RawPointer,rhs: T.Type)
        {
        lhs += MemoryLayout<T>.size
        }
        
    // Note that this method changes the underlying value of the receiver by incrementing it by the number of bytes read
    public mutating func loadValue<T>(as: T.Type) -> T
        {
        let value = self.loadUnaligned(as: T.self)
        self ++ T.self
        return(value)
        }
        
    // Note that this method changes the underlying value of the receiver by incrementing it by the number of bytes written
    public mutating func storeValue<T>(of value: T,as: T.Type)
        {
        self.storeBytes(of: value, as: T.self)
        self ++ T.self
        }
    }
