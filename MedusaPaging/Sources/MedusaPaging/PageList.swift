//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 11/12/2023.
//

import Foundation
import MedusaCore

//public typealias PageNodes = Array<PageNode>
//
//public class PageNode
//    {
//    public let pageReference: PageReference
//    public var previousNode: PageNode?
//    public var nextNode: PageNode?
//    
//    public init(pageReference: PageReference,previousNode: PageNode? = nil,nextNode: PageNode? = nil)
//        {
//        self.pageReference = pageReference
//        self.previousNode = previousNode
//        self.nextNode = nextNode
//        }
//        
//    public func nodes(maximumCount: Integer64,matching: (PageReference) -> Bool,orderedBy: (PageNode,PageNode) -> Bool) -> PageNodes
//        {
//        var nodes = PageNodes()
//        var node: PageNode? = self
//        var count = 0
//        while node.isNotNil && count < maximumCount
//            {
//            if matching(node!.pageReference)
//                {
//                nodes.append(node!)
//                count += 1
//                }
//            node = node!.nextNode
//            }
//        return(nodes.sorted(by: orderedBy))
//        }
//    }
//    
//public class PageReference
//    {
//    public var lastAccessTimestamp: Integer64
//        {
//        self.page.isNotNil ? self.page!.lastAccessTimestamp : 0
//        }
//        
//    public var isPageResident: Boolean
//        {
//        self.page.isNotNil
//        }
//        
//    public var freeSpaceInBytes: Integer64
//        {
//        self.page.isNotNil ? self.page!.freeByteCount : self._freeSpaceInBytes!
//        }
//        
//    public var isPageLockedInMemory: Bool
//        {
//        self.page.isNil ? false : self.page!.isLockedInMemory
//        }
//        
//    public var isPageDirty: Boolean
//        {
//        self.page.isNil ? false : self.page!.isDirty
//        }
//        
//    public var pageOffset: Integer64
//        {
//        self.page.isNil ? self._pageOffset! : self.page!.pageOffset
//        }
//        
//    public var nextPageOffset: Integer64
//        {
//        self._nextPageOffset.isNil ? self.page!.nextPageOffset : self._nextPageOffset!
//        }
//        
//    public var previousPageOffset: Integer64
//        {
//        self._previousPageOffset.isNil ? self.page!.previousPageOffset : self._previousPageOffset!
//        }
//        
//    private var _pageOffset: Integer64?
//    public var page: Page?
//    private var _nextPageOffset: Integer64?
//    private var _previousPageOffset: Integer64?
//    private var _freeSpaceInBytes: Integer64?
//    
//    public private(set) var isDirty = false
//    
//    public init(pageOffset: Integer64,previousPageOffset: Integer64,nextPageOffset: Integer64)
//        {
//        self.page = nil
//        self._pageOffset = pageOffset
//        self._nextPageOffset = nextPageOffset
//        self._previousPageOffset = previousPageOffset
//        }
//        
//    public init(page: Page)
//        {
//        self.page = page
//        self._pageOffset = nil
//        }
//        
//    public func setNextPageOffset(_ offset: Integer64?)
//        {
//        self._nextPageOffset = offset
//        self.isDirty = true
//        }
//        
//    public func setPreviousPageOffset(_ offset: Integer64?)
//        {
//        self._previousPageOffset = offset
//        self.isDirty = true
//        }
//        
//    public func flushPage(to file: FileIdentifier) throws
//        {
//        if self._nextPageOffset.isNotNil
//            {
//            self.page!.nextPageOffset = self._nextPageOffset!
//            }
//        if self._previousPageOffset.isNotNil
//            {
//            self.page!.previousPageOffset = self._previousPageOffset!
//            }
//        try page!.store()
//        try file.write(self.page!.buffer, atOffset: self.page!.pageOffset, sizeInBytes: self.page!.sizeInBytes)
//        self._pageOffset = self.page!.pageOffset
//        self.page = nil
//        }
//        
//    public func faultPageIn(from file: FileIdentifier) throws -> Page?
//        {
//        let buffer = try file.readBuffer(atOffset: self.pageOffset, sizeInBytes: Page.kPageSizeInBytes)
//        if let kind = Page.Kind(magicNumber: buffer.load(fromByteOffset: 0, as: Unsigned64.self))
//            {
//            let someClass = kind.pageClass
//            self.page = someClass.init(buffer: buffer,sizeInBytes: Page.kPageSizeInBytes)
//            if self._nextPageOffset.isNotNil
//                {
//                self.page!.nextPageOffset = self._nextPageOffset!
//                }
//            if self._previousPageOffset.isNotNil
//                {
//                self.page!.previousPageOffset = self._previousPageOffset!
//                }
//            return(page)
//            }
//        return(nil)
//        }
//        
//    public func write(toFile file: FileIdentifier) throws
//        {
//        try file.seek(toOffset: self.pageOffset + MemoryLayout<Integer64>.size)
//        try file.write(self.nextPageOffset)
//        try file.write(self.previousPageOffset)
//        }
//        
//    public func lockPageInMemory()
//        {
//        self.page?.lockInMemory()
//        }
//        
//    public func unlockPageInMemory()
//        {
//        self.page?.unlockInMemory()
//        }
//        
//    public func clearOffsets()
//        {
//        self._previousPageOffset = nil
//        self._nextPageOffset = nil
//        }
//        
//    public static func <(lhs: PageReference,rhs: PageReference) -> Bool
//        {
//        lhs.pageOffset < rhs.pageOffset
//        }
//        
//    public static func ==(lhs: PageReference,rhs: PageReference) -> Bool
//        {
//        lhs.pageOffset == rhs.pageOffset
//        }
//    }
//        
public class PageList<P>: Sequence where P:PageProtocol
    {
    public var firstPage: P?
    private var lastPage: P?
    private var startingAtOffset: Integer64
    
    public init(startingAtOffset: Integer64)
        {
        self.startingAtOffset = startingAtOffset
        }
        
    public func insert(_ page: P) where P:PageProtocol
        {
        page.previousPage = self.firstPage
        page.nextPage = self.firstPage?.nextPage
        let oldPage = self.firstPage
        self.firstPage = page
        if oldPage === self.lastPage
            {
            self.lastPage = page
            }
        }
        
    public func append(_ page: P) where P:PageProtocol
        {
        page.previousPage = self.lastPage
        page.nextPage = nil
        self.lastPage?.nextPage = page
        let oldPage = self.lastPage
        self.lastPage = page
        if oldPage === self.firstPage
            {
            self.firstPage = page
            }
        }

    public func findFirstResidentPageWithSpace(sizeInBytes: Integer64) -> P?
        {
        var page = self.firstPage
        while page.isNotNil
            {
            if !page!.isStubbed && page!.freeByteCount >= sizeInBytes
                {
                return(page)
                }
            page = page!.nextPage as? P
            }
        return(nil)
        }
        
    public func findFirstPageWithSpace(sizeInBytes: Integer64) -> P?
        {
        var page = self.firstPage
        while page.isNotNil
            {
            if page!.freeByteCount >= sizeInBytes
                {
                return(page)
                }
            page = page!.nextPage as? P
            }
        return(nil)
        }
        
    public func findFirstStubbedPageWithSpace(sizeInBytes: Integer64) -> P?
        {
        var page = self.firstPage
        while page.isNotNil
            {
            if page!.isStubbed && page!.freeByteCount >= sizeInBytes
                {
                return(page)
                }
            page = page!.nextPage as? P
            }
        return(nil)
        }
        
    public func loadStubList(from file: FileIdentifier) throws -> PageList<P>
        {
        var nextOffset = self.startingAtOffset
        while nextOffset != 0
            {
            let stub = try self.loadPageStub(at: nextOffset,from: file)
            self.append(stub)
            nextOffset = stub.nextPageOffset
            }
        return(self)
        }
        
    private func loadPageStub(at offset: Integer64,from file: FileIdentifier) throws -> P
        {
        let buffer = try file.readBuffer(atOffset: offset, sizeInBytes: Page.kPageStubSizeInBytes)
        let magicNumber = buffer.load(fromByteOffset: 0, as: Unsigned64.self)
        if let kind = Page.Kind(magicNumber: magicNumber)
            {
            let pageClass = kind.pageClass
            let instance = pageClass.init(stubBuffer: buffer,pageOffset: offset,sizeInBytes: Page.kPageStubSizeInBytes) as! P
            return(instance)
            }
        else
            {
            throw(SystemIssue(code: .readingPageStubFoundInvalidPageKind, agentKind: .pageServer))
            }
        }
        
    public func findFirstResidentPage() -> P?
        {
        var page = self.firstPage
        while page.isNotNil
            {
            if !page!.isStubbed
                {
                return(page)
                }
            page = page!.nextPage as? P
            }
        return(nil)
        }
        
    public func findFirstStubbedPage() -> P?
        {
        var page = self.firstPage
        while page.isNotNil
            {
            if page!.isStubbed
                {
                return(page)
                }
            page = page!.nextPage as? P
            }
        return(nil)
        }
    //
    // This method assumes the page being removed is actually in this list
    // and uses its instance variables accordingly.
    //
    public func removePage(page: P)
        {
        if page === self.firstPage
            {
            let oldPage = self.firstPage
            self.firstPage = page.nextPage as? P
            self.firstPage?.previousPage = nil
            if oldPage === self.lastPage
                {
                self.lastPage = page
                }
            }
        else if page === self.lastPage
            {
            let oldPage = self.lastPage
            self.lastPage = page
            if oldPage === self.firstPage
                {
                self.firstPage = self.lastPage
                }
            }
        else
            {
            page.previousPage?.nextPage = page.nextPage
            page.nextPage?.previousPage = page.previousPage
            }
        }
        
    public func makeIterator() -> PageListIterator<P>
        {
        PageListIterator(pageList: self)
        }
    }


public struct PageListIterator<P>: IteratorProtocol where P:PageProtocol
    {
    private let pageList: PageList<P>
    private var page: (any PageProtocol)?
    
    public init(pageList: PageList<P>)
        {
        self.pageList = pageList
        self.page = self.pageList.firstPage
        }
        
    public mutating func next() -> P?
        {
        let somePage = self.page?.nextPage
        let nextPage = self.page
        self.page = somePage
        return(nextPage as? P)
        }
    }
