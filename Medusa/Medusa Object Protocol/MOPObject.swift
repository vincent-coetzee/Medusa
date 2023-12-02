//
//  MOPObjectValue.swift
//  Medusa
//
//  Created by Vincent Coetzee on 17/11/2023.
//

import Foundation

public class MOPObject: MOPRoot
    {
    public static let nothing = 0b01110000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    
    public var objectID: Medusa.ObjectID!
    public var klass: MOPClass!
    public var hasBytes: Bool = false
    public var elementKlass: MOPClass?
    public var sizeInBytes: Integer64
        {
        self.klass.sizeInBytes
        }
    
    public init(ofClass: MOPClass?,hasBytes: Boolean,elementOfClass: MOPClass? = nil)
        {
        self.klass = ofClass
        self.hasBytes = hasBytes
        self.elementKlass = elementOfClass
        }

    public func basicAt(_ index: Integer64) throws -> Instance
        {
        fatalError("Not implemented yet.")
        }
        
    public func basicAt(_ index: Integer64,put: Instance) throws
        {
        fatalError("Not implemented yet.")
        }
        
    @discardableResult
    public func setClass(_ someClass: MOPClass) -> Self
        {
        self.klass = someClass
        return(self)
        }
    }
