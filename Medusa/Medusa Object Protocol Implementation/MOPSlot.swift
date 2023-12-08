//
//  MOPInstanceVariable.swift
//  Medusa
//
//  Created by Vincent Coetzee on 17/11/2023.
//

import Foundation

public class MOPSlot
    {
    public let name: String
    public let klass: MOPClass
    public let offset: Int
    
    public var sizeInBytes: Integer64
        {
        self.klass.slotSizeInBytes
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
        
    public func writeInstance(_ instance: MOPInstance,into buffer: UnsafeMutableRawPointer,atByteOffset offset:inout Integer64)
        {
        self.klass.writeInstance(instance,into: buffer,atByteOffset: &offset)
        }
    }
