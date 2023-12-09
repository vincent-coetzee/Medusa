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
        }
        
    public typealias Annotations = Dictionary<String,Annotation>
            
    public class Section:Equatable
        {
        var frame: CGRect!
        let startRow: Int
        let startColumn: Int
        let stopRow: Int
        let stopColumn: Int
        let annotation: Annotation
        
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
        }
        
    public class ElementAnnotation: Annotation
        {
        public let byteOffset: Integer64
        
        public init(key: String,kind: AnnotationKind,byteOffset: Integer64 = -1)
            {
            self.byteOffset = byteOffset
            super.init(key: key,kind: kind)
            }
            
        public override func description(in buffer: RawPointer) -> String
            {
            if self.byteOffset == -1
                {
                return("")
                }
            switch(self.kind)
                {
                case .integer64:
                    let value = buffer.load(fromByteOffset: self.byteOffset, as: Integer64.self)
                    return("\(value)")
                case .float64:
                     let value = buffer.load(fromByteOffset: self.byteOffset, as: Float64.self)
                    return("\(value)")
                case .boolean:
                    let value = buffer.load(fromByteOffset: self.byteOffset, as: Boolean.self)
                    return("\(value)")
                case .bytes:
                    let size = buffer.load(fromByteOffset: self.byteOffset, as: Integer64.self)
                    let bytes = Bytes(from: buffer,atByteOffset: self.byteOffset,sizeInBytes: size)
                    var string = ""
                    for byte in bytes
                        {
                        string += String(byte,radix:16,uppercase: true) + " "
                        }
                    return(string)
                case .byte:
                    let value = buffer.load(fromByteOffset: self.byteOffset, as: Byte.self)
                    return("\(value)")
                case .string:
                    let count = buffer.load(fromByteOffset: self.byteOffset, as: Integer64.self)
                    var string = ""
                    for index in (self.byteOffset + MemoryLayout<Integer64>.size)..<(self.byteOffset + MemoryLayout<Integer64>.size + count)
                        {
                        string.append(Character(buffer.load(fromByteOffset: index, as: UnicodeScalar.self)))
                        }
                    return(string)
                case .nothing:
                    return("nothing")
                case .composite:
                    fatalError("This should not be called on an annotation of kind .composite.")
                }
            }
            
        public override func sizeInBytes(in buffer: RawPointer) -> Integer64
            {
            if self.byteOffset == -1
                {
                return(0)
                }
            switch(self.kind)
                {
                case .integer64:
                    return(MemoryLayout<Integer64>.size)
                case .float64:
                    return(MemoryLayout<Float64>.size)
                case .boolean:
                    return(MemoryLayout<Boolean>.size)
                case .byte:
                    return(MemoryLayout<Byte>.size)
                case .bytes:
                    return(buffer.load(fromByteOffset: self.byteOffset, as: Integer64.self))
                case .string:
                    return(buffer.load(fromByteOffset: self.byteOffset, as: Integer64.self))
                case .nothing:
                    return(MemoryLayout<Integer64>.size)
                case .composite:
                    fatalError("This should not be called on an annotation of kind .composite.")
                }
            }
            
        public func sections(in buffer: RawPointer,withRowWidth rowWidth: Int) -> Array<Section>
            {
            if self.byteOffset == -1
                {
                fatalError("Should not have been called on this object.")
                }
            let length = self.sizeInBytes(in: buffer)
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
            
        public func append(key: String,kind: AnnotationKind,atByteOffset: Integer64 = -1)
            {
            self.annotations[key] = ElementAnnotation(key: key, kind: kind, byteOffset: atByteOffset)
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
        self.annotations.append(key: key,kind: kind,atByteOffset: atByteOffset)
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
