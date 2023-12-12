//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 11/12/2023.
//

import Foundation
import MedusaCore

public class PageList: Sequence
    {
    public class PageReference
        {
        public var lastAccessTimestamp: Integer64
            {
            self.page.isNotNil ? self.page!.lastAccessTimestamp : 0
            }
            
        public var isPageResident: Boolean
            {
            self.page.isNotNil
            }
            
        public var freeByteCount: Integer64
            {
            self.page.isNotNil ? self.page!.freeByteCount : 0
            }
            
        public var isPageLockedInMemory: Bool
            {
            self.page.isNil ? false : self.page!.isLockedInMemory
            }
            
        public var isPageDirty: Boolean
            {
            self.page.isNil ? false : self.page!.isDirty
            }
            
        public var pageOffset: Integer64
            {
            self.page.isNil ? self._pageOffset! : self.page!.pageOffset
            }
            
        public var pageKind: Page.Kind
            {
            self.page.isNil ? self._pageKind! : self.page!.kind
            }
            
        public var nextPageOffset: Integer64
            {
            self.page.isNil ? self._nextPageOffset! : self.page!.nextPageOffset
            }
            
        public var previousPageOffset: Integer64
            {
            self.page.isNil ? self._previousPageOffset! : self.page!.previousPageOffset
            }
            
        public var _pageOffset: Integer64?
        public var page: Page?
        public var _pageKind: Page.Kind?
        public var _nextPageOffset: Integer64?
        public var _previousPageOffset: Integer64?
        
        public init(pageKind: Page.Kind,previousPageOffset: Integer64,nextPageOffset: Integer64)
            {
            self._pageKind = pageKind
            self._nextPageOffset = nextPageOffset
            self._previousPageOffset = previousPageOffset
            }
            
        public init(page: Page)
            {
            self.page = page
            self._pageOffset = nil
            }
            
        public func flushPage(to file: FileIdentifier) throws
            {
            try file.writeBuffer(self.page!.buffer, at: self.page!.pageOffset, sizeInBytes: self.page!.sizeInBytes)
            self._pageOffset = self.page!.pageOffset
            self.page = nil
            }
            
        public func lockPageInMemory()
            {
            self.page?.lockInMemory()
            }
            
        public func unlockPageInMemory()
            {
            self.page?.unlockInMemory()
            }
        }
        
    //
    // Page entries hold references because the pages may not all be resident
    // and there might be an external process that flushes or removes pages
    // which means if the entry held onto the page, that page might no longer be valid.
    // Using a page reference allows an external process holding on to the reference
    // to dump the page for whatever reason and not screw up the page entries.
    // Additonally pages might be held in more that one page list at the same time
    // there might, for example be a global page list holding on to a page
    // and a specific list holding on to the same page. This way both lists
    // can hold onto a reference and manipualte the page safely.
    //
    public class PageEntry: Equatable
        {
        public var isPageResident: Boolean
            {
            self.pageReference.isPageResident
            }
            
        public var freeByteCount: Integer64
            {
            self.pageReference.freeByteCount
            }
            
        public var pageOffset: Integer64
            {
            self.pageReference.pageOffset
            }
            
        public var pageReference: PageReference
        public var nextEntry: PageEntry?
        public var previousEntry: PageEntry?
        
        public init(pageReference: PageReference,previousEntry: PageEntry? = nil,nextEntry: PageEntry? = nil)
            {
            self.pageReference = pageReference
            self.previousEntry = previousEntry
            self.nextEntry = nextEntry
            }
            
        public static func ==(lhs: PageEntry,rhs: PageEntry) -> Bool
            {
            lhs.pageReference.pageOffset == rhs.pageReference.pageOffset
            }
            
        public func clearEntries()
            {
            self.nextEntry = nil
            self.previousEntry = nil
            }
        }
        
    public var firstEntry: PageEntry?
    private var lastEntry: PageEntry?
    private var startingAtOffset: Integer64 = 0
    private var pageEntriesByPageOffset = Dictionary<Integer64,PageEntry>()
    
    public init()
        {
        self.firstEntry = nil
        self.lastEntry = nil
        }
        
    public func append(_ pageEntry: PageEntry)
        {
        self.pageEntriesByPageOffset[pageEntry.pageOffset] = pageEntry
        if self.firstEntry.isNil
            {
            self.startingAtOffset = pageEntry.pageReference.pageOffset
            self.firstEntry = pageEntry
            pageEntry.nextEntry = nil
            pageEntry.previousEntry = nil
            self.lastEntry = self.firstEntry
            }
        else
            {
            let someEntry = self.lastEntry
            self.lastEntry = pageEntry
            self.lastEntry!.previousEntry = someEntry
            someEntry!.nextEntry = pageEntry
            
            }
        }
        
    public func append(_ page: Page)
        {
        self.append(PageEntry(pageReference: PageReference(page: page)))
        }
        
//    @discardableResult
//    public func addPageReference(_ pageReference: PageReference) -> PageReference
//        {
//        if self.firstEntry.isNil
//            {
//            self.firstEntry = PageEntry(pageReference: pageReference,previousEntry: nil,nextEntry: nil)
//            self.lastEntry = self.firstEntry
//            }
//        else
//            {
//            self.lastEntry = PageEntry(pageReference: pageReference,previousEntry: self.lastEntry,nextEntry: nil)
//            }
//        return(pageReference)
//        }
        
    public func findPageWithSpace(sizeInBytes: Integer64) -> Page?
        {
        for entry in self where entry.isPageResident
            {
            if entry.pageReference.freeByteCount >= sizeInBytes
                {
                return(entry.pageReference.page!)
                }
            }
        return(nil)
        }
        
    @discardableResult
    public func removePage(at offset: Integer64) -> PageReference
        {
        }
        
    @discardableResult
    public func removePage(page: Page) -> PageReference?
        {
        for entry in self
            {
            if entry.pageReference.pageOffset == page.pageOffset
                {
                if entry == self.firstEntry
                    {
                    self.firstEntry = entry.nextEntry
                    entry.clearEntries()
                    return(entry.pageReference)
                    }
                else if entry == self.lastEntry
                    {
                    self.lastEntry = entry.previousEntry
                    entry.clearEntries()
                    }
                else
                    {
                    entry.previousEntry?.nextEntry = entry.nextEntry
                    entry.nextEntry?.previousEntry = entry.previousEntry
                    entry.clearEntries()
                    return(entry.pageReference)
                    }
                }
            }
        return(nil)
        }
        
    public func makeIterator() -> PageListIterator
        {
        PageListIterator(pageList: self)
        }
    }


public struct PageListIterator: IteratorProtocol
    {
    private let pageList: PageList
    private var entry: PageList.PageEntry?
    
    public init(pageList: PageList)
        {
        self.pageList = pageList
        self.entry = pageList.firstEntry
        }
        
    public mutating func next() -> PageList.PageEntry?
        {
        if self.entry.isNil
            {
            return(nil)
            }
        let someEntry = self.entry
        self.entry = self.entry!.nextEntry
        return(someEntry)
        }
    }
