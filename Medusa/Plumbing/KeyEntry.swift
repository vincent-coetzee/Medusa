//
//  KeyEntry.swift
//  Medusa
//
//  Created by Vincent Coetzee on 24/11/2023.
//

import Foundation

public class KeyEntry<Key,Value>: Fragment where Key:Fragment,Value:Fragment
    {
    public let key: Key
    public let value: Value
    public let pointer: Medusa.PageAddress
    public private(set) var cellOffset: Medusa.Integer
    
    public var description: String
        {
        self.key.description + " : " + self.value.description + " -> " + String(self.pointer,radix: 16,uppercase: true)
        }
        
    public var sizeInBytes: Int
        {
        // Add extra 16 bytes as a fudge factor to allow for alignment
        Int(MemoryLayout<Medusa.PageAddress>.size + MemoryLayout<Medusa.PageAddress>.alignment) + self.key.sizeInBytes + self.value.sizeInBytes
        }
        
    public var elementSizeInBytes: Medusa.Integer
        {
        1
        }
        
    public var alignment: Medusa.Integer
        {
        MemoryLayout<Medusa.PageAddress>.alignment
        }
        
    public init(key: Key,value: Value,pointer: Medusa.PagePointer)
        {
        self.key = key
        self.value = value
        self.pointer = pointer
        self.cellOffset = 0
        }
        
    public required init(from buffer: PageBuffer,atByteOffset:inout Medusa.Integer)
        {
        print("READING KEY FROM \(atByteOffset)")
        var localOffset = atByteOffset
        self.cellOffset = atByteOffset
        print("READING POINTER AT \(localOffset)")
        self.pointer = buffer.load(fromByteOffset: &localOffset, as: Medusa.PageAddress.self)
        print("READING KEY AT \(localOffset)")
        self.key = Key(from: buffer,atByteOffset: &localOffset)
        print("READING VALUE AT \(localOffset)")
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
        
    public func write(to page: PageBuffer,atByteOffset:inout Medusa.Integer)
        {
        print("WRITING OUT KEY ENTRY")
        var localOffset = self.cellOffset
        print("CELL OFFSET = \(self.cellOffset)")
        if self.cellOffset == 0
            {
            print("halt")
            }
        print("WRITING POINTER \(self.pointer) AT \(localOffset)")
        var savedOffset = localOffset
        let readPointer = page.load(fromByteOffset: &savedOffset, as: Medusa.PageAddress.self)
        print("READ POINTER \(readPointer)")
        page.storeBytes(of: Medusa.PageAddress(self.pointer), atByteOffset: &localOffset, as: Medusa.PageAddress.self)
        print("WRITING KEY AT \(localOffset)")
        self.key.write(to: page, atByteOffset: &localOffset)
        print("WRITING VALUE AT \(localOffset)")
        self.value.write(to: page,atByteOffset: &localOffset)
        atByteOffset = localOffset
        }
    }
