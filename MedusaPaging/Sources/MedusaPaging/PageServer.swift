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
    
    private var nextAvailableOffset: Integer64
        {
        get
            {
            var offset = self.rootPage.endPageOffset
            self.rootPage.endPageOffset = offset + Page.kPageSizeInBytes
            return(offset)
            }
        }
    
    public  var cachedSystemDictionary: Any?
    public  var cachedSystemModule: Any?
    private var accessLock = NSRecursiveLock()
    private var freePages: PageList<Page>!
    private var pageCache = Dictionary<Integer64,Page>()
    private var objectPages: PageList<ObjectPage>!
    private var blockPages: PageList<BlockPage>!
    private var overflowPages: PageList<OverflowPage>!
    private var btreeRootPages: PageList<BTreeRootPage>!
    private let dataFile: FileIdentifier
    public var rootPage: RootPage!
    private let logger: Logger
    
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
        }
        
    private func loadSystemData()
        {
        do
            {
            self.loadRootPage()
            self.freePages = try PageList<Page>(startingAtOffset: self.rootPage.firstFreePageOffset).loadStubList(from: self.dataFile)
            self.objectPages = try PageList<ObjectPage>(startingAtOffset: self.rootPage.firstObjectPageOffset).loadStubList(from: self.dataFile)
            self.blockPages = try PageList<BlockPage>(startingAtOffset: self.rootPage.firstBlockPageOffset).loadStubList(from: self.dataFile)
            self.overflowPages = try PageList<OverflowPage>(startingAtOffset: self.rootPage.firstOverflowPageOffset).loadStubList(from: self.dataFile)
            self.btreeRootPages = try PageList<BTreeRootPage>(startingAtOffset: self.rootPage.firstBTreeRootPageOffset).loadStubList(from: self.dataFile)
            self.touchColdPages()
            }
        catch let error as SystemIssue
            {
            self.logger.log("Error(\(error.code)) \(error.message) laoding system data. Medusa will now terminate.")
            fatalError("Error(\(error.code)) \(error.message) loading system data. Medusa will now terminate.")
            }
        catch let error
            {
            self.logger.log("Unknown error \(error) laoding system data. Medusa will now terminate.")
            fatalError("Unknown error \(error) laoding system data. Medusa will now terminate.")
            }
        }
        
    private func initSystemPages()
        {
        do
            {
            self.rootPage = RootPage()
            self.rootPage.endPageOffset = Page.kPageSizeInBytes
            //
            // Set up 2 object pages
            //
            let firstObjectPage = ObjectPage()
            firstObjectPage.pageOffset = self.nextAvailableOffset
            let secondObjectPage = ObjectPage()
            secondObjectPage.pageOffset = self.nextAvailableOffset
            firstObjectPage.previousPage = nil
            firstObjectPage.nextPage = secondObjectPage
            secondObjectPage.previousPage = firstObjectPage
            secondObjectPage.nextPage = nil
            self.rootPage.firstObjectPageOffset = firstObjectPage.pageOffset
            try self.dataFile.write(firstObjectPage.buffer,atOffset: firstObjectPage.pageOffset,sizeInBytes: Page.kPageSizeInBytes)
            try self.dataFile.write(secondObjectPage.buffer,atOffset: firstObjectPage.pageOffset,sizeInBytes: Page.kPageSizeInBytes)
            //
            // Set up 2 free pages
            //
            let firstFreePage = Page()
            firstFreePage.pageOffset = self.nextAvailableOffset
            let secondFreePage = Page()
            secondFreePage.pageOffset = self.nextAvailableOffset
            firstFreePage.previousPage = nil
            firstFreePage.nextPage = secondFreePage
            secondFreePage.previousPage = firstFreePage
            secondFreePage.nextPage = nil
            self.rootPage.firstFreePageOffset = firstFreePage.pageOffset
            try self.dataFile.write(firstFreePage.buffer,atOffset: firstFreePage.pageOffset,sizeInBytes: Page.kPageSizeInBytes)
            try self.dataFile.write(secondFreePage.buffer,atOffset: secondFreePage.pageOffset,sizeInBytes: Page.kPageSizeInBytes)
            //
            // Set up 2 block pages
            //
            let firstBlockPage = BlockPage()
            firstBlockPage.pageOffset = self.nextAvailableOffset
            let secondBlockPage = BlockPage()
            secondBlockPage.pageOffset = self.nextAvailableOffset
            firstBlockPage.previousPage = nil
            firstBlockPage.nextPage = secondBlockPage
            secondBlockPage.previousPage = firstBlockPage
            secondBlockPage.nextPage = nil
            self.rootPage.firstBlockPageOffset = firstBlockPage.pageOffset
            try self.dataFile.write(firstBlockPage.buffer,atOffset: firstBlockPage.pageOffset,sizeInBytes: Page.kPageSizeInBytes)
            try self.dataFile.write(secondBlockPage.buffer,atOffset: secondBlockPage.pageOffset,sizeInBytes: Page.kPageSizeInBytes)
            self.rootPage.firstOverflowPageOffset = 0
            self.rootPage.firstBTreeRootPageOffset = 0
            try self.dataFile.write(rootPage.buffer,atOffset: 0,sizeInBytes: RootPage.kRootPageSizeInBytes)
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
            let buffer = try self.dataFile.readBuffer(atOffset: Self.kRootPageOffset,sizeInBytes: RootPage.kRootPageSizeInBytes)
            self.rootPage = RootPage(buffer: buffer,sizeInBytes: RootPage.kRootPageSizeInBytes)
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
        
    public func firstFreePageStub() -> Page
        {
        fatalError()
        }
        
    public func firstObjectPageStub() -> Page
        {
        fatalError()
        }
        
    public func firstBlockPageStub() -> Page
        {
        fatalError()
        }
        
    public func firstOverflowPageStub() -> Page
        {
        fatalError()
        }
        
    public func firstBTreeRootPageStub() -> Page
        {
        fatalError()
        }
        
    public func loadContents(of page: Page) throws
        {
        if page.isStubbed
            {
            try page.loadContents(from: self.dataFile)
            }
        }
        
    public func objectPointer(forAddress address: ObjectAddress) -> RawPointer
        {
        let page = self.loadObjectPage(at: address.pageOffset)
        let offset = page.objectOffset(at: address.objectIndex)
        return(page.buffer + offset)
        }
        
    public func loadObjectPage(at offset: Integer64) -> ObjectPage
        {
        fatalError()
        }
        
    public func loadPage<T>(at offset: Integer64,as type: T.Type) -> T where T:PageProtocol
        {
        fatalError()
        }
    
    public func allocateObjectPage() -> ObjectPage
        {
        self.accessLock.lock()
        defer
            {
            self.accessLock.unlock()
            }
        return(ObjectPage())
        }
        
    public func findObjectPage(withFreeSpaceInBytes size: Integer64) -> ObjectPage?
        {
        self.accessLock.lock()
        defer
            {
            self.accessLock.unlock()
            }
        if let page = self.objectPages.findFirstPageWithSpace(sizeInBytes: size)
            {
            if page.isStubbed
                {
                do
                    {
                    try page.loadContents(from: self.dataFile)
                    return(page)
                    }
                catch let issue as SystemIssue
                    {
                    logger.log("Error \(issue.code) while loading contents of stubbed page at \(page.pageOffset) \(issue.message).")
                    }
                catch let error
                    {
                    logger.log("Error \(error) while loading contents of stubbed page at \(page.pageOffset).")
                    }
                return(nil)
                }
            return(page)
            }
        else
            {
            let newPage = ObjectPage()
            newPage.pageOffset = self.nextAvailableOffset
            self.pageCache[newPage.pageOffset] = newPage
            do
                {
                try self.dataFile.write(newPage.buffer,atOffset: newPage.pageOffset,sizeInBytes: Page.kPageSizeInBytes)
                }
            catch let issue as SystemIssue
                {
                logger.log("Error \(issue.code) while writing contents of new page at \(newPage.pageOffset) \(issue.message).")
                }
            catch let error
                {
                logger.log("Error \(error) while writing contents of new page at \(newPage.pageOffset).")
                }
            }
        fatalError()
        }
        
    public func allocateBTreeNodePage(keysPerPage: Integer64,keyClass: Any,valueClass: Any) -> BTreeNodePage
        {
        fatalError()
        }
    }
