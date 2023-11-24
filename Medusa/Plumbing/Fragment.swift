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
    var elementSizeInBytes: Int { get }
    init(from: PageBuffer,atByteOffset:inout Int)
    func write(to: PageBuffer,atByteOffset:inout Int)
    }
