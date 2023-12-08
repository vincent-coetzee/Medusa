
//
//  BTreePage.swift
//  Xenon
//
//  Created by Vincent Coetzee on 15/11/2023.
//

import Foundation
import MedusaCore
import MedusaStorage
import Fletcher

public class BTreePage: Page
    {
//    //
//    // Local constants
//    //
//    public static let kBTreePageKeyCountOffset                   = Page.kPageHeaderSizeInBytes
//    public static let kBTreePageKeysPerPageOffset                = kBTreePageKeyCountOffset + MemoryLayout<Integer64>.size
//    public static let kBTreePageIsLeafOffset                     = kBTreePageKeysPerPageOffset + MemoryLayout<Integer64>.size
//    public static let kBTreePageHeaderSizeInBytes                = kBTreePageIsLeafOffset + MemoryLayout<Boolean>.size
//    
//    public typealias ChildPointers = Array<Int>
//    public typealias Keys = Array<Integer64>
//    
//    internal var children: ChildPointers!
//    internal var keyCount: Integer64 = 0
//    internal var keysPerPage: Integer64
//    internal var isLeaf: Bool = false
//    private var childPointersOffset: Int = 0
//    internal var keys: Keys!
//    
//        {
//        Self.kBTreePageHeaderSizeInBytes + self.keysPerPage * MemoryLayout<Integer64>.size + (self.keysPerPage + 1) * MemoryLayout<Integer64>.size
//        }
//        
//    public override var initialFreeByteCount: Integer64
//        {
//        // The page size               less the header size                 less size of the key pointers                            less the size of the child pointers                            less the size of the first free cell
//        Medusa.kBTreePageSizeInBytes - Medusa.kBTreePageHeaderSizeInBytes - self.keysPerPage * MemoryLayout<Integer64>.size - (self.keysPerPage + 1) * MemoryLayout<Integer64>.size - 2 * MemoryLayout<Integer64>.size
//        }
//        
//    public override var fields: CompositeField
//        {
//        let superFields = super.fields
//        let headerFields = superFields.compositeField(named: "Header Fields")
//        headerFields?.append(Field(name: "keyCount",value: .integer(self.keyCount),offset: Medusa.kBTreePageKeyCountOffset))
//        headerFields?.append(Field(name: "keysPerPage",value: .integer(self.keysPerPage),offset: Medusa.kBTreePageKeysPerPageOffset))
//        headerFields?.append(Field(name: "isLeaf",value: .boolean(self.isLeaf),offset: Medusa.kBTreePageIsLeafOffset))
//        superFields.append(self.keyFields)
//        superFields.append(self.childPointerFields)
//        return(superFields)
//        }
//        
//    public var keyFields: CompositeField
//        {
//        let fields = CompositeField(name: "Keys")
//        var offset = Medusa.kBTreePageHeaderSizeInBytes
//        for index in 0..<self.keyCount
//            {
//            let keyOffset = self.keys[index]
//            let moreFields = CompositeField(name: "Key \(index)")
//            moreFields.append(Field(name: "Key Offset",value: .integer(keyOffset),offset: keyOffset))
//            var innerOffset = readInteger64(self.buffer,Medusa.kBTreePageKeysOffset + index * MemoryLayout<Integer64>.size)
//            moreFields.append(Field(name: "Key",value: .bytes(self.keyBytes(at: index)),offset: innerOffset))
//            let keyLength = readInteger64(self.buffer,innerOffset)
//            innerOffset += keyLength
//            moreFields.append(Field(name: "Value",value: .bytes(self.valueBytes(at: index)),offset: innerOffset))
//            offset += MemoryLayout<Integer64>.size
//            fields.append(moreFields)
//            }
//        return(fields)
//        }
//        
//    private var childPointerFields: CompositeField
//        {
//        let field = CompositeField(name: "Child Pointers")
//        var lastOffset = self.childPointersOffset
//        for index in 0..<self.keyCount + 1
//            {
//            field.append(Field(name: "Child Pointer \(index)",value: .address(self.children[index]),offset: lastOffset))
//            lastOffset += MemoryLayout<Medusa.Address>.size
//            }
//        return(field)
//        }
//    
//    public required init(magicNumber: Medusa.MagicNumber,keysPerPage: Integer64)
//        {
//        self.children = ChildPointers(repeating: 0,count: keysPerPage + 1)
//        self.keys = Keys(repeating: 0, count: keysPerPage)
//        self.keysPerPage = keysPerPage
//        self.childPointersOffset = Medusa.kBTreePageKeysOffset + keysPerPage * MemoryLayout<Integer64>.size
//        super.init(magicNumber: magicNumber)
//        }
//        
//    public override init(from buffer: RawPointer)
//        {
//        self.keysPerPage = readInteger64(buffer,Self.kBTreePageKeysPerPageOffset)
//        super.init(from: buffer)
//        self.readKeysAndChildren()
//        }
//        
//    public override init(from page: Page)
//        {
//        self.keysPerPage = readInteger64(page.buffer,Self.kBTreePageKeysPerPageOffset)
//        super.init(from: page)
//        self.loadKeysAndChildren()
//        }
//        
//    public override func store() throws
//        {
//        try super.store()
//        self.storeKeysAndChildren()
//        self.storeChecksum()
//        }
//        
//    internal override func reStore() throws
//        {
//        try super.reStore()
//        try self.rewriteKeysAndChildren()
//        super.storeChecksum()
//        self.needsDefragmentation = false
//        }
//        
//    private func key(at index: Int) -> Key
//        {
//        var byteOffset = readInteger64(self.buffer,Self.kBTreePageKeysOffset + index * MemoryLayout<Integer64>.size)
//        return(Key(from: self.buffer, atByteOffset: &byteOffset))
//        }
//        
//        
//    private func keyBytes(at index: Int) -> Bytes
//        {
//        let byteOffset = readInteger64(self.buffer,Self.kBTreePageKeysOffset + index * MemoryLayout<Integer64>.size)
//        return(Bytes(from: self.buffer, atByteOffset: byteOffset))
//        }
//        
//    private func keyOffset(at index: Int) -> Int
//        {
//        readInteger64(self.buffer,Self.kBTreePageKeysOffset + index * MemoryLayout<Integer64>.size)
//        }
//        
//    private func value(at index: Int) -> Value
//        {
//        var byteOffset = readInteger64(self.buffer,Self.kBTreePageKeysOffset + index * MemoryLayout<Integer64>.size)
//        let keySizeInBytes = readInteger64(self.buffer,byteOffset)
//        byteOffset += keySizeInBytes
//        return(Value(from: self.buffer,atByteOffset: &byteOffset))
//        }
//        
//    private func valueBytes(at index: Int) -> Bytes
//        {
//        var byteOffset = readInteger64(self.buffer,Self.kBTreePageKeysOffset + index * MemoryLayout<Integer64>.size)
//        let keySizeInBytes = readInteger64(self.buffer,byteOffset)
//        byteOffset += keySizeInBytes
//        return(Bytes(from: self.buffer,atByteOffset: &byteOffset))
//        }
//        
//    internal override func storeHeader()
//        {
//        super.storeHeader()
//        writeInteger(self.buffer,Int(self.keyCount),Self.kBTreePageKeyCountOffset)
//        writeInteger(self.buffer,Int(self.keysPerPage),Self.kBTreePageKeysPerPageOffset)
//        writeInteger(self.buffer,Int(self.isLeaf ? 1 : 0),Self.kBTreePageIsLeafOffset)
//        }
//        
//    internal override func loadHeader()
//        {
//        super.loadHeader()
//        self.keyCount = readInteger64(self.buffer,Self.kBTreePageKeyCountOffset)
//        self.keysPerPage = readInteger64(self.buffer,Self.kBTreePageKeysPerPageOffset)
//        self.isLeaf = readInteger64(self.buffer,Self.kBTreePageIsLeafOffset) == 1
//        }
//
//    private func loadKeysAndChildren()
//        {
//        self.keys = Keys(repeating: 0, count: self.keysPerPage)
//        self.children = ChildPointers(repeating: 0, count: self.keysPerPage + 1)
//        var offset = Self.kBTreePageHeaderSizeInBytes
//        print("OFFSET FOR KEYS \(offset)")
//        for index in 0..<self.keysPerPage
//            {
//            self.keys[index] = readInteger64WithOffset(self.buffer,&offset)
//            print("\tKEY \(index) = \(self.key(at: index).description)")
//            print("\tVALUE \(index) = \(self.value(at: index).description)")
//            }
//        offset = self.childPointersOffset
//        for index in 0..<self.keysPerPage + 1
//            {
//            self.children[index] = readInteger64WithOffset(self.buffer,&offset)
//            }
//        }
//        
//    public func storeKeysAndChildren()
//        {
//        var offset = Self.kBTreePageHeaderSizeInBytes
//        for index in 0..<self.keysPerPage
//            {
//            writeInteger64WithOffset(self.buffer,self.keys[index],&offset)
//            }
//        offset = self.childPointersOffset
//        for index in 0..<self.keysPerPage + 1
//            {
//            writeInteger64WithOffset(self.buffer,self.children[index],&offset)
//            }
//        }
//        
//    internal func reStoreKeysAndChildren() throws
//        {
//        var offset = Medusa.kBTreePageHeaderSizeInBytes
//        var keyPointerOffset = Medusa.kBTreePageHeaderSizeInBytes
//        var someKeys = Array<KeyPart>()
//        var someValues = Array<Value>()
//        for index in 0..<self.keyCount
//            {
//            someKeys[index] = self.key(at: index)
//            someValues[index] = self.value(at: index)
//            }
//        for index in 0..<self.keyCount
//            {
//            var byteOffset = try self.allocate(sizeInBytes: someKeys[index].sizeInBytes + someValues[index].sizeInBytes)
//            writeIntegerWithOffset(self.buffer,byteOffset,&keyPointerOffset)
//            someKeys[index].write(to: self.buffer, atByteOffset: &byteOffset)
//            someValues[index].write(to: self.buffer,atByteOffset: &byteOffset)
//            }
//        offset = childPointersOffset
//        for index in 0..<self.keysPerPage
//            {
//            writeIntegerWithOffset(self.buffer,self.children[index],&offset)
//            }
//        }
//        
//    public func findIndex(key: KeyPart) -> Int
//        {
//        var lower = -1
//        var upper = self.keyCount - 1
//        while (lower + 1 < upper)
//            {
//            let middle = (lower + upper) / 2
//            let middleKey = self.key(at: middle)
//            if middleKey == key
//                {
//                return(middle)
//                }
//            else if middleKey < key
//                {
//                lower = middle
//                }
//            else
//                {
//                upper = middle
//                }
//            }
//        return(upper)
//        }
//
//    public func insert(key: Key,value: Value,medianKeyValue:inout KeyValue) throws -> BTreePage?
//        {
//        let savedOffset = try self.insert(key: key,value: value)
//        let position = self.findIndex(key: key)
//        let positionKey = self.key(at: position)
//        if position < self.keyCount && positionKey == key
//            {
//            return(nil)
//            }
//        if self.isLeaf
//            {
//            self.keys.shiftUp(from: position + 1,by: 1)
//            self.keys[position] = savedOffset
//            self.keyCount += 1
//            }
//        else
//            {
//            let page2 = try PageServer.shared.readBTreePage(from: self.fileHandle, at: self.children[position], keyType: Key.self, valueType: Value.self)
//            var middle: KeyValue<Key,Value>!
//            let nextPage = try page2.insert(key: key, value: value, medianKeyValue: &middle)
//            if let nextPage
//                {
//                try nextPage.write()
//                self.keys.shiftUp(from: position + 1,by: 1)
//                self.children.shiftUp(from: position + 2,by: 1)
//                self.keys[position] = try self.insert(key: middle.key,value: middle.value)
//                self.children[position] = nextPage.pageAddress
//                self.keyCount += 1
//                try self.write()
//                self.isDirty = true
//                }
//            }
//        //
//        // Split the page
//        //
//        if self.keyCount >= self.keysPerPage
//            {
//            let middle = self.keyCount / 2
//            medianKeyValue = KeyValue(key: self.key(at: middle),value: self.value(at: middle))
//            let newPage = try PageServer.shared.allocateBTreePage(fileHandle: self.fileHandle, magicNumber: self.magicNumber, keysPerPage: self.keysPerPage, keyType: Key.self, valueType: Value.self)
//            newPage.keyCount = self.keyCount - middle - 1
//            newPage.isLeaf = self.isLeaf
//            for index in 0..<newPage.keyCount
//                {
//                let oldIndex = index + middle + 1
//                let newOffset = try newPage.insert(key: self.key(at: oldIndex),value: self.value(at: oldIndex))
//                newPage.keys[index] = newOffset
//                try self.deallocate(at: self.keys[oldIndex])
//                }
//            if !self.isLeaf
//                {
//                for index in 0..<newPage.keyCount + 1
//                    {
//                    newPage.children[index] = self.children[index + middle + 1]
//                    }
//                }
//            self.keyCount = middle
//            newPage.isDirty = true
//            return(newPage)
//            }
//        return(nil)
//        }
//        
//    internal func insert(key: Key,value: Value) throws -> Integer64
//        {
//        var keyOffset = try self.allocate(sizeInBytes: key.sizeInBytes + value.sizeInBytes)
//        let savedOffset = keyOffset
//        key.write(to: self.buffer, atByteOffset: &keyOffset)
//        value.write(to: self.buffer,atByteOffset: &keyOffset)
//        return(savedOffset)
//        }
//        
//    internal func copy(from old: BTreePage) throws
//        {
//        self.keyCount = old.keyCount
//        for index in 0..<old.keysPerPage
//            {
//            let newOffset = try self.insert(key: old.key(at: index),value: self.value(at: index))
//            self.keys[index] = newOffset
//            self.children[index] = old.children[index]
//            }
//        self.children[self.keysPerPage + 1] = old.children[self.keysPerPage + 1]
//        }
//    }
//
//extension Array
//    {
//    public mutating func shiftUp(from start: Int,by: Int)
//        {
//        for index in stride(from: self.count - by - 1,to: start,by: -1)
//            {
//            self[index + by] = self[index]
//            }
//        }
//        
//    public mutating func shiftDown(from start: Int,by: Int)
//        {
//        for index in stride(from: start,to: self.count - by - 1,by: 1)
//            {
//            self[index] = self[index + by]
//            }
//        }
//        
//    public mutating func move(from start: Int,length: Int,to other:inout Array<Element>,at otherStart: Int)
//        {
//        var delta = otherStart
//        for index in start..<start + length - 1
//            {
//            other[delta] = self[index]
//            delta += 1
//            }
//        }
    }
