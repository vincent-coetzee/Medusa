//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 10/12/2023.
//

import Foundation

public protocol Instance: Equatable,Hashable,Comparable
    {
    var description: String { get }
    var objectAddress: ObjectAddress { get }
    var objectHandle: ObjectHandle { get }
    var sizeInBytes: Integer64 { get }
    var _class: Any { get }
    var isIndexed: Boolean { get }
    //
    // Writing is how instances are stored in Pages. It's a compact storage format but unlike packing
    // which is used for storing objects in buffers for transmission to and from clients. Writing is
    // used when objects are stored in pages or in local buffers. References to other objects are stored
    // as ObjectAddresses and primitives are stored as encoded raw values.
    //
    func write(into: RawPointer,atByteOffset: Integer64)
    func write(into: RawPointer,atByteOffset:inout Integer64)
    //
    // Packing is how instances are stored in a message buffer. It is used when an object is packed into a message
    // buffer for transmission to and from remote clients. References to other objects may be stored as internal
    // references ( because the stored value is actually an offset within the current buffer ) and primitive
    // values are stored in their encoded form.
    //
    func pack(into: RawPointer,atByteOffset: Integer64)
    
    func value(ofSlotAtKey: String) -> any Instance
    func setValue(_ value: any Instance,ofSlotAtKey: String)
    func isEqual(to: Any) -> Bool
    func isLess(than: Any) -> Bool
    }

public typealias Instances = Array<any Instance>
