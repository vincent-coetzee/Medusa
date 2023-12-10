//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import MedusaCore

public actor PageServer
    {
    private static let kRootPageOffset          = 0
    private static let kRootPageSizeInBytes     = Page.kPageSizeInBytes
    
    public private(set) static var shared:PageServer!
    
    private let dataFile: FileIdentifier
    private let rootPage: RootPage!
    private let logger: Logger
    private var nextAvailableOffset: Integer64 = 0
    
    public static func initialize(with file: FileIdentifier,logger: Logger,dataFileNeedsInitialization: Boolean)
        {
        let server = PageServer(dataFile: file,logger: logger)
        Self.shared = server
        if dataFileNeedsInitialization
            {
            server.initSystemPages()
            }
        server.loadSystemPages()
        }
        
    public init(dataFile: FileIdentifier,logger: Logger)
        {
        self.dataFile = dataFile
        self.rootPage = RootPage()
        self.logger = logger
        self.nextAvailableOffset = Self.kRootPageSizeInBytes

        }
        
    private nonisolated func loadSystemPages()
        {
        self.loadRootPage()
        self.touchColdPages()
        }
        
    private nonisolated func initSystemPages()
        {
        
        }
        
    private nonisolated func loadRootPage()
        {
        self.logger.log("About to read root page of size \(Self.kRootPageSizeInBytes) from offset \(Self.kRootPageOffset).")
        do
            {
            let buffer = try self.dataFile.readBuffer(at: Self.kRootPageOffset,sizeInBytes: Self.kRootPageSizeInBytes)
            }
        catch let error as SystemIssue
            {
            self.logger.log("Loading of root database page with size \(Self.kRootPageSizeInBytes) failed with error \(error.message).")
            fatalError("Medusa could not load the root database page and it can not function without, it will now terminate.")
            }
        catch let error
            {
            self.logger.log("Loading of root database page with size \(Self.kRootPageSizeInBytes) failed with error \(error).")
            fatalError("Medusa could not load the root database page and it can not function without, it will now terminate.")
            }
        self.logger.log("Successfully read root page of size \(Self.kRootPageSizeInBytes) from offset \(Self.kRootPageOffset).")
        }
        
    private nonisolated func touchColdPages()
        {
        }
        
    public nonisolated func initDataFile()
        {
        }
        
    public func loadPage(at offset: Integer64) async throws -> Page
        {
        let buffer = try self.dataFile.readBuffer(at: offset, sizeInBytes: Self.kRootPageSizeInBytes)
        let magicNumber = buffer.load(fromByteOffset: 0, as: Unsigned64.self)
        if magicNumber == Page.kRootPageMagicNumber
            {
            return(RootPage(from: buffer))
            }
        else if magicNumber == Page.kObjectPageMagicNumber
            {
            return(ObjectPage(from: buffer))
            }
        else if magicNumber == Page.kOverlfowPageMagicNumber
            {
            return(OverflowPage(from: buffer))
            }
        else if magicNumber == Page.kBTreePageMagicNumber
            {
            return(BTreePage(from: buffer))
            }
        else if magicNumber == Page.kHashtablePageMagicNumber
            {
            return(HashtablePage(from: buffer))
            }
        else if magicNumber == Page.kHashtableBucketPageMagicNumber
            {
            return(HashtableBucketPage(from: buffer))
            }
        else if magicNumber == Page.kBlockPageMagicNumber
            {
            return(BlockPage(from: buffer))
            }
        else
            {
            fatalError("Invalid page type erad in PageServer.")
            }
        }
        
    public func fetchPage(at offset: Integer64) -> Page
        {
        // search page cache first
        fatalError()
        }
    }
