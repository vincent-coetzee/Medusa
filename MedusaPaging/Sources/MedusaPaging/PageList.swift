//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 11/12/2023.
//

import Foundation
import MedusaCore

public class PageList<P>: Sequence where P:PageProtocol
    {
    public var firstPage: P?
    public var lastPage: P?
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
        
    deinit
        {
        self.release()
        }
        
    public func release()
        {
        self.firstPage?.release()
        self.firstPage = nil
        self.lastPage = nil
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
