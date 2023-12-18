//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 17/12/2023.
//

import Foundation
import MedusaCore
import MedusaPaging

extension BlockPage
    {
    public convenience init(pageOffset: Integer64,slotClass: Class)
        {
        self.init()
        self.pageOffset = pageOffset
        self.magicNumber = Page.kBlockPageMagicNumber
        self.slotSizeInBytes = slotClass.slotSizeInBytes
        self.slotClassAddress = slotClass.objectAddress
        }
    }
