//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 18/12/2023.
//

import Foundation
import MedusaCore

public protocol PageProtocol: AnyObject,Equatable
    {
    var pageOffset: Integer64 { get set }
    var nextPageOffset: Integer64 { get set }
    var freeByteCount: Integer64 { get set }
    var nextPage: (any PageProtocol)? { get set }
    var previousPage: (any PageProtocol)? { get set }
    var isStubbed: Bool { get }
    var magicNumber: Unsigned64 { get set }
    init()
    init(stubBuffer: RawPointer,pageOffset: Integer64,sizeInBytes: Integer64)
    func release()
    }
