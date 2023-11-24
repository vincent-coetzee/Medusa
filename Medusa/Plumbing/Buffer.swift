//
//  Buffer.swift
//  Medusa
//
//  Created by Vincent Coetzee on 16/11/2023.
//

import Foundation

public protocol Buffer
    {
    var count: Int { get }
    var sizeInBytes: Int { get }
    subscript(_ index: Int) -> Medusa.Byte { get set }
    }