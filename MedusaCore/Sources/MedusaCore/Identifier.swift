////
////  Identifier.swift
////  Argon
////
////  Created by Vincent Coetzee on 14/01/2023.
////
//
//import Foundation
//
//
//        
//public struct Identifier: Hashable, Sequence
//    {
//    public static func ==(lhs: Identifier,rhs: Identifier) -> Bool
//        {
//        if lhs.parts.count != rhs.parts.count
//            {
//            return(false)
//            }
//        for (left,right) in zip(lhs.parts,rhs.parts)
//            {
//            if left != right
//                {
//                return(false)
//                }
//            }
//        return(true)
//        }
//        
//    public static func <(lhs: Identifier,rhs: Identifier) -> Bool
//        {
//        if lhs.parts == rhs.parts
//            {
//            return(false)
//            }
//        for (left,right) in zip(lhs.parts,rhs.parts)
//            {
//            if left >= right
//                {
//                return(false)
//                }
//            }
//        return(true)
//        }
//                
//    public var car: String?
//        {
//        if self.parts.count > 0
//            {
//            return(self.parts.first!)
//            }
//        return(nil)
//        }
//        
//    public var cdr: Identifier
//        {
//        if self.parts.count > 0
//            {
//            return(Identifier(parts: Array(self.parts.dropFirst(1))))
//            }
//        return(Identifier())
//        }
//        
//    public var standardHash: Int
//        {
//        var hasher = Hasher()
//        for part in self.parts
//            {
//            hasher.combine("/")
//            hasher.combine(part)
//            }
//        return(hasher.finalize())
//        }
//        
//    public static let empty = Identifier(parts: [])
//    
//    public static func +(lhs: Identifier,rhs: String) -> Identifier
//        {
//        Identifier(parts: lhs.parts.appending(rhs))
//        }
//        
//    public var description: String
//        {
//        self.parts.map{$0}.joined(separator: "/")
//        }
//     
//    public var firstPart: String
//        {
//        if self.parts.isEmpty
//            {
//            fatalError("There is no first in this identifier")
//            }
//        return(self.parts.first!)
//        }
//
//    public var isEmpty: Bool
//        {
//        return(self.parts.isEmpty)
//        }
//        
//    public var count: Int
//        {
//        return(self.parts.count)
//        }
//        
//    public var lastPart: String
//        {
//        if self.count < 1
//            {
//            fatalError("Attempt to use lastPart of empty identifier.")
//            }
//        return(self.parts.last!)
//        }
//        
//    public var remainingPart: Identifier
//        {
//        if self.isEmpty || self.count == 1
//            {
//            return(Identifier())
//            }
//        return(Identifier(parts: Array(self.parts.dropFirst(1))))
//        }
//        
//    private var parts: Array<String> = []
//    
//    public var isCompoundIdentifier: Bool
//        {
//        self.parts.count > 1
//        }
//        
//    public var isSingleIdentifier: Bool
//        {
//        self.parts.count == 1
//        }
//        
//    internal init(parts: Array<String>)
//        {
//        self.parts = parts
//        }
//        
//    private init()
//        {
//        self.parts = []
//        }
//        
//    internal init(parts: String...)
//        {
//        self.parts = parts
//        }
//        
//    public init(string: String)
//        {
//        if string.isEmpty
//            {
//            self.parts = []
//            }
//        else
//            {
//            self.parts = string.components(separatedBy: "/")
//            }
//        }
//        
//    public var string: String
//        {
//        self.parts.map{$0}.joined(separator: "/")
//        }
//        
//    public subscript(_ index:Int) -> String
//        {
//        self.parts[index]
//        }
//        
//    public func makeIterator() -> IdentifierIterator
//        {
//        IdentifierIterator(identifier: self)
//        }
//        
//    public func storeBytes(in buffer: RawBuffer,atByteOffset: inout Integer64)
//        {
//        buffer.storeBytes(of: self.count,toByteOffset: atByteOffset,as: Integer64.self)
//        atByteOffset += MemoryLayout<Integer64>.size
//        for part in self.parts
//            {
//            part.storeBytes(in: buffer,atByteOffset: &atByteOffset)
//            }
//        }
//    }
//
//extension String.StringInterpolation
//    {
//    public mutating func appendInterpolation(_ identifier: Identifier)
//        {
//        self.appendInterpolation("Parts(\(identifier.description))")
//        }
//    }
//
//public typealias Identifiers = Array<Identifier>
//
//extension Array<String>
//    {
//    public func appending(_ string: String) -> Array<String>
//        {
//        var new = self
//        new.append(string)
//        return(new)
//        }
//    }
//    
//    
//public struct IdentifierIterator: IteratorProtocol
//    {
//    private let identifier: Identifier
//    private var index: Int = 0
//    
//    public init(identifier: Identifier)
//        {
//        self.identifier = identifier
//        }
//        
//    public mutating func next() -> String?
//        {
//        if index < self.identifier.count
//            {
//            let value = self.identifier[index]
//            self.index = index + 1
//            return(value)
//            }
//        return(nil)
//        }
//    }
