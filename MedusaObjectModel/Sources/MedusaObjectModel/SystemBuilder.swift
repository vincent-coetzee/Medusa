//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 16/12/2023.
//

import Foundation
import MedusaCore
import MedusaPaging

public class SystemBuilder: ObjectWrangler
    {
    private var objectClass: Class!
    private var classClass: Class!
    private var stringClass: Class!
    private var collectionClass: Class!
    private var dictionaryClass: Class!
    private var arrayClass: Class!
    private var moduleClass: Class!
    private var identityDictionaryClass: Class!
    private var systemDictionaryClass: Class!
    private var integer64Class: Class!
    private var float64Class: Class!
    private var unsigned64Class: Class!
    private var booleanClass: Class!
    private var byteClass: Class!
    private var enumerationClass: Class!
    private var magnitudeClass: Class!
    private var numberClass: Class!
    private var slotClass: Class!
    
    public override init(pageServer: PageServer,logger: Logger)
        {
        super.init(pageServer: pageServer,logger: logger)
        self.initBaseClasses()
        }
        
    private func initBaseClasses()
        {
        self.objectClass = self.makeClass(named: "Object",superclass: nil)
        self.slotClass = self.makeClass(named: "Slot",superclass: self.objectClass)
        self.classClass = self.makeClass(named: "Class",superclass: self.objectClass).slot("name",.stringClass).slot("hasBytes",self.booleanClass).slot("slots",self.arrayClass,self.slotClass)
        self.collectionClass = self.makeGenericClass(named: "Collection",superclass: self.objectClass,hasBytes: true)
        self.stringClass = self.makeClass(named: "String",superclass: self.collectionClass)
        self.dictionaryClass = self.makeGenericClass(named: "Dictionary",superclass: self.collectionClass)
        self.moduleClass = self.makeClass(named: "Module",superclass: self.collectionClass).slot("name",self.stringClass).slot("classes",self.arrayClass,self.classClass)
        self.identityDictionaryClass = self.makeGenericClass(named: "IdentityDictionary",superclass: self.dictionaryClass)
        self.systemDictionaryClass = self.makeGenericClass(named: "SystemDictionary",superclass: self.identityDictionaryClass)
        self.magnitudeClass = self.makeClass(named: "Magnitude",superclass: self.objectClass)
        self.numberClass = self.makeClass(named: "Number",superclass: self.magnitudeClass)
        self.stringClass.instanceClass = MOMString.self
        self.dictionaryClass.instanceClass = MOMDictionary.self
        self.identityDictionaryClass.instanceClass = IdentityDictionary.self
        self.moduleClass.instanceClass = MOMModule.self
        self.integer64Class = self.makePrimitiveClass(named: "Integer64",superclass: self.numberClass,primitiveClass: Integer64Class.self)
        self.collectionClass.slot("count",self.integer64Class).slot("capacity",self.integer64Class)
        self.slotClass.slot("name",self.stringClass).slot("class",self.classClass).slot("offset",self.integer64Class)
        self.float64Class = self.makePrimitiveClass(named: "Float64",superclass: self.numberClass,primitiveClass: Integer64Class.self)
        self.unsigned64Class = self.makePrimitiveClass(named: "Unsigned64",superclass: self.numberClass,primitiveClass: Unsigned64Class.self)
        self.byteClass = self.makePrimitiveClass(named: "Byte",superclass: self.magnitudeClass,primitiveClass: ByteClass.self)
        self.booleanClass = self.makePrimitiveClass(named: "Boolean",superclass: self.objectClass,primitiveClass: BooleanClass.self)
        }
     
    private func makeGenericClassInstance(_ generic: Class,generics: Class...) -> Class
        {
        generic.instanciateClass(with: generics)
        }
        
    private func makePrimitiveClass(named: String,superclass: Class,primitiveClass: PrimitiveClass.Type) -> Class
        {
        var someClass = primitiveClass.init(named: named,superclass: superclass)
        if named != "Object"
            {
            someClass.class = self.classClass
            }
        someClass.objectWrangler = self
        return(someClass)
        }
        
    private func makeClass(named: String,superclass: Class? = nil,hasBytes: Boolean = false) -> Class
        {
        var someClass = Class(inMemoryNamed: named, superclass: superclass, hasBytes: hasBytes)
        if named != "Object"
            {
            someClass.class = self.classClass
            }
        someClass.objectWrangler = self
        return(someClass)
        }
        
    private func makeGenericClass(named: String,superclass: Class? = nil,hasBytes: Boolean = false) -> Class
        {
        var someClass = GenericClass(inMemoryNamed: named, superclass: superclass, hasBytes: hasBytes)
        if named != "Object"
            {
            someClass.class = self.classClass
            }
        someClass.objectWrangler = self
        return(someClass)
        }
        
    private func makeStringClass() -> Class
        {
        let someClass = StringClass(inMemoryNamed: "String", superclass: self.objectClass, hasBytes: false)
        someClass.objectWrangler = self
        return(someClass)
        }
        
    private func makeDictionaryClass() -> Class
        {
        let someClass = StringClass(inMemoryNamed: "String", superclass: self.objectClass, hasBytes: false)
        someClass.objectWrangler = self
        return(someClass)
        }
        
    public func makeString(_ string: String) -> MOMString
        {
        MOMString(string: string)
        }
    }
