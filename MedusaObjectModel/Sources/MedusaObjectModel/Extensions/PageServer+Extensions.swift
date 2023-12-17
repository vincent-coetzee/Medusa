//
//  File 2.swift
//  
//
//  Created by Vincent Coetzee on 13/12/2023.
//

import Foundation
import MedusaCore
import MedusaStorage
import MedusaPaging

extension PageServer
    {
    public func systemDictionary() throws -> SystemDictionary
        {
        try self.cachedSystemDictionary = SystemDictionary(pageServer: self,address: self.rootPage.systemDictionaryAddress)
        return(self.cachedSystemDictionary as! SystemDictionary)
        }
        
    public func systemModule() throws -> MOMModule
        {
        fatalError()
        }
    }
