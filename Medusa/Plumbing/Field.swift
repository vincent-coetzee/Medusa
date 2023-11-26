//
//  Field.swift
//  Medusa
//
//  Created by Vincent Coetzee on 22/11/2023.
//

import Foundation

//public class KeyValueEntry
//    {
//    private let keyHolder: () -> Any
//    private let valueHolder: () -> Any
//    
//    public func key<K>() -> K
//        {
//        self.keyHolder() as! K
//        }
//        
//    public func value<V>() -> V
//        {
//        self.valueHolder() as! V
//        }
//        
//    public init<K,V>(key: K,value: V)
//        {
//        self.keyHolder = { key }
//        self.valueHolder = { value }
//        }
//    }
    
public struct Field
    {
    public var isBufferBased: Bool
        {
        self.offset != -1
        }
        
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
                let sample1 = String(keyBytes.description.prefix(10))
                let sample2 = String(valueBytes.description.prefix(10))
                return("\(offset)(\(pointer),\(keyBytes.sizeInBytes),\(sample1),\(valueBytes.sizeInBytes),\(sample2))")
            case .freeCell(let offset,let next, let size):
                return("OFFSET(\(offset)) NEXT(\(next)) SIZE(\(size))")
            case .pageAddress(let address):
                return("ADDRESS(\(address))")
            case .bytes(let bytes):
                return("BYTES(\(bytes.sizeInBytes))")
                }
            }
        public var sizeInBytes: Int
            {
            switch(self)
                {
                case .integer:
                    return(Int(MemoryLayout<Medusa.Integer64>.size))
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
                case .bytes(let bytes):
                    return(bytes.sizeInBytes)
                }
            }
            
        case integer(Medusa.Integer64)
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
        case bytes(Medusa.Bytes)
        }
        
    public typealias SectionRange = Range<Int>
    
    public struct Section:Equatable
        {
        let startRow: Int
        let startColumn: Int
        let stopRow: Int
        let stopColumn: Int
        
        public static func ==(lhs: Section,rhs: Section) -> Bool
            {
            lhs.startRow == rhs.startRow && lhs.startColumn == rhs.startColumn && lhs.stopRow == rhs.stopRow && lhs.stopColumn == rhs.stopColumn
            }
            
        public func startOffset(rowWidth: Int) -> Int
            {
            self.startRow * rowWidth + self.startColumn
            }
            
        public func stopOffset(rowWidth: Int) -> Int
            {
            self.stopRow * rowWidth + self.stopColumn
            }
        }
        
    public var stopOffset: Int
        {
        self.offset + self.value.sizeInBytes
        }
        
    public var startOffset: Int
        {
        self.offset
        }
        
    public let index: Int
    public let name: String
    public let value: FieldValue
    public var offset: Int = -1
    
    public init(index: Int,name: String,value: FieldValue,offset: Int = -1)
        {
        self.index = index
        self.name = name
        self.value = value
        self.offset = offset
        if offset == 0
            {
            print("halt")
            }
        }
        
//    public func sections(withRowWidth rowWidth: Int) -> Array<Section>?
//        {
//        if self.offset == -1
//            {
//            return(nil)
//            }
//        let length = self.value.sizeInBytes
//        var start = self.offset % rowWidth
//        var index = self.offset
//        let stop = self.offset + length
//        let column = self.offset % rowWidth
//        let row = self.offset / rowWidth
//        if column + length < rowWidth
//            {
//            return([Section(startRow: row, startColumn: column, stopRow: row, stopColumn: column + length)])
//            }
//        var sections = Array<Section>()
//        while index < stop
//            {
//            let sectionLength = min(rowWidth - start,stop - index)
//            var stopRow = (index + sectionLength) / rowWidth
//            stopRow = stopRow == rowWidth ? stopRow : stopRow - 1
//            sections.append(Section(startRow: index / rowWidth, startColumn: index % rowWidth, stopRow: stopRow, stopColumn: rowWidth - (index + sectionLength) % rowWidth))
//            index += sectionLength
//            start = index % rowWidth
//            }
//        return(sections)
//        }
        
    public func sections(withRowWidth rowWidth: Int) -> Array<Section>
        {
        if self.offset == -1
            {
            fatalError("Should not have been called on this object.")
            }
        let length = self.value.sizeInBytes
        var index = self.offset
        let stop = self.offset + length
        var column  = self.offset % rowWidth
        var row = self.offset / rowWidth
        var sections = Array<Section>()
        while index < stop
            {
            let sectionLength = min(rowWidth - column,stop - index)
            sections.append(Section(startRow: row, startColumn: column, stopRow: row, stopColumn: column + sectionLength))
            index += sectionLength
            row += 1
            column = index % rowWidth
            }
        return(sections)
        }
    }

public class FieldSet: Sequence
    {
    public var count: Int
        {
        self.fields.count
        }
        
    public let name: String
    private var fields = Array<Field>()
    
    public init(name: String)
        {
        self.name = name
        }
        
    public func append(_ field: Field)
        {
        var newField = field
        self.fields.append(newField)
        }
        
    public subscript(_ index: Int) -> Field
        {
        self.fields[index]
        }
        
    public func append(contentsOf: FieldSet)
        {
        self.fields.append(contentsOf: contentsOf.fields)
        }
        
    public func makeIterator() -> FieldSetIterator
        {
        FieldSetIterator(fieldSet: self)
        }
    }

public struct FieldSetIterator: IteratorProtocol
    {
    private let fieldSet: FieldSet
    private var index: Int = 0
    
    public init(fieldSet: FieldSet)
        {
        self.fieldSet = fieldSet
        }
        
    public mutating func next() -> Field?
        {
        if index < self.fieldSet.count
            {
            let value = self.fieldSet[index]
            self.index = index + 1
            return(value)
            }
        return(nil)
        }
    }

public typealias FieldSetList = Dictionary<String,FieldSet>
