//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import MedusaCore
import MedusaPaging

public actor PageServer
    {
    public private(set) static var shared:PageServer!

    private var fileHandle: FileIdentifier
//    private var rootPage: RootPage!
    private let mappedAddress: Integer64
    
    public init(dataFileHandle: FileIdentifier)
        {
        self.fileHandle = dataFileHandle
        self.mappedAddress = dataFileHandle.mappedAddress!
        Self.shared = self
        }
        
    //
    // This initializes the server for the first time.
    //
    public func initServerConfiguration()
        {
        }
    //
    // This loads the server configuation from the database file
    public func loadServerConfiguration()
        {
//        self.rootPage = RootPage(from: RawPointer(bitPattern: self.mappedAddress)!)
        self.touchColdStartPages()
        }

    private func touchColdStartPages()
        {
        }
        
//    public func allocateBTreePage(keyClass: MOPClass,valueClass: MOPClass) -> MOPBTreePage
//        {
//        }
//        
    public func appendFreePage(_ page: Page)
        {
//        self.rootPage.app
        }
    }
