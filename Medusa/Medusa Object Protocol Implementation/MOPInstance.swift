//
//  MOPObject.swift
//  Medusa
//
//  Created by Vincent Coetzee on 17/11/2023.
//

import Foundation

public enum MOPInstance: Comparable,Equatable,Hashable
    {
    case nothing
    case integer64(Integer64)
    case unsigned64(Unsigned64)
    case float64(Float64)
    case string(String)
    case boolean(Boolean)
    case byte(Byte)
    case unicodeScalar(Medusa.UnicodeScalar)
    case atom(Atom)
    case object(MOPObject)
    case address(Address)
    case enumeration(MOPEnumeration,Integer64,Instances)
    case identifier(Identifier)
    case array([Instance])
    case fault(ObjectID)
    
    public var integer64Value: Integer64
        {
        switch(self)
            {
            case(.integer64(let integer)):
                return(integer)
            default:
                fatalError("Called .integer64Value on non Integer64 property.")
            }
        }
        
    public var stringValue: String
        {
        switch(self)
            {
            case(.string(let string)):
                return(string)
            default:
                fatalError("Called .stringValue on non String property.")
            }
        }
        
    public var booleanValue: Boolean
        {
        switch(self)
            {
            case(.boolean(let boolean)):
                return(boolean)
            default:
                fatalError("Called .booleanValue on non Boolean property.")
            }
        }
        
    public var objectValue: MOPObject
        {
        switch(self)
            {
            case(.object(let object)):
                return(object)
            default:
                fatalError("Called .objectValue on non Object property.")
            }
        }
        
    public var rawValue: Int
        {
        switch(self)
            {
            case .nothing:
                return(0)
            case .integer64:
                return(1)
            case .unsigned64:
                return(2)
            case .float64:
                return(3)
            case .string:
                return(4)
            case .boolean:
                return(5)
            case .byte:
                return(6)
            case .unicodeScalar:
                return(7)
            case .atom:
                return(8)
            case .object:
                return(9)
            case .address:
                return(10)
            case .enumeration:
                return(11)
            case .identifier:
                return(12)
            case .array:
                return(13)
            case .fault:
                return(14)
            }
        }
        
    public var standardHash: Int
        {
        switch(self)
            {
            case .nothing:
                return(0)
            case .integer64(let integer):
                return(integer)
            case .unsigned64(let unsigned):
                return(Integer64(bitPattern: unsigned))
            case .float64(let float):
                return(Integer64(bitPattern: float))
            case .string(let string):
                return(string.polynomialRollingHash)
            case .boolean(let boolean):
                return(boolean ? 1 : 0)
            case .byte(let byte):
                return(Integer64(byte))
            case .unicodeScalar(let scalar):
                return(scalar.hashValue)
            case .atom(let atom):
                return(atom)
            case .object(let object):
                return(object.standardHash)
            case .address(let address):
                return(address)
            case .enumeration(let kind,let code,let instances):
                var hasher = Hasher()
                hasher.combine(kind.standardHash)
                hasher.combine(code)
                for instance in instances
                    {
                    hasher.combine(instance.standardHash)
                    }
                return(hasher.finalize())
            case .identifier(let identifier):
                return(identifier.standardHash)
            case .array(let values):
                var hasher = Hasher()
                for value in values
                    {
                    hasher.combine(value.standardHash)
                    }
                return(hasher.finalize())
            case .fault(let id):
                return(Integer64(bitPattern: id))
            }
        }
        
    public var instanceValue: MOPInstance
        {
        self
        }
        
    public var description: String
        {
        switch(self)
            {
            case .nothing:
                return("nothing")
            case .integer64(let integer):
                return("\(integer)")
            case .unsigned64(let unsigned):
                return("\(unsigned)")
            case .float64(let float):
                return("\(float)")
            case .string(let string):
                return(string)
            case .boolean(let boolean):
                return(boolean ? "true" : "false")
            case .byte(let byte):
                return("\(byte)")
            case .unicodeScalar(let scalar):
                return(String(scalar))
            case .atom(let atom):
                return("\(atom)")
            case .object(let object):
                let string = String(object.objectID,radix: 16,uppercase: true)
                return("object(\(string))")
            case .address(let address):
                return(String(address,radix: 16,uppercase: true))
            case .enumeration(let kind,let code,let instances):
                let list = "(" + instances.map{$0.description}.joined(separator: ",") + ")"
                return("\(kind.name)->\(kind.caseName(atIndex: code))\(list)")
            case .identifier(let identifier):
                return(identifier.description)
            case .array(let values):
                let list = "[" + values.map{$0.description}.joined(separator: ",") + "]"
                return(list)
            case .fault(let id):
                return("fault(\(String(id,radix: 16,uppercase: true)))")
            }
        }
        
    //
    // This is the size in bytes needed to actually store the value
    // in an object. Primitives return their actual size whereas
    // some types ( objects,tuples, enumerations ) return the size of
    // a pointer to them ( which is the size of an Integer64 ).
    //
    public var sizeInBytes: Int
        {
        switch(self)
            {
            case .nothing:
                return(MemoryLayout<Integer64>.size)
            case .integer64:
                return(MemoryLayout<Integer64>.size)
            case .unsigned64:
                return(MemoryLayout<Unsigned64>.size)
            case .float64:
                return(MemoryLayout<Float64>.size)
            case .string(let string):
                return(string.sizeInBytes)
            case .boolean:
                return(MemoryLayout<Integer64>.size)
            case .byte:
                return(MemoryLayout<Byte>.size)
            case .unicodeScalar:
                return(MemoryLayout<Unicode.Scalar>.size)
            case .atom:
                return(MemoryLayout<Integer64>.size)
            case .object(let object):
                return(object.sizeInBytes)
            case .address:
                return(MemoryLayout<Integer64>.size)
            case .enumeration:
                return(MemoryLayout<Integer64>.size)
            case .identifier(let identifier):
                return(identifier.string.sizeInBytes)
            case .array:
                return(MemoryLayout<Integer64>.size)
            case .fault:
                return(MemoryLayout<Integer64>.size)
            }
        }
        
    public static func <(lhs: MOPInstance,rhs: MOPInstance) -> Bool
        {
        switch(lhs,rhs)
            {
            case (.nothing,.nothing):
                return(false)
            case (.integer64(let integer1),.integer64(let integer2)):
                return(integer1 < integer2)
            case (.unsigned64(let integer1),.unsigned64(let integer2)):
                return(integer1 < integer2)
            case (.float64(let integer1),.float64(let integer2)):
                return(integer1 < integer2)
            case (.string(let integer1),.string(let integer2)):
                return(integer1 < integer2)
            case (.boolean,.boolean):
                return(false)
            case (.byte(let integer1),.byte(let integer2)):
                return(integer1 < integer2)
            case (.unicodeScalar(let integer1),.unicodeScalar(let integer2)):
                return(integer1 < integer2)
            case (.atom(let integer1),.atom(let integer2)):
                return(integer1 < integer2)
            case (.object(let integer1),.object(let integer2)):
                return(integer1 < integer2)
            case (.address(let integer1),.address(let integer2)):
                return(integer1 < integer2)
            case (.enumeration(let kind1,let code1,_),.enumeration(let kind2,let code2,_)):
                return(kind1 < kind2 && code1 < code2)
            case (.identifier(let id1),.identifier(let id2)):
                return(id1 < id2)
            case (.array(let list1),.array(let list2)):
                for (left,right) in zip(list1,list2)
                    {
                    if left >= right
                        {
                        return(false)
                        }
                    }
                return(true)
            case (.fault(let integer1),.fault(let integer2)):
                return(integer1 < integer2)
            default:
                fatalError("This should not happen.")
            }
        }
        
    public static func ==(lhs: MOPInstance,rhs: MOPInstance) -> Bool
        {
        switch(lhs,rhs)
            {
            case (.nothing,.nothing):
                return(true)
            case (.integer64(let integer1),.integer64(let integer2)):
                return(integer1 == integer2)
            case (.unsigned64(let integer1),.unsigned64(let integer2)):
                return(integer1 == integer2)
            case (.float64(let integer1),.float64(let integer2)):
                return(integer1 == integer2)
            case (.string(let integer1),.string(let integer2)):
                return(integer1 == integer2)
            case (.boolean(let b1),.boolean(let b2)):
                return(b1 == b2)
            case (.byte(let integer1),.byte(let integer2)):
                return(integer1 == integer2)
            case (.unicodeScalar(let integer1),.unicodeScalar(let integer2)):
                return(integer1 == integer2)
            case (.atom(let integer1),.atom(let integer2)):
                return(integer1 == integer2)
            case (.object(let integer1),.object(let integer2)):
                return(integer1 == integer2)
            case (.address(let integer1),.address(let integer2)):
                return(integer1 == integer2)
            case (.enumeration(let kind1,let code1,_),.enumeration(let kind2,let code2,_)):
                return(kind1 == kind2 && code1 == code2)
            case (.identifier(let id1),.identifier(let id2)):
                return(id1 == id2)
            case (.array(let list1),.array(let list2)):
                return(list1 == list2)
            case (.fault(let integer1),.fault(let integer2)):
                return(integer1 == integer2)
            default:
                fatalError("This should not happen.")
            }
        }
        
    public func hash(into hasher: inout Hasher)
        {
        hasher.combine(self.standardHash)
        }
        

    }

