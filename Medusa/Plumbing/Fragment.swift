//
//  Chunk.swift
//  Medusa
//
//  Created by Vincent Coetzee on 24/11/2023.
//

import Foundation

public protocol Fragment: Comparable
    {
    var description: String { get }
    var sizeInBytes: Int { get }
    init(from: UnsafeMutableRawPointer,atByteOffset:inout Int)
    func write(to: UnsafeMutableRawPointer,atByteOffset:inout Int)
    }
