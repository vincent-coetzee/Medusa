//
//  BTreePage.swift
//  Xenon
//
//  Created by Vincent Coetzee on 15/11/2023.
//

import Foundation
import Fletcher

public class BTreePage<Key,Value>: Page where Key:Fragment,Value:Fragment
    {
    public typealias ChildPointers = Array<Int>
    public typealias Keys = Array<Medusa.Integer64>
    
    internal var children: ChildPointers!
    internal var keyCount: Medusa.Integer64 = 0
    internal var keysPerPage: Medusa.Integer64
    internal var isLeaf: Bool = false
    private var childPointersOffset: Int = 0
    internal var keys: Keys!
    
    internal override var basePageSizeInBytes: Medusa.Integer64
        {
        super.basePageSizeInBytes + 3 * MemoryLayout<Medusa.Integer64>.size + self.keysPerPage * MemoryLayout<Medusa.Integer64>.size
        }
 
    public override var fields: CompositeField
        {
        let superFields = super.fields
        let headerFields = superFields.compositeField(named: "Header Fields")
        headerFields?.append(Field(name: "keyCount",value: .integer(self.keyCount),offset: Medusa.kBTreePageKeyCountOffset))
        headerFields?.append(Field(name: "keysPerPage",value: .integer(self.keysPerPage),offset: Medusa.kBTreePageKeysPerPageOffset))
        headerFields?.append(Field(name: "isLeaf",value: .boolean(self.isLeaf),offset: Medusa.kBTreePageIsLeafOffset))
        superFields.append(self.keyFields)
        superFields.append(self.childPointerFields)
        return(superFields)
        }
        
    public var keyFields: CompositeField
        {
        let fields = CompositeField(name: "Keys")
        var offset = Medusa.kBTreePageHeaderSizeInBytes
        for index in 0..<self.keyCount
            {
            let keyOffset = self.keys[index]
            let moreFields = CompositeField(name: "Key \(index)")
            moreFields.append(Field(name: "Key Offset",value: .integer(keyOffset),offset: keyOffset))
            var innerOffset = readInteger(self.buffer,Medusa.kBTreePageKeysOffset + index * MemoryLayout<Medusa.Integer64>.size)
            moreFields.append(Field(name: "Key",value: .bytes(self.keyBytes(at: index)),offset: innerOffset))
            let keyLength = readInteger(self.buffer,innerOffset)
            innerOffset += keyLength
            moreFields.append(Field(name: "Value",value: .bytes(self.valueBytes(at: index)),offset: innerOffset))
            offset += MemoryLayout<Medusa.Integer64>.size
            fields.append(moreFields)
            }
        return(fields)
        }
        
    private var childPointerFields: CompositeField
        {
        let field = CompositeField(name: "Child Pointers")
        var lastOffset = self.childPointersOffset
        for index in 0..<self.keyCount + 1
            {
            field.append(Field(name: "Child Pointer \(index)",value: .address(self.children[index]),offset: lastOffset))
            lastOffset += MemoryLayout<Medusa.Address>.size
            }
        return(field)
        }
    
    public required init(fileIdentifier: FileIdentifier,magicNumber: Medusa.MagicNumber,keysPerPage: Medusa.Integer64)
        {
        self.children = ChildPointers(repeating: 0,count: keysPerPage + 1)
        self.keys = Keys(repeating: 0, count: keysPerPage)
        self.keysPerPage = keysPerPage
        self.childPointersOffset = Medusa.kBTreePageKeysOffset + keysPerPage * MemoryLayout<Medusa.Integer64>.size
        super.init(magicNumber: magicNumber)
        self.fileIdentifier = fileIdentifier
        }
        
    public override init(from buffer: UnsafeMutableRawPointer)
        {
        self.keysPerPage = readInteger(buffer,Medusa.kBTreePageKeysPerPageOffset)
        super.init(from: buffer)
        self.readKeysAndChildren()
        }
        
    public override init(from page: Page)
        {
        self.keysPerPage = readInteger(page.buffer,Medusa.kBTreePageKeysPerPageOffset)
        super.init(from: page)
        self.readKeysAndChildren()
        }
        
    public override func write() throws
        {
        try super.write()
        self.writeKeysAndChildren()
        self.writeChecksum()
        }
        
    internal override func rewritePage() throws
        {
        try super.rewritePage()
        try self.rewriteKeysAndChildren()
        super.writeChecksum()
        self.needsDefragmentation = false
        }
        
    private func key(at index: Int) -> Key
        {
        var byteOffset = readInteger(self.buffer,Medusa.kBTreePageKeysOffset + index * MemoryLayout<Medusa.Integer64>.size)
        return(Key(from: self.buffer, atByteOffset: &byteOffset))
        }
        
        
    private func keyBytes(at index: Int) -> Bytes
        {
        let byteOffset = readInteger(self.buffer,Medusa.kBTreePageKeysOffset + index * MemoryLayout<Medusa.Integer64>.size)
        return(Bytes(from: self.buffer, atByteOffset: byteOffset))
        }
        
    private func keyOffset(at index: Int) -> Int
        {
        readInteger(self.buffer,Medusa.kBTreePageKeysOffset + index * MemoryLayout<Medusa.Integer64>.size)
        }
        
    private func value(at index: Int) -> Value
        {
        var byteOffset = readInteger(self.buffer,Medusa.kBTreePageKeysOffset + index * MemoryLayout<Medusa.Integer64>.size)
        let keySizeInBytes = readInteger(self.buffer,byteOffset)
        byteOffset += keySizeInBytes
        return(Value(from: self.buffer,atByteOffset: &byteOffset))
        }
        
    private func valueBytes(at index: Int) -> Bytes
        {
        var byteOffset = readInteger(self.buffer,Medusa.kBTreePageKeysOffset + index * MemoryLayout<Medusa.Integer64>.size)
        let keySizeInBytes = readInteger(self.buffer,byteOffset)
        byteOffset += keySizeInBytes
        return(Bytes(from: self.buffer,atByteOffset: &byteOffset))
        }
        
    internal override func writeHeader()
        {
        super.writeHeader()
        writeInteger(self.buffer,Int(self.keyCount),Medusa.kBTreePageKeyCountOffset)
        writeInteger(self.buffer,Int(self.keysPerPage),Medusa.kBTreePageKeysPerPageOffset)
        writeInteger(self.buffer,Int(self.isLeaf ? 1 : 0),Medusa.kBTreePageIsLeafOffset)
        }
        
    internal override func readHeader()
        {
        super.readHeader()
        self.keyCount = readInteger(self.buffer,Medusa.kBTreePageKeyCountOffset)
        self.keysPerPage = readInteger(self.buffer,Medusa.kBTreePageKeysPerPageOffset)
        self.isLeaf = readInteger(self.buffer,Medusa.kBTreePageIsLeafOffset) == 1
        }

    private func readKeysAndChildren()
        {
        self.keys = Keys(repeating: 0, count: self.keysPerPage)
        self.children = ChildPointers(repeating: 0, count: self.keysPerPage + 1)
        var offset = Medusa.kBTreePageHeaderSizeInBytes
        print("OFFSET FOR KEYS \(offset)")
        for index in 0..<self.keysPerPage
            {
            self.keys[index] = readIntegerWithOffset(self.buffer,&offset)
            print("\tKEY \(index) = \(self.key(at: index).description)")
            print("\tVALUE \(index) = \(self.value(at: index).description)")
            }
        offset = self.childPointersOffset
        for index in 0..<self.keysPerPage + 1
            {
            self.children[index] = readIntegerWithOffset(self.buffer,&offset)
            }
        }
        
    public func writeKeysAndChildren()
        {
        var offset = Medusa.kBTreePageHeaderSizeInBytes
        for index in 0..<self.keysPerPage
            {
            writeIntegerWithOffset(self.buffer,self.keys[index],&offset)
            }
        offset = self.childPointersOffset
        for index in 0..<self.keysPerPage + 1
            {
            writeIntegerWithOffset(self.buffer,self.children[index],&offset)
            }
        }
        
    internal func rewriteKeysAndChildren() throws
        {
        var offset = Medusa.kBTreePageHeaderSizeInBytes
        var keyPointerOffset = Medusa.kBTreePageHeaderSizeInBytes
        var someKeys = Array<Key>()
        var someValues = Array<Value>()
        for index in 0..<self.keyCount
            {
            someKeys[index] = self.key(at: index)
            someValues[index] = self.value(at: index)
            }
        for index in 0..<self.keyCount
            {
            var byteOffset = try self.allocate(sizeInBytes: someKeys[index].sizeInBytes + someValues[index].sizeInBytes)
            writeIntegerWithOffset(self.buffer,byteOffset,&keyPointerOffset)
            someKeys[index].write(to: self.buffer, atByteOffset: &byteOffset)
            someValues[index].write(to: self.buffer,atByteOffset: &byteOffset)
            }
        offset = childPointersOffset
        for index in 0..<self.keysPerPage
            {
            writeIntegerWithOffset(self.buffer,self.children[index],&offset)
            }
        }
        
    public func findIndex(key: Key) -> Int
        {
        var lower = -1
        var upper = self.keyCount - 1
        while (lower + 1 < upper)
            {
            let middle = (lower + upper) / 2
            let middleKey = self.key(at: middle)
            if middleKey == key
                {
                return(middle)
                }
            else if middleKey < key
                {
                lower = middle
                }
            else
                {
                upper = middle
                }
            }
        return(upper)
        }

    public func insert(key: Key,value: Value,medianKeyValue:inout KeyValue<Key,Value>) throws -> BTreePage?
        {
        let savedOffset = try self.insert(key: key,value: value)
        let position = self.findIndex(key: key)
        let positionKey = self.key(at: position)
        if position < self.keyCount && positionKey == key
            {
            return(nil)
            }
        if self.isLeaf
            {
            self.keys.shiftUp(from: position + 1,by: 1)
            self.keys[position] = savedOffset
            self.keyCount += 1
            }
        else
            {
            let page2 = try PageAgent.nextAvailableAgent().readBTreePage(from: self.fileIdentifier, at: self.children[position], keyType: Key.self, valueType: Value.self)
            var middle: KeyValue<Key,Value>!
            let nextPage = try page2.insert(key: key, value: value, medianKeyValue: &middle)
            if let nextPage
                {
                try nextPage.write()
                self.keys.shiftUp(from: position + 1,by: 1)
                self.children.shiftUp(from: position + 2,by: 1)
                self.keys[position] = try self.insert(key: middle.key,value: middle.value)
                self.children[position] = nextPage.pageAddress
                self.keyCount += 1
                try self.write()
                self.isDirty = true
                }
            }
        //
        // Split the page
        //
        if self.keyCount >= self.keysPerPage
            {
            let middle = self.keyCount / 2
            medianKeyValue = KeyValue(key: self.key(at: middle),value: self.value(at: middle))
            let newPage = try PageAgent.nextAvailableAgent().allocateBTreePage(fileIdentifier: self.fileIdentifier, magicNumber: self.magicNumber, keysPerPage: self.keysPerPage, keyType: Key.self, valueType: Value.self)
            newPage.keyCount = self.keyCount - middle - 1
            newPage.isLeaf = self.isLeaf
            for index in 0..<newPage.keyCount
                {
                let oldIndex = index + middle + 1
                let newOffset = try newPage.insert(key: self.key(at: oldIndex),value: self.value(at: oldIndex))
                newPage.keys[index] = newOffset
                try self.deallocate(at: self.keys[oldIndex])
                }
            if !self.isLeaf
                {
                for index in 0..<newPage.keyCount + 1
                    {
                    newPage.children[index] = self.children[index + middle + 1]
                    }
                }
            self.keyCount = middle
            newPage.isDirty = true
            return(newPage)
            }
        return(nil)
        }
        
    internal func insert(key: Key,value: Value) throws -> Medusa.Integer64
        {
        var keyOffset = try self.allocate(sizeInBytes: key.sizeInBytes + value.sizeInBytes)
        let savedOffset = keyOffset
        key.write(to: self.buffer, atByteOffset: &keyOffset)
        value.write(to: self.buffer,atByteOffset: &keyOffset)
        return(savedOffset)
        }
        
    internal func copy(from old: BTreePage<Key,Value>) throws
        {
        self.keyCount = old.keyCount
        for index in 0..<old.keysPerPage
            {
            let newOffset = try self.insert(key: old.key(at: index),value: self.value(at: index))
            self.keys[index] = newOffset
            self.children[index] = old.children[index]
            }
        self.children[self.keysPerPage + 1] = old.children[self.keysPerPage + 1]
        }
    }

extension Array
    {
    public mutating func shiftUp(from start: Int,by: Int)
        {
        for index in stride(from: self.count - by - 1,to: start,by: -1)
            {
            self[index + by] = self[index]
            }
        }
        
    public mutating func shiftDown(from start: Int,by: Int)
        {
        for index in stride(from: start,to: self.count - by - 1,by: 1)
            {
            self[index] = self[index + by]
            }
        }
        
    public mutating func move(from start: Int,length: Int,to other:inout Array<Element>,at otherStart: Int)
        {
        var delta = otherStart
        for index in start..<start + length - 1
            {
            other[delta] = self[index]
            delta += 1
            }
        }
    }
