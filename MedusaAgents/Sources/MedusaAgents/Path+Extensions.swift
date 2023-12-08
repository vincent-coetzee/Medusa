//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import Path

extension Path
    {
    public static func +(lhs: Path,rhs: String) -> Path
        {
        lhs.join(rhs)
        }
    }
