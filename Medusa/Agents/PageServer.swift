//
//  PageAgent.swift
//  Xenon
//
//  Created by Vincent Coetzee on 15/11/2023.
//

import Foundation

public class PageServer
    {
    public private(set) static var shared:PageServer!

    private var fileHandle: FileHandle
    private var rootPage: RootPage!
    private let mappedAddress: Address
    
    public init(dataFileHandle: FileHandle)
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
        self.rootPage = RootPage(from: RawPointer(bitPattern: self.mappedAddress)!)
        self.touchColdStartPages()
        }

    private func touchColdStartPages()
        {
        }
        
    public func allocateBTreePage(keyClass: MOPClass,valueClass: MOPClass) -> MOPBTreePage
        {
        }
        
    public func appendFreePage(_ page: Page)
        {
        self.rootPage.app
        }
    }
