//
//  Field.swift
//  Medusa
//
//  Created by Vincent Coetzee on 22/11/2023.
//

import Foundation

public class KeyValueEntry
    {
    private let keyHolder: () -> Any
    private let valueHolder: () -> Any
    
    public func key<K>() -> K
        {
        self.keyHolder() as! K
        }
        
    public func value<V>() -> V
        {
        self.valueHolder() as! V
        }
        
    public init<K,V>(key: K,value: V)
        {
        self.keyHolder = { key }
        self.valueHolder = { value }
        }
    }
    
public struct Field
    {
    public enum FieldValue
        {
        public var description: String
            {
            switch(self)
            {
            case .integer(let integer):
                return("\(integer)")
            case .float(let float):
                return(String(format: "%.04lf",float))
            case .string(let string):
                return(string)
            case .magicNumber(let number):
                let string = String(number,radix: 16,uppercase: true)
                return(string)
            case .checksum(let sum):
                return(String(format: "0x%08X",sum))
            case .offset(let offset):
                return("\(offset)")
            case .pagePointer(let pointer):
                let pagePointer = Medusa.PagePointer(pointer)
                return("PAGE(\(pagePointer.pageValue)):OFFSET(\(pagePointer.offsetValue))")
            case .fixedLengthString(let count, let string):
                return("\(count) \(string)")
            case .keyValueEntry(let offset,let pointer,let keyBytes,let valueBytes):
                let sample1 = keyBytes.description.prefix(10)
                let sample2 = keyBytes.description.prefix(10)
                return("\(offset):\(pointer) \(keyBytes.sizeInBytes) \(sample1) \(valueBytes.sizeInBytes) \(sample2)")
            case .freeCell(let offset,let next, let size):
                return("OFFSET(\(offset)) NEXT(\(next)) SIZE(\(size))")
            case .pageAddress(let address):
                return("ADDRESS(\(address))")
                }
            }
        public var sizeInBytes: Int
            {
            switch(self)
                {
                case .integer:
                    return(Int(MemoryLayout<Medusa.Integer>.size))
                case .float:
                    return(Int(MemoryLayout<Medusa.Float>.size))
                case .string(let string):
                    return(Int(MemoryLayout<Int32>.size + string.count * MemoryLayout<Character>.size))
                case .magicNumber:
                    return(Int(MemoryLayout<Medusa.MagicNumber>.size))
                case .checksum:
                    return(Int(MemoryLayout<Medusa.Checksum>.size))
                case .offset:
                    return(Int(MemoryLayout<Int>.size))
                case .pagePointer:
                    return(Int(MemoryLayout<Medusa.PagePointer>.size))
                case .fixedLengthString(let count,_):
                    return(Int((count)))
                case .keyValueEntry(_,_,let key,let value):
                    return(Int(MemoryLayout<Int>.size + MemoryLayout<Medusa.PagePointer>.size + Int(key.sizeInBytes) + Int(value.sizeInBytes)))
                case .freeCell(_,_,let size):
                    return(Int((size)))
                case .pageAddress:
                    return(Int(MemoryLayout<Medusa.PageAddress>.size))
                }
            }
            
        case integer(Medusa.Integer)
        case float(Medusa.Float)
        case string(Medusa.String)
        case magicNumber(Medusa.MagicNumber)
        case checksum(Medusa.Checksum)
        case offset(Int)
        case pagePointer(Medusa.PagePointer)
        case fixedLengthString(Int,String)
        case keyValueEntry(Int,Medusa.PagePointer,Medusa.Bytes,Medusa.Bytes)
        case freeCell(Int,Int,Int)
        case pageAddress(Medusa.PageAddress)
        }
        
    public let index: Int
    public let name: String
    public let value: FieldValue
    public var offset: Int = 0
    
    public init(index: Int,name: String,value: FieldValue,offset: Int = 0)
        {
        self.index = index
        self.name = name
        self.value = value
        self.offset = offset
        }
    }

public class FieldSet
    {
    public var count: Int
        {
        self.fields.count
        }
        
    private var fields = Array<Field>()
    private var offset: Int = 0
    
    public func append(_ field: Field)
        {
        var newField = field
        newField.offset = self.offset
        self.fields.append(newField)
        self.offset += Int(newField.value.sizeInBytes)
        }
        
    public subscript(_ index: Int) -> Field
        {
        self.fields[index]
        }
    }
