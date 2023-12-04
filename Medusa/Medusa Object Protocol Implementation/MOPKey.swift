//
//  MOPKey.swift
//  Medusa
//
//  Created by Vincent Coetzee on 04/12/2023.
//

import Foundation

//
//
// MOPKeys are used by the MOP dictionary classes ( MOPDictionary, MOPIdentityDictionary and MOPSystemDictionary )
// to key their elements. We need a MOPKey to do this because due to object proxying and faulting our definition
// of what is equal, idential and less than, differs from Swift's.
//

public protocol MOPKey
    {
    var standardHash: Integer64 { get }
    init(from: RawBuffer,atByteOffset: inout Integer64)
    func isIdentical(to: any MOPKey) -> Boolean
    func isEqual(to: any MOPKey) -> Boolean
    func isLess(than: any MOPKey) -> Boolean
    func writeValue(into buffer: RawBuffer,atByteOffset: inout Integer64)
    func writeSlotValue(into buffer: RawBuffer,atByteOffset: inout Integer64)
    }
