//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 09/12/2023.
//

import Foundation

//
//
// This is declared as a struct so we can encapsulate its behaviour without experiencing
// conflicts that would occur if we just typealiased from Unsigned64. Object handles
// uniquely identify objects. If two objects are identical then their ObjectHandles will
// be identical too. An object's handle is stored in Slot 2 in an object. Slot 0 in an object
// is the object's header, Slot 1 is its class pointer, Slot 2 is its handle and Slot 3 is its
// ( standard ) hash. The only sure way to compare two objects for identity is by comparing
// their handles. One could in theory use the object's address but there are some edge cases
// where the ObjectAddresses could point to the same object but not be identical.
//
// ObjectHandles are allocated to an object on creation and are unique across the entire object
// space in Medusa. No matter what happens to an object ( moved, copied, rehomed etc ) its
// ObjectHandle remain the same.
//
// ObjectHandles are used by the storage mechanisms in the Medusa server to identify which objects
// are changed according to the changes sent through from clients in transactions. Different clients could
// have internal copies of the same object and could both propagate changes to the same object
// at the same time. An ObjectHandle allows Medusa to disambiguate these objects.
//
//
public struct ObjectHandle: Equatable
    {
    private var handle: Unsigned64
    
    public static func ==(lhs: ObjectHandle,rhs: ObjectHandle) -> Bool
        {
        lhs.handle == rhs.handle
        }
        
    public static func ===(lhs: ObjectHandle,rhs: ObjectHandle) -> Bool
        {
        lhs.handle == rhs.handle
        }
        
    public init(_ handle: Integer64)
        {
        self.handle = Unsigned64(bitPattern: handle)
        }
    }

