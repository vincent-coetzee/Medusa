//
//  File 2.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import MedusaCore
import MedusaStorage

//
//
// An enumeration is stored as a single Integer64 unless it has associatedValues in which
// case it is stored as an Integer64 which packs the class of the enumeration and the
// case index + a flag indicating that there are associated values. The associated values
// are store as a normal object instance.
//
// If there are no associated values the Integer64 is packed as follows
//
//              Sign Bit ( 1 bit )              S                                                                       63
//              Tag ( 4 bits )                   TTTT                                                                   62 Tag = 0110
//              Associated Values Flag (1 bit )      V                                                                  58 Flag = 0
//              Case Index ( 8 bits = 255 )           CC CCCCCC                                                         50 This is the index of the enumeration case
//              Enumeration Class Address ( 50 bits )          AA AAAAAAAA AAAAAAAA AAAAAAAA AAAAAAAA AAAAAAAA AAAAAAAA  0 This contains a shifted pointer to the class of the enumeration
//
// so there is no need to follow the pointer, the enumeration can be used as is and just copied. If, however, the enumeration
// does have associated values, then the Integer64 looks as follows :-
//
//              Sign Bit ( 1 bit )                          S                                                                       63
//              Tag ( 4 bits )                               TTTT                                                                   62 Tag = 0110
//              Associated Values Flag (1 bit )                  A                                                                  58 Flag = 1
//              Address of enumeration instance ( 58 bits )       II IIIIIIII IIIIIIII IIIIIIII IIIIIIII IIIIIIII IIIIIIII IIIIIIII  0 The address of the enumeration instance containing all the details of the enumeration
//
//

public class Enumeration: Instance
    {
    private static let kAssociatedValuesFlagOffset: Unsigned64  = 58
    private static let kClassAddressMask: Unsigned64            = 0b11_11111111_11111111_11111111_11111111_11111111_11111111_11111111
    private static let kCaseIndexMask: Unsigned64               = 0b00000011_11111100_00000000_00000000_00000000_00000000_00000000_00000000
    private static let kAssociatedValuesFlagMask: Unsigned64    = 0b00000100_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    private static let kCaseIndexShift: Unsigned64              = 50
    private static let kCaseIndexBits: Unsigned64               = 0b11111111
    
    private var _objectAddress: ObjectAddress?
    public var caseIndex: Integer64
    public var associatedValues: Instances
    public var instanceAddress: ObjectAddress!
    
    public var objectAddress: MedusaCore.ObjectAddress
        {
        get
            {
//        if self._objectAddress.isNil
//            {
//            fatalError()
////            if self.associatedValues.isEmpty
////                {
//////                let classAddress = (self.class.objectAddress.address & Self.kClassAddressMask) >> ObjectAddress.kObjectIndexShift
//////                let tag = Header.kEnumerationMask
////                self._objectAddress = ObjectAddress(enumerationCaseIndex: self.caseIndex,classAddress: 0)
////                }
////            else
////                {
////                self._objectAddress = ObjectAddress(enumerationInstanceAddress: instanceAddress)
////                }
//            }
//        return(self._objectAddress!)
        fatalError()
        }
        set
            {
            fatalError()
            }
        }
        
    public required init(from buffer: RawPointer,atByteOffset:inout Integer64)
        {
        fatalError()
        }
        
    public func write(into buffer: RawPointer,atByteOffset: inout Integer64)
        {
        fatalError("Unimplemented")
        }
        
    public var description: String
        {
                fatalError()
                }
    
    public var objectHandle: MedusaCore.ObjectHandle
        {
        fatalError()
        }
    
    public var sizeInBytes: MedusaCore.Integer64
        {
        fatalError()
        }
    
    public var _class: Any
        {
        fatalError()
        }
    
    public var isIndexed: MedusaCore.Boolean
        {
        fatalError()
        }
    
    public func write(into: MedusaCore.RawPointer, atByteOffset: MedusaCore.Integer64) {
        fatalError()
    }
    
    public func pack(into: MedusaCore.RawPointer, atByteOffset: MedusaCore.Integer64) {
        fatalError()
    }
    
    public func value(ofSlotAtKey: String) -> any Instance {
        fatalError()
    }
    
    public func setValue(_ value: any Instance, ofSlotAtKey: String) {
        fatalError()
    }
    
    public func isEqual(to: Any) -> Bool {
        fatalError()
    }
    
    public func isLess(than: Any) -> Bool {
        fatalError()
    }
    
    public static func <(lhs: Enumeration,rhs: Enumeration) -> Bool
        {
        fatalError()
        }
        
    public static func ==(lhs: Enumeration,rhs: Enumeration) -> Bool
        {
        fatalError()
        }
        
    public func hash(into: inout Hasher)
        {
        }
        
    }
