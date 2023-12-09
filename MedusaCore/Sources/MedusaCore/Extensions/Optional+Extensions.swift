//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 06/12/2023.
//

import Foundation

extension Optional
    {
    public var isNotNil: Bool
        {
        switch(self)
            {
            case .none:
                return(false)
            case .some:
                return(true)
            }
        }
        
    public var isNil: Bool
        {
        switch(self)
            {
            case .none:
                return(true)
            case .some:
                return(false)
            }
        }
    }
