//
//  Instance.swift
//  
//
//  Created by Vincent Coetzee on 10/12/2023.
//

import Foundation

public protocol Instance: Equatable,Hashable,Comparable
    {
    var description: String { get }
    var objectAddress: ObjectAddress { get set }
    var objectHandle: ObjectHandle { get }
    var objectHash: Integer64 { get }
    var sizeInBytes: Integer64 { get }
    var _class: Any { get set }
    var hasBytes: Boolean { get }
    var isNothing: Boolean { get }
    //
    // Writing is used when the object is being encoded internally. We use
    // an Any for the page because Pages are only defined later in
    // the dependency chain. page is assumed to be an instance of ObjectPage.
    //
    func write(into page: Any,atIndex: Integer64) throws
    func write(into pointer: RawPointer,atByteOffset:inout Integer64) throws
    //
    // Keys and values need to be stored in the BTreePage they are referenced in, so
    // there may be a different way of writing a key or a value.
    //
    func writeKey(into pointer: RawPointer,atByteOffset:inout Integer64) throws
    func writeValue(into pointer: RawPointer,atByteOffset: inout Integer64) throws
    //
    // Packing is used when the object is being encoded into a message buffer,
    // some instance variables will be encoded differently when going into
    // a message buffer.
    //
    func pack(into buffer: RawPointer,atByteOffset:inout Integer64) throws
    func value(ofSlotAtKey: String) -> any Instance
    func setValue(_ value: any Instance,ofSlotAtKey: String)
    func isEqual(to: Any) -> Bool
    func isLess(than: Any) -> Bool
    }

public typealias Instances = Array<any Instance>
