//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 08/12/2023.
//

import Foundation
import MedusaCore

public class HashtableRootPage: Page
    {
    public var tableEntryCount: Integer64 = 0
    
    open override var kind: Page.Kind
        {
        Page.Kind.hashtableRootPage
        }
    }
