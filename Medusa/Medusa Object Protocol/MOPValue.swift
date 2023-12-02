//
//  MOPObject.swift
//  Medusa
//
//  Created by Vincent Coetzee on 17/11/2023.
//

import Foundation

public enum MOPInstance
    {
    case integer64(Integer64)
    case unsigned64(Unsigned64)
    case float64(Float64)
    case string(String)
    case boolean(Boolean)
    case byte(Byte)
    case unicodeScalar(Medusa.UnicodeScalar)
    case atom(Atom)
    case object(MOPObject)
    case address(Address)
    case enumeration(MOPEnumeration,Integer64,Instances)
    case identifier(Identifier)
    }

