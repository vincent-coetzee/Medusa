//
//  WeakArray.swift
//  Medusa
//
//  Created by Vincent Coetzee on 02/12/2023.
//

import Foundation

public struct WeakArray<Element>: Sequence where Element:AnyObject
    {
    private typealias WeakHolder = WeakReference<Element>
    
    public var elements: Array<Element>
        {
        var elements = Array<Element>()
        for element in self
            {
            elements.append(element)
            }
        return(elements)
        }
        
    public var count: Int
        {
        var count = 0
        for element in self.holders
            {
            count += element.object.isNil ? 0 : 1
            }
        return(count)
        }
        
    public var actualCount: Int
        {
        self.holders.count
        }
        
    public var isEmpty: Bool
        {
        for element in self.holders
            {
            if element.object.isNotNil
                {
                return(false)
                }
            }
        return(true)
        }
        
    private var holders: Array<WeakReference<Element>>
    
    public init()
        {
        self.holders = Array()
        }
        
    public init(_ array: Array<Element>)
        {
        self.holders = Array()
        for element in array
            {
            self.holders.append(WeakReference(object: element))
            }
        }
        
    public mutating func append(_ element: Element)
        {
        self.holders.append(WeakReference(object: element))
        }
        
    public subscript(_ index: Int) -> Element?
        {
        get
            {
            if index < self.holders.count
                {
                return(self.holders[index].object)
                }
            fatalError("index >= \(self.holders.count)")
            }
        set
            {
            if index < self.holders.count
                {
                self.holders[index].object = newValue
                }
            }
        }
        
    public func makeIterator() -> WeakArrayIterator<Element>
        {
        WeakArrayIterator(weakArray: self)
        }
        
    }


public struct WeakArrayIterator<Element>: IteratorProtocol where Element:AnyObject
    {
    private var index: Int = 0
    private let array: WeakArray<Element>
    private let count: Int
    
    public init(weakArray: WeakArray<Element>)
        {
        self.array = weakArray
        self.count = weakArray.actualCount
        }
        
    public mutating func next() -> Element?
        {
        if index < self.count
            {
            let value = self.array[self.index]
            self.index = index + 1
            if value.isNil
                {
                return(self.next())
                }
            return(value)
            }
        return(nil)
        }
    }
