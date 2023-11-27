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
        
    internal func writePage(_ page: Page)
        {
        fatalError("Not yet implemented")
        }
        
    internal func readPage(from: Medusa.FileIdentifier,at: Medusa.PageAddress) throws -> Page
        {
        fatalError("Not yet implemented")
        }
    }
