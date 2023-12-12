//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import MedusaCore

public class BlockPage: Page
    {
    public private(set) var totalSlotCount: Integer64       = 0
    public private(set) var slotCount: Integer64            = 0
    public private(set) var nextBlockPageOffset: Integer64  = 0
    public private(set) var slotSizeInBytes: Integer64      = 0
    
    open override var kind: Page.Kind
        {
        Page.Kind.blockPage
        }
    }
