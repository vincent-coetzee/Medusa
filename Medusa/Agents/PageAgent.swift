//
//  PageAgent.swift
//  Xenon
//
//  Created by Vincent Coetzee on 15/11/2023.
//

import Foundation

public class PageAgent: BaseAgent
    {
    public class func nextAvailableAgent() -> PageAgent
        {
        fatalError("Not yet implemented")
        }
        
    public override func boot()
        {
        self.name = "Pager"
        super.boot()
        self.loadColdStartPages()
        }
        
    private func loadColdStartPages()
        {
        }
        
    internal func initializeFile(withPath: String)
        {
        }
        
    internal func writePage(_ page: Page)
        {
        fatalError("Not yet implemented")
        }
        
    internal func readPage(from: FileIdentifier,at: Medusa.Address) throws -> Page
        {
        fatalError("Not yet implemented")
        }
        
    internal func readBTreePage<K,V>(from: FileIdentifier,at: Medusa.Address,keyType: K.Type,valueType: V.Type) throws -> BTreePage<K,V>
        {
        fatalError("Not yet implemented")
        }
        
    internal func allocatePageAddress(fileIdentifier: FileIdentifier) throws -> Medusa.Address
        {
        fatalError("Not yet implemented")
        }
        
    internal func allocatePage(fileIdentifier: FileIdentifier,sizeInBytes: Int) throws -> Medusa.Buffer
        {
        fatalError("Not yet implemented")
        }
        
    internal func allocateBTreePage<K,V>(fileIdentifier: FileIdentifier,magicNumber: Medusa.MagicNumber,keysPerPage: Medusa.Integer64,keyType: K.Type,valueType: V.Type) throws -> BTreePage<K,V>
        {
        fatalError("Not yet implemented")
        }
    }
