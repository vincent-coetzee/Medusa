//
//  Buffer.swift
//  Medusa
//
//  Created by Vincent Coetzee on 16/11/2023.
//

import Foundation

public protocol Buffer
    {
    var rawPointer: UnsafeMutableRawPointer { get }
    var fields: CompositeField { get }
    var sizeInBytes: Int { get }
    func flush()
    func bytes(atByteOffset: Int,sizeInBytes: Int) -> Array<Medusa.Byte>
    func allocate(sizeInBytes: Int) throws -> Int
    func deallocate(at: Int) throws
    subscript(_ index: Int) -> Medusa.Byte { get set }
    }
    
extension Buffer
    {
    public func bytes(atByteOffset: Int,sizeInBytes: Int) -> Array<Medusa.Byte>
        {
        var bytes = Array<Medusa.Byte>()
        for index in atByteOffset..<atByteOffset + sizeInBytes
            {
            bytes.append(self[index])
            }
        return(bytes)
        }
    }
