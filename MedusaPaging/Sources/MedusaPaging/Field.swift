//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import MedusaCore

public class Field: Sequence
    {
    public var sections = Array<Section>()
        
    public var flattenedFields: Fields
        {
        [self]
        }
        
    public var isBufferBased: Bool
        {
        self.offset != -1
        }
        
    public var count: Integer64
        {
        1
        }
        
    public var fields: Array<Field>
        {
        [self]
        }
        
    public enum FieldValue
        {
        public var description: String
            {
            switch(self)
            {
            case .empty:
                return("nil")
            case .integer(let integer):
                return("\(integer)")
            case .boolean(let integer):
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
            case .fixedLengthString(let count, let string):
                return("\(count) \(string)")
            case .keyValueEntry(let offset,let pointer,let keyBytes,let valueBytes):
                let sample1 = String(keyBytes.description.prefix(10))
                let sample2 = String(valueBytes.description.prefix(10))
                return("\(offset)(\(pointer),\(keyBytes.sizeInBytes),\(sample1),\(valueBytes.sizeInBytes),\(sample2))")
            case .address(let address):
                return("ADDRESS(\(address))")
            case .bytes(let bytes):
                return("BYTES(\(bytes.sizeInBytes))")
                }
            }
        public var sizeInBytes: Int
            {
            switch(self)
                {
                case .empty:
                    return(0)
                case .integer:
                    return(MemoryLayout<Integer64>.size)
                case .boolean:
                    return(MemoryLayout<Boolean>.size)
                case .float:
                    return(MemoryLayout<Float64>.size)
                case .string(let string):
                    return(MemoryLayout<Int32>.size + string.count * MemoryLayout<Character>.size)
                case .magicNumber:
                    return(MemoryLayout<MagicNumber>.size)
                case .checksum:
                    return(MemoryLayout<Checksum>.size)
                case .offset:
                    return(MemoryLayout<Int>.size)
                case .fixedLengthString(let count,_):
                    return(count)
                case .keyValueEntry(_,_,let key,let value):
                    return(MemoryLayout<Int>.size + MemoryLayout<Integer64>.size + Int(key.sizeInBytes) + Int(value.sizeInBytes))
                case .address:
                    return(MemoryLayout<Address>.size)
                case .bytes(let bytes):
                    return(bytes.sizeInBytes)
                }
            }
            
        case empty
        case integer(Integer64)
        case boolean(Boolean)
        case float(Float64)
        case string(String)
        case magicNumber(MagicNumber)
        case checksum(Checksum)
        case offset(Int)
        case fixedLengthString(Int,String)
        case keyValueEntry(Int,Integer64,Bytes,Bytes)
        case address(Address)
        case bytes(Bytes)
        }
        
    public typealias SectionRange = Range<Int>
    
    public class Section:Equatable
        {
        var frame: CGRect!
        let startRow: Int
        let startColumn: Int
        let stopRow: Int
        let stopColumn: Int
        let field: Field
        
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
            
        public init(field: Field,startRow: Int,stopRow: Int,startColumn: Int,stopColumn: Int)
            {
            self.field = field
            self.startRow = startRow
            self.stopRow = stopRow
            self.stopColumn = stopColumn
            self.startColumn = startColumn
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
        
    public var description: String
        {
        self.value.description
        }
        
    public var sizeInBytes: Integer64
        {
        self.value.sizeInBytes
        }
        
//    public func description(in buffer: Buffer) -> String
//        {
//        switch(self.value)
//            {
//            case .integer:
//                let integer = readInteger(buffer.rawPointer,self.startOffset)
//                return(String(integer,radix: 10))
//            default:
//                return(self.value.description)
//            }
//        }
        
    public let name: String
    public let value: FieldValue
    public var offset: Int = -1
    
    public init(name: String,value: FieldValue,offset: Int = -1)
        {
        self.name = name
        self.value = value
        self.offset = offset
        }
    
    public init(name: String,offset: Integer64 = -1)
        {
        self.name = name
        self.value = .empty
        self.offset = offset
        }
        
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
            let sectionLength = Swift.min(rowWidth - column,stop - index)
            sections.append(Section(field: self,startRow: row, stopRow: row,startColumn: column,stopColumn: column + sectionLength))
            index += sectionLength
            row += 1
            column = index % rowWidth
            }
        return(sections)
        }
        
    public subscript(_ index: Int) -> Field
        {
        if index == 0
            {
            return(self)
            }
        fatalError()
        }
        
   public func append(_ field: Field)
        {
        fatalError()
        }
        
    public func makeIterator() -> FieldIterator
        {
        FieldIterator(field: self)
        }
        
    public func compositeField(named: String) -> CompositeField?
        {
        nil
        }
    }
    
public class CompositeField: Field
    {
    public override var flattenedFields: Fields
        {
        self.fields.flatMap{$0.flattenedFields}
        }
        
    public override var count: Integer64
        {
        self._fields.count
        }
        
    public override var fields: Array<Field>
        {
        self._fields
        }
        
    private var _fields = Array<Field>()
    
    public override var description: String
        {
        self._fields.map{$0.description}.joined(separator: " ")
        }
        
    public override var sizeInBytes: Integer64
        {
        self._fields.reduce(0) {$0 + $1.sizeInBytes}
        }
        
    public override func sections(withRowWidth rowWidth: Int) -> Array<Section>
        {
        var sections = Array<Section>()
        for field in self._fields
            {
            sections.append(contentsOf: field.sections(withRowWidth: rowWidth))
            }
        return(sections)
        }
        
    public override subscript(_ index: Int) -> Field
        {
        self._fields[index]
        }
        
   public override func append(_ field: Field)
        {
        self._fields.append(field)
        }
        
    public func append(contentsOf fields: Fields)
        {
        for field in fields
            {
            self._fields.append(field)
            }
        }
        
    public override func compositeField(named: String) -> CompositeField?
        {
        if self.name == named
            {
            return(self)
            }
        for field in self._fields
            {
            if field.name == named
                {
                return(field as? CompositeField)
                }
            if let found = field.compositeField(named: named)
                {
                return(found)
                }
            }
        return(nil)
        }
    }

public struct FieldIterator: IteratorProtocol
    {
    private let field: Field
    private var index: Int = 0
    
    public init(field: Field)
        {
        self.field = field
        }
        
    public mutating func next() -> Field?
        {
        if index < self.field.count
            {
            let value = self.field[index]
            self.index = index + 1
            return(value)
            }
        return(nil)
        }
    }

public typealias FieldList = Dictionary<String,Field>

public typealias Fields = Array<Field>

extension Fields
    {
    public func compositeField(named: String) -> CompositeField?
        {
        for field in self
            {
            if field.name == named
                {
                return(field as? CompositeField)
                }
            }
        return(nil)
        }
        
    public mutating func append(contentsOf fields: Fields)
        {
        for field in fields
            {
            self.append(field)
            }
        }
        
    public var flattened: Self
        {
        self.flatMap{$0.fields}
        }
    }
