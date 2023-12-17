//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 14/12/2023.
//

import Foundation

import MedusaCore
import MedusaStorage
import MedusaPaging

public extension ObjectPage
    {
    //
    // This method assumes a size check has already been on the page and that there
    // is sufficient space in both the object table and the bytes space for the
    // object is questions.
    //
    public func allocateObject(ofClass: Class) -> any Instance
        {
        fatalError()
        }
    }
