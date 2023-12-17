//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 10/12/2023.
//

import Foundation
import MedusaCore
import MedusaStorage
import MedusaPaging

public extension BTreeNodePage
    {
    var keyClass: Class
        {
        get
            {
            self._keyClass as! Class
            }
        set
            {
            self._keyClass = newValue as! KeyType
            }
        }
        
    var valueClass: Class
        {
        get
            {
            self._valueClass as! Class
            }
        set
            {
            self._valueClass = newValue as! ValueType
            }
        }
    }
