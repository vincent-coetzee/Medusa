//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import MedusaCore


    
public class PageServer
    {
    private static let kRootPageOffset          = 0
    
    public private(set) static var shared:PageServer!
    
    private let dataFile: FileIdentifier
    private var rootPage: RootPage!
    private let logger: Logger
    private var nextAvailableOffset: Integer64 = 0
    private var accessLock = NSRecursiveLock()
    private var emptyPageList = EmptyPageList()
    private let residentPages = Array<Page>()
    private let objectPages: PageList
    private let blockPages: PageList
    private let overflowPages: PageList
    
    public static func initialize(with file: FileIdentifier,logger: Logger,dataFileNeedsInitialization: Boolean) throws
        {
        let server = PageServer(dataFile: file,logger: logger)
        Self.shared = server
        if dataFileNeedsInitialization
            {
            server.initSystemPages()
            }
        server.loadSystemData()
        }
        
    public init(dataFile: FileIdentifier,logger: Logger)
        {
        self.dataFile = dataFile
        self.rootPage = RootPage()
        self.logger = logger
        self.nextAvailableOffset = RootPage.kRootPageSizeInBytes
        self.residentObjectPages = PageList()
        self.residentBlockPages = PageList()
        self.residentOverflowPages = PageList()
        }
        
    private func loadSystemData()
        {
//        do
//            {
            self.loadRootPage()
            self.emptyPageList = self.loadEmptyPageList(startingAt: self.rootPage.firstEmptyPageCellOffset)
//            self.load
            self.touchColdPages()
//            }
//        catch let error as SystemIssue
//            {
//            self.logger.log("Error(\(error.code)) \(error.message) laoding system data. Medusa will now terminate.")
//            fatalError("Error(\(error.code)) \(error.message) laoding system data. Medusa will now terminate.")
//            }
//        catch let error
//            {
//            self.logger.log("Unknown error \(error) laoding system data. Medusa will now terminate.")
//            fatalError("Unknown error \(error) laoding system data. Medusa will now terminate.")
//            }
        }
        
    private func initSystemPages()
        {
        do
            {
            self.rootPage = RootPage()
            try self.dataFile.writeBuffer(rootPage.buffer,at: 0,sizeInBytes: RootPage.kRootPageSizeInBytes)
            }
        catch let error as SystemIssue
            {
            self.logger.log("Initialization of root page with size \(RootPage.kRootPageSizeInBytes) failed with error \(error.message).")
            fatalError("Medusa could not initialize the root page and it can not function without it, it will now terminate.")
            }
        catch let error
            {
            self.logger.log("Initialization of root page with size \(RootPage.kRootPageSizeInBytes) failed with unexpected error \(error).")
            fatalError("Medusa could not initialize the root page and it can not function without it, it will now terminate.")
            }
        }
        
    private func loadRootPage()
        {
        self.logger.log("About to read root page of size \(RootPage.kRootPageSizeInBytes) from offset \(Self.kRootPageOffset).")
        do
            {
            let buffer = try self.dataFile.readBuffer(at: Self.kRootPageOffset,sizeInBytes: RootPage.kRootPageSizeInBytes)
            self.rootPage = RootPage(from: buffer)
            }
        catch let error as SystemIssue
            {
            self.logger.log("Loading of root database page with size \(RootPage.kRootPageSizeInBytes) failed with error \(error.message).")
            fatalError("Medusa could not load the root database page and it can not function without, it will now terminate.")
            }
        catch let error
            {
            self.logger.log("Loading of root database page with size \(RootPage.kRootPageSizeInBytes) failed with error \(error).")
            fatalError("Medusa could not load the root database page and it can not function without, it will now terminate.")
            }
        self.logger.log("Successfully read root page of size \(RootPage.kRootPageSizeInBytes) from offset \(Self.kRootPageOffset).")
        }
        
    private func touchColdPages()
        {

        }
        
    public func initDataFile()
        {
        }
        
    private func loadPageList(startingAt offset: Integer64) throws -> PageList
        {
        let pageList = PageList()
        var nextOffset = offset
        while nextOffset != 0
            {
            let pageEntry = try self.loadPageEntry(at: nextOffset)
            pageList.append(pageEntry)
            nextOffset = pageEntry.pageReference.nextPageOffset
            }
        return(pageList)
        }
        
    public func findObjectPage(withFreeSpaceInBytes size: Integer64) -> ObjectPage
        {
        try self.objectPages.findPageWithSpace(sizeInBytes: size)
        }
        
    private func loadPageEntry(at offset: Integer64) throws -> PageList.PageEntry
        {
        if let kind = Page.Kind(magicNumber: try self.dataFile.readUnsigned64(at: offset))
            {
            let nextOffset = try self.dataFile.readInteger64(at: offset + MemoryLayout<Unsigned64>.size)
            let previousOffset = try self.dataFile.readInteger64(at: offset + MemoryLayout<Integer64>.size)
            let pageEntry = PageList.PageEntry(pageReference: PageList.PageReference(pageKind: kind,previousPageOffset: previousOffset,nextPageOffset: nextOffset))
            return(pageEntry)
            }
        throw(SystemIssue(code: .readPageDetailsFailed, agentKind: .pageServer))
        }
        
    public func loadPage(at offset: Integer64) throws -> Page
        {
        self.accessLock.lock()
        defer
            {
            self.accessLock.unlock()
            }
        let buffer = try self.dataFile.readBuffer(at: offset, sizeInBytes: RootPage.kRootPageSizeInBytes)
        let magicNumber = buffer.load(fromByteOffset: 0, as: Unsigned64.self)
        if magicNumber == Page.kRootPageMagicNumber
            {
            return(RootPage(from: buffer))
            }
        else if magicNumber == Page.kObjectPageMagicNumber
            {
            let page = ObjectPage(from: buffer)
            self.residentObjectPages.append(page)
            return(page)
            }
        else if magicNumber == Page.kOverflowPageMagicNumber
            {
            let page = OverflowPage(from: buffer)
            self.residentOverflowPages.append(page)
            return(page)
            }
        else if magicNumber == Page.kBTreeNodePageMagicNumber
            {
            return(BTreeNodePage(from: buffer))
            }
        else if magicNumber == Page.kHashtableRootPageMagicNumber
            {
            return(HashtableRootPage(from: buffer))
            }
//        else if magicNumber == Page.kHashtableBucketPageMagicNumber
//            {
//            return(HashtableBucketPage(from: buffer))
//            }
        else if magicNumber == Page.kBlockPageMagicNumber
            {
            let page = BlockPage(from: buffer)
            self.residentBlockPages.append(page)
            return(page)
            }
        else
            {
            fatalError("Invalid page type erad in PageServer.")
            }
        }
        
    public func allocateBTreePage(keysPerPage: Integer64,keyClass: any KeyType,valueClass: any ValueType) -> BTreeNodePage
        {
        fatalError()
        }
        
    public func findObjectPageWithFreeSpace(sizeInBytes: Integer64)
        {
        }
    }
