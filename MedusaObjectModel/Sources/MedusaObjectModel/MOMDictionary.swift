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
    public class BucketList
        {
        }
        
    private var tableEntryCount: Integer64
    private let keyClass: Class
    private let valueClass: Class
    private let pageServer: PageServer
    private var hashmapPage: HashtableRootPage!
    private let bucketList: PageList!
    
    public init(pageServer: PageServer,at offset: Integer64,keyClass: Class,valueClass: Class) throws
        {
        self.keyClass = keyClass
        self.valueClass = keyClass
        self.pageServer = pageServer
        self.tableEntryCount = 0
        self.bucketList = PageList()
        super.init(ofClass: .dictionaryClass)
        try self.loadDictionary(at: offset)
        }
        
    public init(pageServer: PageServer) throws
        {
        self.pageServer = pageServer
        self.tableEntryCount = 0
        self.bucketList = PageList()
        self.keyClass = Class.objectClass
        self.valueClass = Class.objectClass
        super.init(ofClass: .dictionaryClass)
        try self.initDictionary()
        }
        
    private func initDictionary()  throws
        {
        let newPage = HashtableRootPage()
        self.tableEntryCount = newPage.freeByteCount / MemoryLayout<Integer64>.size
        newPage.tableEntryCount = self.tableEntryCount
        
        }
        
    private func loadDictionary(at offset: Integer64) throws
        {
        self.hashmapPage = (try pageServer.loadPage(at: offset) as! HashtableRootPage)
        
        }
    }
