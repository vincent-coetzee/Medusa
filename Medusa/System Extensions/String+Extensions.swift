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
    public var standardHash: Int
        {
        // this is a PolynomialRollingHash hacked to work with Unicode.Scalars, not sure how correct it is
        let p:Int64 = Int64(Int32.max) // there are Int32.max possible Unicode.Scalar values
        let m:Int64 = Int64(1e9) + 9
        var powerOfP:Int64 = 1
        var hashValue:Int64 = 0
        for char in self.unicodeScalars
            {
            hashValue = (hashValue + Int64(char.value) * powerOfP) % m
            powerOfP = (powerOfP * p) % m
            }
        return(Int(hashValue) & Integer64.maximum)
        }
    
    public var instanceValue: MOPInstance
        {
        .string(self)
        }
    
    public init(from page: UnsafeMutableRawPointer,atByteOffset:inout Medusa.Integer64)
        {
        self.init()
        self = self.readStringFromPointer(buffer: page,atByteOffset: &atByteOffset)
        }
        
    public var polynomialRollingHash:Int
        {
        self.standardHash
        }
        
    public func write(to buffer: UnsafeMutableRawPointer,atByteOffset:inout Medusa.Integer64)
        {
        var offset = atByteOffset
        assert(offset >= 0 && offset < Medusa.kPageSizeInBytes,"Offset should be >= 0 and less than \(Medusa.kPageSizeInBytes)")
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
        assert(offset >= 0 && offset < Medusa.kPageSizeInBytes,"Offset should be >= 0 and < \(Medusa.kPageSizeInBytes)")
        let length = readIntegerWithOffset(buffer,&offset) / MemoryLayout<Unicode.Scalar>.size
        assert(length >= 0 && length < Medusa.kMaximumStringLength,"String length should be >= 0 and < \(Medusa.kMaximumStringLength) but is \(length)")
        print("     READING STRING OF LENGTH \(length / MemoryLayout<Unicode.Scalar>.size) SIZE IN BYTES \(length) AT \(offset)")
        var newString = String()
        let pointer = UnsafeMutablePointer<Unicode.Scalar>.allocate(capacity: 1)
        defer
            {
            pointer.deallocate()
            }
        for _ in 0..<length / MemoryLayout<Unicode.Scalar>.size
            {
            readUnicodeScalarWithOffset(buffer,pointer,&offset)
            newString.append(Character(pointer.pointee))
            }
        return(newString)
        }
        
    public func storeBytes(in buffer: RawBuffer,atByteOffset: inout Integer64)
        {
        self.write(to: buffer,atByteOffset: &atByteOffset)
        }
        
    public var sizeInBytes: Int
        {
        return(self.count * MemoryLayout<Unicode.Scalar>.size + 8)
        }
    }
