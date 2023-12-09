//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 09/12/2023.
//

import Foundation

public class AnnotatedBytes: Bytes
    {
    public enum AnnotationKind
        {
        case integer64
        case float64
        case boolean
        case byte
        case bytes
        case string
        case nothing
        case composite
        case unsigned64
        case integer64Value(Integer64)
        case unsigned64Value(Unsigned64)
        case booleanValue(Boolean)
        
        public var isValue: Boolean
            {
            switch(self)
                {
                case .integer64Value:
                    return(true)
                case .unsigned64Value:
                    return(true)
                case .booleanValue:
                    return(true)
                default:
                    return(false)
                }
            }
        }
        
    public enum AnnotationValue
        {
        case integer64(Integer64)
        case float64(Float64)
        case boolean(Boolean)
        case byte(Byte)
        case bytes(Bytes)
        case string(String)
        case nothing
        case composite
        case unsigned64(Unsigned64)
        
        public var sizeInBytes: Integer64
            {
            switch(self)
                {
                case .integer64:
                    return(MemoryLayout<Integer64>.size)
                case .float64:
                    return(MemoryLayout<Float64>.size)
                case .boolean:
                    return(MemoryLayout<Boolean>.size)
                case .byte:
                    return(MemoryLayout<Byte>.size)
                case .unsigned64:
                    return(MemoryLayout<Unsigned64>.size)
                case .bytes(let bytes):
                    return(bytes.sizeInBytes)
                case .string(let string):
                    return(MemoryLayout<Integer64>.size + string.count * MemoryLayout<UnicodeScalar>.size)
                default:
                    return(MemoryLayout<Integer64>.size)
                }
            }
            
        public var description:String
            {
            switch(self)
                {
                case .unsigned64(let value):
                    return("\(value)")
                case .integer64(let value):
                    return("\(value)")
                case .float64(let value):
                    return("\(value)")
                case .boolean(let value):
                    return("\(value)")
                case .bytes(let value):
                    return(value.description)
                case .byte(let value):
                    return(String(value,radix: 16, uppercase: true))
                case .string(let value):
                    return(value)
                case .nothing:
                    return("nothing")
                case .composite:
                    fatalError("This should not be called on an annotation of kind .composite.")
                }
            }
        }
        
    public typealias Annotations = Dictionary<String,Annotation>
            
    public class Section:Equatable
        {
        public var frame: CGRect!
        public let startRow: Int
        public let startColumn: Int
        public let stopRow: Int
        public let stopColumn: Int
        public let annotation: Annotation
        
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
            
        public init(annotation: Annotation,startRow: Int,stopRow: Int,startColumn: Int,stopColumn: Int)
            {
            self.annotation = annotation
            self.startRow = startRow
            self.stopRow = stopRow
            self.stopColumn = stopColumn
            self.startColumn = startColumn
            }
        }
        
    public class Annotation
        {
        public var allAnnotations: Array<Annotation>
            {
            [self]
            }
            
        public var isValidElementAnnotation: Bool
            {
            false
            }

            
        public let key: String
        public let kind: AnnotationKind
        
        public init(key: String,kind: AnnotationKind)
            {
            self.key = key
            self.kind = kind
            }
            
        public func description(in buffer: RawPointer) -> String
            {
            "Annotation(\(self.key),\(kind))"
            }
            
        public func sizeInBytes(in buffer: RawPointer) -> Integer64
            {
            return(0)
            }
            
        public func compositeAnnotation(atKey: String) -> CompositeAnnotation?
            {
            return(nil)
            }
            
        public func annotation(atKey: String) -> Annotation?
            {
            return(nil)
            }
            
        public var stopOffset: Int
            {
            0
            }
            
        public var startOffset: Int
            {
            0
            }
            
        public var description: String
            {
            ""
            }
            
        public var sizeInBytes: Integer64
            {
            0
            }
            
        public var value: AnnotationValue
            {
            .nothing
            }
            
        public func sections(withRowWidth rowWidth: Int) -> Array<Section>
            {
            []
            }
            
        public var isValue: Bool
            {
            self.kind.isValue
            }
        }
        
    public class ElementAnnotation: Annotation
        {
        public override var isValidElementAnnotation: Bool
            {
            self.byteOffset != -1
            }
            
        public let byteOffset: Integer64
        public let bytes: AnnotatedBytes
        
        public init(bytes: AnnotatedBytes,key: String,kind: AnnotationKind,byteOffset: Integer64 = -1)
            {
            self.bytes = bytes
            self.byteOffset = byteOffset
            super.init(key: key,kind: kind)
            }
            
        public override var stopOffset: Int
            {
            self.byteOffset + self.value.sizeInBytes
            }
            
        public override var startOffset: Int
            {
            self.byteOffset
            }
            
        public override var description: String
            {
            self.value.description
            }
            
        public override var sizeInBytes: Integer64
            {
            self.value.sizeInBytes
            }
        
        public override var value: AnnotationValue
            {
            if self.byteOffset == -1
                {
                fatalError()
                }
            switch(self.kind)
                {
                case .integer64:
                    return(.integer64(self.bytes.bytesPointer.load(fromByteOffset: self.byteOffset, as: Integer64.self)))
                case .integer64Value(let value):
                    return(.integer64(value))
                case .booleanValue(let value):
                    return(.boolean(value))
                case .unsigned64Value(let value):
                    return(.unsigned64(value))
                case .unsigned64:
                    return(.unsigned64(self.bytes.bytesPointer.load(fromByteOffset: self.byteOffset, as: Unsigned64.self)))
                case .float64:
                     return(.float64(self.bytes.bytesPointer.load(fromByteOffset: self.byteOffset, as: Float64.self)))
                case .boolean:
                    return(.boolean(self.bytes.bytesPointer.load(fromByteOffset: self.byteOffset, as: Boolean.self)))
                case .bytes:
                    let size = self.bytes.bytesPointer.load(fromByteOffset: self.byteOffset, as: Integer64.self)
                    let someBytes = Bytes(from: self.bytes.bytesPointer,atByteOffset: self.byteOffset + MemoryLayout<Integer64>.size,sizeInBytes: size)
                    return(.bytes(someBytes))
                case .byte:
                    return(.byte(self.bytes.bytesPointer.load(fromByteOffset: self.byteOffset, as: Byte.self)))
                case .string:
                    let count = self.bytes.bytesPointer.load(fromByteOffset: self.byteOffset, as: Integer64.self)
                    var string = ""
                    for index in (self.byteOffset + MemoryLayout<Integer64>.size)..<(self.byteOffset + MemoryLayout<Integer64>.size + count)
                        {
                        string.append(Character(self.bytes.bytesPointer.load(fromByteOffset: index, as: UnicodeScalar.self)))
                        }
                    return(.string(string))
                case .nothing:
                    return(.nothing)
                case .composite:
                    fatalError("This should not be called on an annotation of kind .composite.")
                }
            }
            
//        public override func sizeInBytes(in buffer: RawPointer) -> Integer64
//            {
//            if self.byteOffset == -1
//                {
//                return(0)
//                }
//            switch(self.kind)
//                {
//                case .integer64:
//                    return(MemoryLayout<Integer64>.size)
//                case .float64:
//                    return(MemoryLayout<Float64>.size)
//                case .boolean:
//                    return(MemoryLayout<Boolean>.size)
//                case .byte:
//                    return(MemoryLayout<Byte>.size)
//                case .bytes:
//                    return(buffer.load(fromByteOffset: self.byteOffset, as: Integer64.self))
//                case .string:
//                    return(buffer.load(fromByteOffset: self.byteOffset, as: Integer64.self))
//                case .nothing:
//                    return(MemoryLayout<Integer64>.size)
//                case .composite:
//                    fatalError("This should not be called on an annotation of kind .composite.")
//                }
//            }
            
        public override func sections(withRowWidth rowWidth: Int) -> Array<Section>
            {
            if self.byteOffset == -1
                {
                fatalError("Should not have been called on this object.")
                }
            let length = self.value.sizeInBytes
            var index = self.byteOffset
            let stop = self.byteOffset + length
            var column  = self.byteOffset % rowWidth
            var row = self.byteOffset / rowWidth
            var sections = Array<Section>()
            while index < stop
                {
                let sectionLength = Swift.min(rowWidth - column,stop - index)
                sections.append(Section(annotation: self,startRow: row, stopRow: row,startColumn: column,stopColumn: column + sectionLength))
                index += sectionLength
                row += 1
                column = index % rowWidth
                }
            return(sections)
            }
        }

    public class CompositeAnnotation: Annotation,Sequence
        {
        public override var allAnnotations: Array<Annotation>
            {
            var all = Array<Annotation>()
            for annotation in self.annotations.values
                {
                all.append(contentsOf: annotation.allAnnotations)
                }
            return(all)
            }
            
        fileprivate var annotations = Annotations()
        
        public init(key: String)
            {
            super.init(key: key,kind: .composite)
            }
            
        public func append(bytes: AnnotatedBytes,key: String,kind: AnnotationKind,atByteOffset: Integer64 = -1)
            {
            self.annotations[key] = ElementAnnotation(bytes: bytes,key: key, kind: kind, byteOffset: atByteOffset)
            }
            
        public func append(_ annotation: Annotation)
            {
            self.annotations[annotation.key] = annotation
            }
            
        public override func compositeAnnotation(atKey: String) -> CompositeAnnotation?
            {
            if let annotation = self.annotations[atKey] as? CompositeAnnotation
                {
                return(annotation)
                }
            else
                {
                for annotation in self.annotations.values
                    {
                    if let value = annotation.compositeAnnotation(atKey: atKey)
                        {
                        return(value)
                        }
                    }
                return(nil)
                }
            }
            
        public override func annotation(atKey: String) -> Annotation?
            {
            self.annotations[atKey]
            }
            
        public func makeIterator() -> AnnotationIterator
            {
            AnnotationIterator(annotations: self.allAnnotations)
            }
        }
        
    public var annotations: CompositeAnnotation = CompositeAnnotation(key: "Annotations")
    
    public func appendAnnotation(key: String,kind: AnnotationKind,atByteOffset: Integer64 = -1)
        {
        self.annotations.append(bytes: self,key: key,kind: kind,atByteOffset: atByteOffset)
        }
        
    public func annotation(atKey: String) -> Annotation?
        {
        if let value = self.annotations.annotation(atKey: atKey)
            {
            return(value)
            }
        for annotation in self.annotations
            {
            if let value = annotation.annotation(atKey: atKey)
                {
                return(value)
                }
            }
        return(nil)
        }
    }


public struct AnnotationIterator: IteratorProtocol
    {
    private let annotations: Array<AnnotatedBytes.Annotation>
    private var index: Int = 0
    
    public init(annotations: Array<AnnotatedBytes.Annotation>)
        {
        self.annotations = annotations
        }
        
    public mutating func next() -> AnnotatedBytes.Annotation?
        {
        if index < self.annotations.count
            {
            let value = self.annotations[index]
            self.index = index + 1
            return(value)
            }
        return(nil)
        }
    }
