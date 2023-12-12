//
//  File 2.swift
//  
//
//  Created by Vincent Coetzee on 09/12/2023.
//

import Foundation
import MedusaCore
import MedusaPaging

public class ObjectCatalogue
    {
    public private(set) static var shared: ObjectCatalogue!

    private let pageServer: PageServer
    
    public init(pageServer: PageServer)
        {
        self.pageServer = pageServer
        self.initCatalogue()
        }
        
    private func initCatalogue()
        {
        }
        
    public func makeNewObjectHandle() -> ObjectHandle
        {
        fatalError()
        }
    }
