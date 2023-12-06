//
//  BTree.swift
//  Medusa
//
//  Created by Vincent Coetzee on 28/11/2023.
//

import Foundation

public class BTree<Key,Value> where Key: Fragment,Value: Fragment
    {
    public var rootPage: BTreePage<Key,Value>!
    public let magicNumber: Medusa.MagicNumber
    public let keysPerPage: Medusa.Integer64
    public let fileHandle: FileHandle
    public let order: Medusa.Integer64
    
    public init(fileHandle: FileHandle,order: Medusa.Integer64,magicNumber: Medusa.MagicNumber,keysPerPage: Medusa.Integer64) throws
        {
        self.magicNumber = magicNumber
        self.keysPerPage = keysPerPage
        self.fileHandle = fileHandle
        self.order = order
            self.rootPage = try PageServer.shared.allocateBTreePage(fileHandle: self.fileHandle, magicNumber: Medusa.kBTreePageMagicNumber, keysPerPage: keysPerPage, keyType: Key.self, valueType: Value.self)
        self.rootPage.isLeaf = true
        self.rootPage.keyCount = 0
        }
        
    public func insert(key: Key,value: Value) throws
        {
        var left: BTreePage<Key,Value>!
        var median: KeyValue<Key,Value>!
        if let right = try self.rootPage.insert(key: key, value: value, medianKeyValue: &median)
            {
            left = try PageServer.shared.allocateBTreePage(fileHandle: self.fileHandle, magicNumber: Medusa.kBTreePageMagicNumber,keysPerPage: self.keysPerPage, keyType: Key.self, valueType: Value.self)
            try left.copy(from: self.rootPage)
            try left.write()
            self.rootPage.keyCount = 1
            self.rootPage.isLeaf = false
            self.rootPage.keys[0] = try self.rootPage.insert(key: median.key,value: median.value)
            self.rootPage.children[0] = left.pageAddress
            self.rootPage.children[1] = right.pageAddress
            try right.write()
            right.isDirty = true
            try self.rootPage.write()
            self.rootPage.isDirty = true
            }
        }
    }

public class MOPBTree
    {
    public var rootPage: BTreePage<Key,Value>!
    public let magicNumber: Medusa.MagicNumber
    public let keysPerPage: Medusa.Integer64
    public let fileHandle: FileHandle
    public let order: Medusa.Integer64
    public let keyKlass: MOPClass
    public let valueKlass: MOPClass
    
    public init(baseAddress: Address,order: Medusa.Integer64,magicNumber: Medusa.MagicNumber,keysPerPage: Medusa.Integer64) throws
        {
        self.magicNumber = magicNumber
        self.keysPerPage = keysPerPage
        self.fileHandle = fileHandle
        self.order = order
            self.rootPage = try PageServer.shared.allocateBTreePage(fileHandle: self.fileHandle, magicNumber: Medusa.kBTreePageMagicNumber, keysPerPage: keysPerPage, keyType: Key.self, valueType: Value.self)
        self.rootPage.isLeaf = true
        self.rootPage.keyCount = 0
        }
        
    public func insert(key: MOPInstance,value: MOPInstance) throws
        {
        var left: BTreePage<Key,Value>!
        var median: KeyValue<Key,Value>!
        if let right = try self.rootPage.insert(key: key, value: value, medianKeyValue: &median)
            {
            left = try PageServer.shared.allocateBTreePage(fileHandle: self.fileHandle, magicNumber: Medusa.kBTreePageMagicNumber,keysPerPage: self.keysPerPage, keyType: Key.self, valueType: Value.self)
            try left.copy(from: self.rootPage)
            try left.write()
            self.rootPage.keyCount = 1
            self.rootPage.isLeaf = false
            self.rootPage.keys[0] = try self.rootPage.insert(key: median.key,value: median.value)
            self.rootPage.children[0] = left.pageAddress
            self.rootPage.children[1] = right.pageAddress
            try right.write()
            right.isDirty = true
            try self.rootPage.write()
            self.rootPage.isDirty = true
            }
        }
    }
