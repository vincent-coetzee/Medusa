//
//  MedusaPointer.swift
//  Medusa
//
//  Created by Vincent Coetzee on 04/12/2023.
//

import Foundation

public struct MedusaPointer: Equatable,Comparable
    {
    private var rawPointer: UnsafeMutableRawPointer
    private var pageAddress: Address
    private var offset: Integer64 = 0
    
    public init(pageAddress: Address)
        {
        self.pageAddress = pageAddress
        self.rawPointer = UnsafeMutableRawPointer(bitPattern: pageAddress.cleanAddress)!
        }
        
    public var standardHash: Integer64
        {
        self.pageAddress + self.offset
        }
        
    public static func ==(lhs: MedusaPointer,rhs: MedusaPointer) -> Bool
        {
        lhs.pageAddress == rhs.pageAddress && lhs.offset == rhs.offset
        }
        
    public static func <(lhs: MedusaPointer,rhs: MedusaPointer) -> Bool
        {
        lhs.pageAddress < rhs.pageAddress && lhs.offset < rhs.offset
        }
        
    public static func +(lhs: MedusaPointer,rhs:Integer64) -> MedusaPointer
        {
        var newPointer = MedusaPointer(pageAddress: lhs.pageAddress)
        newPointer.offset += rhs
        newPointer.rawPointer = lhs.rawPointer
        return(newPointer)
        }
        
    public static func +=(lhs:inout MedusaPointer,rhs: Integer64)
        {
        lhs.offset += rhs
        }
        
    public mutating func next<T>(_ valueType: T.Type) -> T
        {
        let value = self.rawPointer.load(fromByteOffset: self.offset, as: T.self)
        self.offset += MemoryLayout<T>.size
        return(value)
        }
        
    public mutating func nextPut<T>(_ value: T)
        {
        self.rawPointer.storeBytes(of: value, toByteOffset: self.offset, as: T.self)
        self.offset += MemoryLayout<T>.size
        }
        
    public mutating func nextInteger64() -> Integer64
        {
        let value = self.rawPointer.load(fromByteOffset: self.offset, as: Integer64.self)
        self.offset += MemoryLayout<Integer64>.size
        return(value)
        }
        
    
    }
