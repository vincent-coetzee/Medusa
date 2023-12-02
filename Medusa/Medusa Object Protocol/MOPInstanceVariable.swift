//
//  MOPInstanceVariable.swift
//  Medusa
//
//  Created by Vincent Coetzee on 17/11/2023.
//

import Foundation

public class MOPInstanceVariable
    {
    public let name: String
    public let klass: MOPClass
    public let offset: Int
    
    public var sizeInBytes: Medusa.Integer64
        {
        self.klass.sizeInBytes
        }
        
    public init(name: String,klass: MOPClass,offset: Int)
        {
        self.name = name
        self.klass = klass
        self.offset = offset
        }
        
    public func value<T>(in: Medusa.RawBuffer,as someType: T.Type) -> T
        {
        fatalError()
        }
        
    public func value<R,T>(in root: R,as someType: T.Type) -> T
        {
        fatalError()
        }
    }

public class MOPPrimitiveInstanceVariable<Root,ValueType>: MOPInstanceVariable
    {
    private let keyPath: AnyKeyPath
    
    public init(name: String,klass: MOPClass,offset: Int,keyPath: KeyPath<Root,ValueType>)
        {
        self.keyPath = keyPath
        super.init(name: name,klass: klass,offset: offset)
        }
        
    public override func value<T>(in buffer: Medusa.RawBuffer,as someType: T.Type) -> T
        {
        buffer.load(fromByteOffset: self.offset, as: T.self)
        }
        
    public override func value<R,T>(in root: R,as someType: T.Type) -> T
        {
        root[keyPath: self.keyPath as! KeyPath<R,T>]
        }
    }
