//
//  File 2.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import MedusaCore
import MedusaStorage
import MedusaPaging

open class MOMDictionary: MOMCollection
    {
    private var tableEntryCount: Integer64 = 0
    private let keyClass: Class!
    private let valueClass: Class!
    private let pageServer: PageServer
    
    public init(pageServer: PageServer,address: ObjectAddress) throws
        {
        self.pageServer = pageServer
        self.keyClass = nil
        self.valueClass = nil
        super.init(inMemorySizeInBytes: 0)
        self.objectAddress = address
        try self.loadDictionary()
        }
        
    public init(pageServer: PageServer,address: ObjectAddress,keyClass: Class,valueClass: Class) throws
        {
        self.keyClass = keyClass
        self.valueClass = keyClass
        self.pageServer = pageServer
        super.init(inMemorySizeInBytes: 0)
        self.tableEntryCount = 0
        self.objectAddress = address
//        super.init(ofClass: Class.dictionaryClass)
        try self.loadDictionary()
        }
        
    public init(pageServer: PageServer) throws
        {
        self.pageServer = pageServer
        self.tableEntryCount = 0
        self.keyClass = Class.objectClass
        self.valueClass = Class.objectClass
        super.init(inMemorySizeInBytes: 0)
//        super.init(ofClass: .dictionaryClass)
        try self.initDictionary()
        }
        
    private func initDictionary()  throws
        {
        let newPage = HashtableRootPage()
        self.tableEntryCount = newPage.freeByteCount / MemoryLayout<Integer64>.size
        newPage.tableEntryCount = self.tableEntryCount
        
        }
        
    private func loadDictionary() throws
        {
//        self.hashmapPage = (try pageServer.loadPage(offset: offset) as! HashtableRootPage)
        }
    }
