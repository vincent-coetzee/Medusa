//
//  KeyEntry.swift
//  Medusa
//
//  Created by Vincent Coetzee on 24/11/2023.
//

import Foundation
import Fletcher

public class KeyEntry<Key,Value>: Fragment where Key:Fragment,Value:Fragment
    {
    public let key: Key
    public let value: Value
    public let pointer: Medusa.PageAddress
    public private(set) var cellOffset: Medusa.Integer64
    
    public var description: String
        {
        self.key.description + " : " + self.value.description + " -> " + String(self.pointer,radix: 16,uppercase: true)
        }
        
    public var sizeInBytes: Int
        {
        // Add extra 16 bytes as a fudge factor to allow for alignment
        MemoryLayout<Medusa.PageAddress>.size + self.key.sizeInBytes + self.value.sizeInBytes
        }
        
    public init(key: Key,value: Value,pointer: Medusa.PagePointer)
        {
        self.key = key
        self.value = value
        self.pointer = pointer
        self.cellOffset = 0
        }
        
    public required init(from buffer: UnsafeMutableRawPointer,atByteOffset:inout Medusa.Integer64)
        {
        print("READING KEY FROM \(atByteOffset)")
        var localOffset = atByteOffset
        self.cellOffset = atByteOffset
        print("     READING POINTER AT \(localOffset)")
        self.pointer = readIntegerWithOffset(buffer,&localOffset)
        print("     READING KEY AT \(localOffset)")
        self.key = Key(from: buffer,atByteOffset: &localOffset)
        print("     READING VALUE AT \(localOffset)")
        self.value = Value(from: buffer,atByteOffset: &localOffset)
        atByteOffset = localOffset
        }
        
    public static func ==(lhs: KeyEntry,rhs: KeyEntry) -> Bool
        {
        lhs.cellOffset == rhs.cellOffset
        }
        
    public func setCellOffset(_ value: Medusa.Offset)
        {
        if value == 0
            {
            print("halt")
            }
        self.cellOffset = value
        }
        
    public static func <(lhs: KeyEntry,rhs: KeyEntry) -> Bool
        {
        lhs.key < rhs.key
        }
        
    public func write(to page: UnsafeMutableRawPointer,atByteOffset:inout Medusa.Integer64)
        {
        print("WRITING OUT KEY ENTRY")
        var localOffset = self.cellOffset
        print("     CELL OFFSET = \(self.cellOffset)")
        if self.cellOffset == 0
            {
            print("halt")
            }
        print("     WRITING POINTER \(self.pointer) AT \(localOffset)")
        let pointerOffset = localOffset
        writeIntegerWithOffset(page,self.pointer,&localOffset)
        let readPointer = readInteger(page,pointerOffset)
        print("     READ POINTER \(readPointer)")
        print("     WRITING KEY OF SIZE \(self.key.sizeInBytes) AT \(localOffset)")
        self.key.write(to: page, atByteOffset: &localOffset)
        print("     WRITING VALUE OF SIZE \(self.value.sizeInBytes) AT \(localOffset)")
        self.value.write(to: page,atByteOffset: &localOffset)
        atByteOffset = localOffset
        }
    }
