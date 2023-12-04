//
//  MOPObjectValue.swift
//  Medusa
//
//  Created by Vincent Coetzee on 17/11/2023.
//

import Foundation
    
public protocol MOPObject
    {
    static var nothing: ObjectID { get }
    
    var objectID: ObjectID! { get }
    var klass: MOPClass! { get }
    var elementKlass: MOPClass? { get }
    var standardHash: Integer64 { get }
    var isIndexed: Boolean { get }
    var isKeyed: Boolean { get }
    var valueSizeInBytes: Integer64 { get }
    var referenceSizeInBytes: Integer64 { get }
    
    init(ofClass: MOPClass,objectID: ObjectID?,elementsOfClass: MOPClass?)
    init(from: Page,atByteOffset: inout Integer64)
    func isIdentical(to: MOPObject) -> Boolean
    func isEqual(to: MOPObject) -> Boolean
    func isLess(than: MOPObject) -> Boolean
    func writeValue(to: RawBuffer,atByteOffset: inout Integer64)
    func writeReference(to: RawBuffer,atByteOffset: inout Integer64)
    
    subscript(_ index: Integer64) -> Instance { get set }
    subscript(_ key: MOPKey) -> Instance { get set }
    }
    
public protocol MOPIndexedObject: MOPObject
    {
    subscript(_ index: Integer64) -> MOPObject { get set }
    }
    
public protocol MOPKeyedObject: MOPObject 
    {
    subscript(_ key: MOPKey) -> MOPObject { get set }
    }
    
extension MOPObject
    {
    @inlinable
    public static var nothing: ObjectID
        {
        Medusa.kNothing
        }
    }
    
public class MOPObject1: MOPRoot,Equatable,MOPKey
{
    public required init(from: RawBuffer, atByteOffset: inout Integer64)
        {
        fatalError("Unimplemented because this is an abstract class.")
        }
    
    public func isIdentical(to: MOPKey) -> Boolean {
        <#code#>
    }
    
    public func isEqual(to: MOPKey) -> Boolean {
        <#code#>
    }
    
    public func isLess(than: MOPKey) -> Boolean {
        <#code#>
    }
    
    public func writeValue(into buffer: RawBuffer, atByteOffset: inout Integer64) {
        <#code#>
    }
    
    public func writeSlotValue(into buffer: RawBuffer, atByteOffset: inout Integer64) {
        <#code#>
    }
    

    
    public private(set) var objectID: ObjectID!
    public private(set) var klass: MOPClass!
    public private(set) var elementKlass: MOPClass?
    private var _standardHashValue: Integer64 = 0
    
    public var standardHash: Integer64
        {
        Integer64(bitPattern: self.objectID)
        }
        
    public var hasBytes: Bool
        {
        self.klass.hasBytes
        }
        
    public var sizeInBytes: Integer64
        {
        self.klass.sizeInBytes
        }
        
    public static func ==(lhs: MOPObject,rhs: MOPObject) -> Bool
        {
        lhs.objectID == rhs.objectID
        }
        
    public init(ofClass: MOPClass?,objectID: ObjectID? = nil,elementsOfClass: MOPClass? = nil)
        {
        self.klass = ofClass
        self.objectID = objectID
        self.elementKlass = elementsOfClass
        self._standardHashValue = objectID.isNil ?  0 : Integer64(bitPattern: objectID!)
        }
        
    @discardableResult
    public func setClass(_ someClass: MOPClass) -> Self
        {
        self.klass = someClass
        return(self)
        }
        
    public subscript(_ index: Integer64) -> Instance
        {
        get
            {
            fatalError("This should not be invoked on MOPObject")
            }
        set
            {
            fatalError("This should not be invoked on MOPObject")
            }
        }
    }
    
public class MOPPageBasedObject: MOPObject
    {
    public private(set) var page: Page
    public private(set) var byteOffset: Integer64
    
    public init(page: Page,atByteOffset: Integer64)
        {
        self.page = page
        self.byteOffset = atByteOffset
        super.init(
        }
    }
    
public class MOPObjectFault: MOPObject
    {
    }
    
public class MOPObjectInstance: MOPObject
    {
    //
    // Declare instance variables
    //
    public var slotValues = Dictionary<String,MOPInstance>()
    //
    // Define instance methods
    //
    public func instanceValue(ofSlot slotName: String) -> MOPInstance!
        {
        self.slotValues[slotName]!
        }
        
    public func integer64Value(ofSlot: String) -> Integer64
        {
        self.slotValues[ofSlot]!.integer64Value
        }
        
    public func stringValue(ofSlot: String) -> String
        {
        self.slotValues[ofSlot]!.stringValue
        }
        
    public func booleanValue(ofSlot: String) -> Boolean
        {
        self.slotValues[ofSlot]!.booleanValue
        }
        
    public func objectValue(ofSlot: String) -> MOPObject
        {
        self.slotValues[ofSlot]!.objectValue
        }
        
    public func setValue(_ instance: MOPInstance,ofSlot: String)
        {
        self.slotValues[ofSlot] = instance
        }
        
    public func setValue(_ integer: Integer64,ofSlot: String)
        {
        self.slotValues[ofSlot] = .integer64(integer)
        }
        
    public func setValue(_ float: Float64,ofSlot: String)
        {
        self.slotValues[ofSlot] = .float64(float)
        }
        
    public func setValue(_ string: String,ofSlot: String)
        {
        self.slotValues[ofSlot] = .string(string)
        }
        
    public func setValue(_ object: MOPObject,ofSlot: String)
        {
        self.slotValues[ofSlot] = .object(object)
        }
    }
