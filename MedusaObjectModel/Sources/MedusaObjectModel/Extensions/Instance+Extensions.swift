//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 16/12/2023.
//

import Foundation
import MedusaCore

extension Instance
    {
    public var `class`: Class
        {
        get
            {
            if self.isNothing
                {
                return(Class.nothingClass)
                }
            return(self._class as! Class)
            }
        set
            {
            self._class = newValue
            }
        }
    }
