//
//  MOPModule.swift
//  Medusa
//
//  Created by Vincent Coetzee on 28/11/2023.
//

import Foundation

public class MOPModule: MOPObject
    {
    public static let argonModule = MOPArgonModule.shared
    
    public let module: MOPModule?
    public let name: String
    public var classes = Dictionary<String,MOPClass>()
    
    public var identifier: Identifier
        {
        (self.module?.identifier ?? Identifier()) + self.name
        }
        
    public init(module:MOPModule?,name: String)
        {
        self.module = module
        self.name = name
        super.init(ofClass: nil, hasBytes: false)
        }
        
    @discardableResult
    public func addClass(_ someClass: MOPClass) -> Self
        {
        self.classes[someClass.name] = someClass
        return(self)
        }
        
    @discardableResult
    public func addSystemClass(_ someClass: MOPClass) -> Self
        {
        someClass.setModule(MOPArgonModule.shared)
        self.classes[someClass.name] = someClass
        return(self)
        }
        
    public func lookupClass(named: String) -> MOPClass?
        {
        self.classes[named]
        }
        
    @discardableResult
    internal func addSystemClass(named: String) -> MOPClass
        {
        let klass = MOPClass(module: MOPArgonModule.shared,name: named)
        MOPArgonModule.shared.addClass(klass)
        return(klass)
        }
    }

public class MOPArgonModule: MOPModule
    {
    public static let shared = MOPArgonModule(module: nil,name: "Argon")
        
    public override init(module: MOPModule?,name: String)
        {
        super.init(module: module,name: name)
        }

    public func initHierarchy()
        {
        //
        // Basic Argon hierarchy in alphabetical order, additional state and relationship info is added later down
        //
        self.addSystemClass(named: "ArgonModule")
        self.addSystemClass(named: "Array")
        self.addSystemClass(named: "Association")
        self.addSystemClass(MOPAtom())
        
        self.addSystemClass(named: "Behaviour")
        self.addSystemClass(named: "BitSet")
        self.addSystemClass(MOPBoolean())
        self.addSystemClass(MOPByte())
        
        self.addSystemClass(named: "Class")
        self.addSystemClass(named: "Closure")
        self.addSystemClass(named: "Collection")
        
        self.addSystemClass(named: "Date")
        self.addSystemClass(named: "DateTime")
        self.addSystemClass(named: "Dictionary")
        self.addSystemClass(named: "Directory")
        
        self.addSystemClass(MOPEnumeration())
        
        self.addSystemClass(named: "File")
        self.addSystemClass(named: "FixedPointNumber")
        self.addSystemClass(named: "FloatingPointNumber")
        self.addSystemClass(MOPFloat64())
        self.addSystemClass(MOPFloat32())
        self.addSystemClass(MOPFloat16())
        
        self.addSystemClass(named: "IdentityDictionary")
        self.addSystemClass(named: "IndexedCollection")
        self.addSystemClass(MOPInteger64())
        self.addSystemClass(MOPInteger32())
        self.addSystemClass(MOPInteger16())
        self.addSystemClass(named: "Interval")
        self.addSystemClass(named: "IPAddress")
        self.addSystemClass(named: "IPv4Address")
        self.addSystemClass(named: "IPv6Address")
        
        self.addSystemClass(named: "KeyedCollection")
        self.addSystemClass(named: "KeyValueAssociation")
        
        self.addSystemClass(named: "List")
        self.addSystemClass(named: "Lock")
        
        self.addSystemClass(named: "Magnitude")
        self.addSystemClass(named: "Message")
        self.addSystemClass(named: "Metaclass")
        self.addSystemClass(named: "Method")
        self.addSystemClass(named: "Module")
        self.addSystemClass(named: "Monitor")
        
        self.addSystemClass(named: "Number")
        self.addSystemClass(MOPNothing())
        
        self.addSystemClass(named: "Object")
        
        self.addSystemClass(named: "Pipe").setClass(.metaclassClass).setSuperclass(.objectClass)
        self.addSystemClass(named: "Pointer").setClass(.metaclassClass).setSuperclass(.objectClass)
        self.addSystemClass(named: "Primitive").setClass(.metaclassClass).setSuperclass(.classClass)
        self.addSystemClass(named: "Process").setClass(.metaclassClass).setSuperclass(.objectClass)
        
        self.addSystemClass(named: "ReadFile").setClass(.metaclassClass)
        self.addSystemClass(named: "ReadStream").setClass(.metaclassClass)
        self.addSystemClass(named: "ReadWriteFile").setClass(.metaclassClass)
        self.addSystemClass(named: "ReadWriteStream").setClass(.metaclassClass)
        
        self.addSystemClass(named: "Semaphore").setClass(.metaclassClass).setSuperclass(.objectClass)
        self.addSystemClass(named: "Set").setClass(.metaclassClass).setSuperclass(.collectionClass)
        self.addSystemClass(named: "Signal").setClass(.metaclassClass).setSuperclass(.objectClass)
        self.addSystemClass(MOPString().setClass(.primitiveClass).setSuperclass(.indexedCollectionClass))
        self.addSystemClass(named: "Stream").setClass(.metaclassClass).setSuperclass(.objectClass)
        
        self.addSystemClass(named: "Thread").setClass(.metaclassClass).setSuperclass(.objectClass)
        self.addSystemClass(named: "Time").setClass(.metaclassClass).setSuperclass(.magnitudeClass)
        self.addSystemClass(named: "Tuple").setClass(.metaclassClass).setSuperclass(.objectClass)
        
        self.addSystemClass(MOPUnsigned64().setClass(.primitiveClass).setSuperclass(.fixedPointNumberClass))
        self.addSystemClass(MOPUnsigned32().setClass(.primitiveClass).setSuperclass(.fixedPointNumberClass))
        self.addSystemClass(MOPUnsigned16().setClass(.primitiveClass).setSuperclass(.fixedPointNumberClass))
        
        self.addSystemClass(named: "WriteFile").setClass(.metaclassClass).setSuperclass(.fileClass)
        self.addSystemClass(named: "WriteStream").setClass(.metaclassClass).setSuperclass(.streamClass)
        //
        // End of basic hierarchy, now establish the relationships
        //
        self.lookupClass(named: "ArgonModule")?.setClass(.metaclassClass).setSuperclass(.moduleClass)
        self.lookupClass(named: "Array")?.setClass(.metaclassClass).setSuperclass(.indexedCollectionClass)
        self.lookupClass(named: "Assocation")?.setClass(.metaclassClass).setSuperclass(.objectClass)
        self.lookupClass(named: "Atom")?.setClass(.primitiveClass).setSuperclass(.magnitudeClass)
        
        self.lookupClass(named: "Behaviour")?.setClass(.metaclassClass).setSuperclass(.objectClass)
        self.lookupClass(named: "BitSet")?.setClass(.metaclassClass).setSuperclass(.collectionClass)
        self.lookupClass(named: "Boolean")?.setClass(.metaclassClass).setSuperclass(.objectClass)
        self.lookupClass(named: "Byte")?.setClass(.metaclassClass).setSuperclass(.magnitudeClass)
        
        self.lookupClass(named: "Class")?.setClass(.metaclassClass).setSuperclass(.behaviourClass)
        self.lookupClass(named: "Closure")?.setClass(.metaclassClass).setSuperclass(.objectClass)
        self.lookupClass(named: "Collection")?.setClass(.metaclassClass).setSuperclass(.objectClass)
        
        self.lookupClass(named: "Date")?.setClass(.metaclassClass).setSuperclass(.magnitudeClass)
        self.lookupClass(named: "DateTime")?.setClass(.metaclassClass).setSuperclasses(.dateClass,.timeClass)
        self.lookupClass(named: "Dictionary")?.setClass(.metaclassClass).setSuperclass(.keyedCollectionClass)
        self.lookupClass(named: "Directory")?.setClass(.metaclassClass).setSuperclass(.fileClass)
        
        self.lookupClass(named: "Enumeration")?.setClass(.primitiveClass).setSuperclass(.objectClass)
        
        self.lookupClass(named: "File")?.setClass(.metaclassClass).setSuperclass(.objectClass)
        self.lookupClass(named: "FixedPointNumber")?.setClass(.metaclassClass).setSuperclass(.numberClass)
        self.lookupClass(named: "FloatingPointNumber")?.setClass(.metaclassClass).setSuperclass(.numberClass)
        self.lookupClass(named: "Float64")?.setClass(.metaclassClass).setSuperclass(.floatingPointNumberClass)
        self.lookupClass(named: "Float32")?.setClass(.metaclassClass).setSuperclass(.floatingPointNumberClass)
        self.lookupClass(named: "Float16")?.setClass(.metaclassClass).setSuperclass(.floatingPointNumberClass)
        
        self.lookupClass(named: "IdentityDictionary")?.setClass(.metaclassClass).setSuperclass(.dictionaryClass)
        self.lookupClass(named: "IndexedCollection")?.setClass(.metaclassClass).setSuperclass(.collectionClass)
        self.lookupClass(named: "Integer64")?.setClass(.metaclassClass).setSuperclass(.fixedPointNumberClass)
        self.lookupClass(named: "Integer32")?.setClass(.metaclassClass).setSuperclass(.fixedPointNumberClass)
        self.lookupClass(named: "Integer16")?.setClass(.metaclassClass).setSuperclass(.fixedPointNumberClass)
        self.lookupClass(named: "Interval")?.setClass(.metaclassClass).setSuperclass(.objectClass)
        self.lookupClass(named: "IPAddress")?.setClass(.metaclassClass).setSuperclass(.magnitudeClass)
        self.lookupClass(named: "IPv4Address")?.setClass(.metaclassClass).setSuperclass(.ipAddressClass)
        self.lookupClass(named: "IPv6Address")?.setClass(.metaclassClass).setSuperclass(.ipAddressClass)
        
        self.lookupClass(named: "KeyedCollection")?.setClass(.metaclassClass).setSuperclass(.collectionClass)
        self.lookupClass(named: "KeyValueAssociation")?.setClass(.metaclassClass).setSuperclass(.objectClass)
        
        self.lookupClass(named: "List")?.setClass(.metaclassClass).setSuperclass(.collectionClass)
        self.lookupClass(named: "Lock")?.setClass(.metaclassClass).setSuperclass(.objectClass)
        
        self.lookupClass(named: "Magnitude")?.setClass(.metaclassClass).setSuperclass(.objectClass)
        self.lookupClass(named: "Message")?.setClass(.metaclassClass).setSuperclass(.objectClass)
        self.lookupClass(named: "Metaclass")?.setClass(.metaclassClass).setSuperclass(.behaviourClass)
        self.lookupClass(named: "Method")?.setClass(.metaclassClass).setSuperclass(.objectClass)
        self.lookupClass(named: "Module")?.setClass(.metaclassClass).setSuperclass(.collectionClass)
        self.lookupClass(named: "Monitor")?.setClass(.metaclassClass).setSuperclass(.objectClass)
        
        self.lookupClass(named: "Number")?.setClass(.metaclassClass).setSuperclass(.magnitudeClass)
        self.lookupClass(named: "Nothing")?.setClass(.metaclassClass).setSuperclass(.objectClass)
        
        self.lookupClass(named: "Object")?.setClass(.metaclassClass)
        
        self.lookupClass(named: "ReadFile")?.setSuperclass(.fileClass)
        self.lookupClass(named: "ReadStream")?.setSuperclass(.streamClass)
        self.lookupClass(named: "ReadWriteFile")?.setClass(.metaclassClass).setSuperclasses(.readFileClass,.writeFileClass)
        self.lookupClass(named: "ReadWriteStream")?.setClass(.metaclassClass).setSuperclasses(.readStreamClass,.writeStreamClass)
        
        //
        //  ^^^^ The rest were all done as they were created.
        //
        
        self.setClass(.moduleClass)
        }
    }
