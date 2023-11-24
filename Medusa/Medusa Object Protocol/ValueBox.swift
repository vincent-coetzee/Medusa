//
//  ValueBox.swift
//  Medusa
//
//  Created by Vincent Coetzee on 24/11/2023.
//

import Foundation

public enum ValueBox
    {
    case integer(Medusa.Integer)
    case string(Medusa.String)
    case float(Medusa.Float)
    case boolean(Medusa.Boolean)
    case enumeration(Medusa.Enumeration)
    case object(MOPClass,MOPObject)
    }
