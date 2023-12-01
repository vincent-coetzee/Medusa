//
//  MOPObjectValue.swift
//  Medusa
//
//  Created by Vincent Coetzee on 17/11/2023.
//

import Foundation

public class MOPObject: MOPRoot
    {
    public var objectID: Medusa.ObjectID!
    public var klass: MOPClass!
    public var hasBytes: Bool = false
    public var buffer: RawBuffer
    public var elementKlass: MOPClass?
    
    public var sizeInBytes: Integer64
        {
        self.klass.sizeInBytes
        }
    
    public init(ofClass: MOPClass,hasBytes: Boolean,elementOfClass: MOPClass? = nil)
        {
        self.buffer = RawBuffer.allocate(byteCount: ofClass.sizeInBytes, alignment: 1)
        self.klass = ofClass
        self.hasBytes = hasBytes
        self.elementKlass = elementOfClass
        }
        
    public func encode(into page: Page) throws
        {
        let pointer = try page.allocate(sizeInBytes: self.klass.sizeInBytes)
        }
        
    public func basicAt<T>(_ index: Integer64,ofClass: MOPClass.Type) throws -> T
        {
        fatalError("Not implemented yet.")
        }
        
    public func basicAt<T>(_ index: Integer64,put: T) throws
        {
        fatalError("Not implemented yet.")
        }
    }
