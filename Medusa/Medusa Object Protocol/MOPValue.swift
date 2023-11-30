//
//  MOPObject.swift
//  Medusa
//
//  Created by Vincent Coetzee on 17/11/2023.
//

import Foundation

public enum MOPValue
    {
    case integer(Medusa.Integer64)
    case unsigned(Medusa.Unsigned64)
    case float(Medusa.Float)
    case string(Medusa.String)
    case boolean(Medusa.Boolean)
    case byte(Medusa.Byte)
    case unicodeScalar(Medusa.UnicodeScalar)
    case atom(Medusa.Atom)
    case objectId(Medusa.ObjectID)
    case address(Medusa.Address)
    case object(MOPObject)
    }
