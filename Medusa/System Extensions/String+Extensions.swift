//
//  String+Extensions.swift
//  Medusa
//
//  Created by Vincent Coetzee on 19/11/2023.
//

import Foundation

extension String: Fragment
    {
    public init(from page: PageBuffer,atByteOffset:inout Medusa.Integer)
        {
        var offset = atByteOffset
        let count = page.load(fromByteOffset: &offset, as: Medusa.Integer.self)
        let elementSize = page.load(fromByteOffset: &offset,as: Medusa.Integer.self)
        assert(elementSize == MemoryLayout<Unicode.Scalar>.size,"ElementSize should equal size of Unicode.Scalar and it does not.")
        var string = String()
        for _ in 0..<count
            {
            let character = Character(page.load(fromByteOffset: &offset, as: Unicode.Scalar.self))
            string.append(character)
            }
        self = string
        atByteOffset = offset
        }
        
    public func write(to buffer: PageBuffer,atByteOffset:inout Medusa.Integer)
        {
        var offset = atByteOffset
        buffer.storeBytes(of: self.count, atByteOffset: &offset, as: Medusa.Integer.self)
        buffer.storeBytes(of: MemoryLayout<Unicode.Scalar>.size,atByteOffset: &offset,as: Medusa.Integer.self)
        for index in 0..<self.count
            {
            let stringIndex = self.unicodeScalars.index(self.unicodeScalars.startIndex, offsetBy: index)
            buffer.storeBytes(of: self.unicodeScalars[stringIndex],atByteOffset: &offset,as: Unicode.Scalar.self)
            }
        atByteOffset = offset
        }
    
    public init(from pageBuffer: PageBuffer,at offset:inout Medusa.Integer)
        {
        self.init()
        self = pageBuffer.loadString(fromByteOffset: &offset)
        
        }
        
    public var elementSizeInBytes: Int
        {
        Int(MemoryLayout<Unicode.Scalar>.size)
        }
        
    public var sizeInBytes: Int
        {
        return(self.count * self.elementSizeInBytes + 2 * MemoryLayout<Medusa.PageAddress>.alignment)
        }
    }
