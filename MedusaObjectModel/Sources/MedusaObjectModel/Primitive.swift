//
//  File 2.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import MedusaCore
import MedusaStorage

open class Primitive: Instance
    {
    public enum Kind: Integer64
        {
        case nothing
        case integer64
        case float64
        case atom
        case boolean
        case byte
        case unicodeScalar
        case object
        
        public func `class`(of address: ObjectAddress) -> Class
            {
            switch(self)
                {
                case .nothing:
                    return(.nothingClass)
                case .integer64:
                    return(.integer64Class)
                case .float64:
                    return(.float64Class)
                case .atom:
                    return(.atomClass)
                case .boolean:
                    return(.booleanClass)
                case .byte:
                    return(.byteClass)
                case .unicodeScalar:
                    return(.unicodeScalarClass)
                case .object:
                    return(address.class)
                }
            }
            
        public func `sizeInBytes`(of address: ObjectAddress) -> Integer64
            {
            switch(self)
                {
                case .object:
//                    return(address.class)
                fatalError()
                default:
                    return(MemoryLayout<Integer64>.size)
                }
            }
        }
    
    public var kind: Kind
    
    open override var `class`: Class
        {
        self.kind.class(of: self.objectAddress)
        }
        
    open override var elementClass: Class?
        {
        if self.kind == .object
            {
            return(self.objectAddress.elementClass)
            }
        return(nil)
        }
    
    open override var isIndexed: Bool
        {
        if self.kind == .object
            {
//            return(self.objectAddress.isIndexed)
            fatalError()
            }
        return(false)
        }
        
    open override var isKeyed: Bool
        {
        if self.kind == .object
            {
//            return(self.objectAddress.isKeyed)
            fatalError()
            }
        return(false)
        }
        
    open override var sizeInBytes: Integer64
        {
        self.kind.sizeInBytes(of: self.objectAddress)
        
        }
        
    public init(objectAddress: ObjectAddress,kind: Kind)
        {
//        self.objectAddress = objectAddress
//        self.kind = kind
//        super.init()
        fatalError()
        }
        
    public required init(from buffer: RawPointer,atByteOffset: inout Integer64)
        {
//        self.objectAddress = readObjectAddressWithOffset(buffer,&atByteOffset)
        fatalError()
        }

    open func store(in buffer: RawPointer,atByteOffset:inout  Integer64)
        {
        writeObjectAddressWithOffset(buffer,self.objectAddress,&atByteOffset)
        }
    }
