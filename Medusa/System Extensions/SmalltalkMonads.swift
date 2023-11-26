//
//  SmalltalkMonads.swift
//  Medusa
//
//  Created by Vincent Coetzee on 26/11/2023.
//

import Foundation

extension Sequence
    {
    public func select(_ closure: (Self.Element) -> Bool) -> [Self.Element]
        {
        var items = Array<Self.Element>()
        for item in self
            {
            if closure(item)
                {
                items.append(item)
                }
            }
        return(items)
        }
        
    public func detect(_ closure: (Self.Element) -> Bool) -> Bool
        {
        for item in self
            {
            if closure(item)
                {
                return(true)
                }
            }
        return(false)
        }
        
    public func reject(_ closure: (Self.Element) -> Bool) -> Array<Self.Element>
        {
        var items = Array<Self.Element>()
        for item in self
            {
            if !closure(item)
                {
                items.append(item)
                }
            }
        return(items)
        }
        
    public func inject<T>(value: T,into closure: (T,Self.Element) -> T) -> T
        {
        self.reduce(value,closure)
        }
    }
