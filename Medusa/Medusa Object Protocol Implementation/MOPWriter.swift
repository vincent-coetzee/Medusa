//
//  MOPEncoder.swift
//  Medusa
//
//  Created by Vincent Coetzee on 17/11/2023.
//

import Foundation

public class MOPWriter: MOPReader
    {
    private let pageAgent: PageAgent
    private var startPage: Page?
    private var pages = Pages()
    private let startOffset: Integer64
    
    public init(pageAgent: PageAgent,startPage: Page?,startOffset: Integer64)
        {
        self.pageAgent = pageAgent
        self.startPage = startPage
        self.startOffset = startOffset
        super.init()
        }
        
    public func encode(_ integer: Medusa.Integer64)
        {

        }
        
    public func encode(_ instance: MOPInstance,usingClass klass: MOPClass,into buffer: UnsafeMutableRawPointer,atByteOffset offset:inout Integer64) throws
        {
        switch(instance,klass)
            {
            case (.nothing,.nothingClass):
                buffer.storeBytes(of: MOPObject.nothing, toByteOffset: offset, as: Integer64.self)
                offset += MemoryLayout<Integer64>.size
            case (.integer64(let integer),.integer64Class):
                buffer.storeBytes(of: integer, toByteOffset: offset, as: Integer64.self)
                offset += MemoryLayout<Integer64>.size
            case .unsigned64(let unsigned):
                buffer.storeBytes(of: unsigned, toByteOffset: offset, as: Unsigned64.self)
                offset += MemoryLayout<Unsigned64>.size
            case .float64(let float):
                buffer.storeBytes(of: float, toByteOffset: offset, as: Float64.self)
                offset += MemoryLayout<Unsigned64>.size
            case .string(let string):
                buffer.storeBytes(of: string.unicodeScalars.count, toByteOffset: offset, as: Integer64.self)
                offset += MemoryLayout<Unsigned64>.size
            case .boolean:
                return(MemoryLayout<Integer64>.size)
            case .byte:
                return(MemoryLayout<Byte>.size)
            case .unicodeScalar:
                return(MemoryLayout<Unicode.Scalar>.size)
            case .atom:
                return(MemoryLayout<Integer64>.size)
            case .object(let object):
                return(object.sizeInBytes)
            case .address:
                return(MemoryLayout<Integer64>.size)
            case .enumeration:
                return(MemoryLayout<Integer64>.size)
            case .identifier(let identifier):
                return(identifier.string.sizeInBytes)
            case .array:
                return(MemoryLayout<Integer64>.size)
            case .fault:
                return(MemoryLayout<Integer64>.size)
            }
        }
    }
