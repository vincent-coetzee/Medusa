//
//  String+Extensions.swift
//  Medusa
//
//  Created by Vincent Coetzee on 19/11/2023.
//

import Foundation
import Fletcher

extension String: Fragment
    {
    public init(from page: UnsafeMutableRawPointer,atByteOffset:inout Medusa.Integer64)
        {
        self.init()
        self = self.readStringFromPointer(buffer: page,atByteOffset: &atByteOffset)
        }
        
    public func write(to buffer: UnsafeMutableRawPointer,atByteOffset:inout Medusa.Integer64)
        {
        var offset = atByteOffset
        let size = self.count * MemoryLayout<Unicode.Scalar>.size
        print("     WRITING STRING OF SIZE \(size) AT \(offset)")
        writeIntegerWithOffset(buffer,size,&offset)
        let pointer = UnsafeMutablePointer<Unicode.Scalar>.allocate(capacity: 1)
        var stringIndex = self.unicodeScalars.startIndex
        for _ in 0..<self.count
            {
            pointer.pointee = self.unicodeScalars[stringIndex]
            writeUnicodeScalarWithOffset(buffer,pointer,&offset)
            stringIndex = self.unicodeScalars.index(after: stringIndex)
            }
        atByteOffset = offset
        }
    
    public init(from buffer: UnsafeMutableRawPointer,at offset:inout Medusa.Integer64)
        {
        self.init()
        self = self.readStringFromPointer(buffer: buffer,atByteOffset: &offset)
        }
        
    private func readStringFromPointer(buffer: UnsafeMutableRawPointer,atByteOffset offset:inout Int) -> String
        {
        let length = readIntegerWithOffset(buffer,&offset) / MemoryLayout<Unicode.Scalar>.size
        print("     READING STRING OF SIZE \(length) AT \(offset)")
        var newString = String()
        let pointer = UnsafeMutablePointer<Unicode.Scalar>.allocate(capacity: 1)
        defer
            {
            pointer.deallocate()
            }
        for _ in 0..<length
            {
            readUnicodeScalarWithOffset(buffer,pointer,&offset)
            newString.append(Character(pointer.pointee))
            }
        return(newString)
        }
        
    public var sizeInBytes: Int
        {
        return(self.count * MemoryLayout<Unicode.Scalar>.size + 8)
        }
    }
