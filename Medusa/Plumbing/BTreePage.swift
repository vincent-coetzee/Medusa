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
    public var keyEntries = Array<KeyEntry<Key,Value>>()
    public var rightPointer: Medusa.PagePointer = 0
    public private(set) var keyEntryCount: Medusa.Integer64 = 0
    private var keyPointersNeedSorting = false
    
    public var entryCount: Int
        {
        return(self.keyEntries.count)
        }
        
    public override var fieldSets: FieldSetList
        {
        var list = super.fieldSets
        list["Header Fields"]!.append(Field(index: 5,name: "rightPointer",value: .pageAddress(self.rightPointer),offset: Medusa.kBTreePageRightPointerOffset))
        list["Header Fields"]!.append(Field(index: 6,name: "keyEntryCount",value: .offset(self.keyEntryCount),offset: Medusa.kBTreePageKeyEntryCountOffset))
        let keyEntryFields = self.keyEntryFields
        list[keyEntryFields.name] = keyEntryFields
        return(list)
        }
        
    public var keyEntryFields: FieldSet
        {
        let fields = FieldSet(name: "Key Entry Fields")
        var index = 0
        var count = 0
        for entry in self.keyEntries
            {
            var localOffset = entry.cellOffset
            let pointer = readIntegerWithOffset(self.buffer,&localOffset)
            print("READ POINTER \(pointer) AT \(entry.cellOffset)")
            let keyBytes = Medusa.Bytes(from: self.buffer, atByteOffset: &localOffset)
            let valueBytes = Medusa.Bytes(from: self.buffer,atByteOffset: &localOffset)
            fields.append(Field(index: index,name: "Key entry \(count)",value: .keyValueEntry(entry.cellOffset, pointer, keyBytes, valueBytes),offset: entry.cellOffset))
            count += 1
            index += 1
            }
        return(fields)
        }
    
    public required init(magicNumber: Medusa.MagicNumber)
        {
        super.init(magicNumber: magicNumber)
        }
        
    public override init(from buffer: UnsafeMutableRawPointer)
        {
        super.init(from: buffer)
        self.readKeyEntries()
        }
        
    public override init(from page: Page)
        {
        super.init(from: page)
        self.readKeyEntries()
        }
        
        
    @discardableResult
    public func write() -> UnsafeMutableRawPointer
        {
        self.writeHeader()
        self.writeKeyPointers()
        self.writeKeyEntries()
        self.writeChecksum()
        self.writeFreeList()
        return(self.buffer)
        }
        
    internal override func writeHeader()
        {
        super.writeHeader()
        writeInteger(self.buffer,self.rightPointer,Medusa.kBTreePageRightPointerOffset)
        writeInteger(self.buffer,Int(self.keyEntries.count),Medusa.kBTreePageKeyEntryCountOffset)
        }
        
    internal override func readHeader()
        {
        super.readHeader()
        self.rightPointer = readInteger(self.buffer,Medusa.kBTreePageRightPointerOffset)
        print("     RIGHT POINTER \(self.rightPointer)")
        self.keyEntryCount = readInteger(self.buffer,Medusa.kBTreePageKeyEntryCountOffset)
        print("     KEY ENTRY COUNT \(self.keyEntryCount)")
        }
    
    //
    // Make sure this is called before writeHeader is called
    //
    private func writeChecksum()
        {
        // set the checksum to 0 before we do the checksum to ensure we get a clean checksum
        writeUnsigned64(self.buffer,UInt64(0),Medusa.kPageChecksumOffset)
        let data = UnsafePointer<UInt32>(OpaquePointer(self.buffer))
        let length = Medusa.kBTreePageSizeInBytes
        self.checksum = fletcher64(data,length)
        writeUnsigned64(self.buffer,self.checksum,Medusa.kPageChecksumOffset)
        }
        
    public func dump()
        {
        print("PAGE BUFFER @ \(self.buffer)")
        print("HEADER")
        print("-------------------------------------")
        print("FREE BYTE COUNT          : \(self.freeByteCount)")
        print("CHECKSUM                 : \(self.checksum)")
        let number = String(format: "%08X",self.magicNumber)
        print("MAGIC NUMBER             : \(number)")
        print("FIRST FREE CELL OFFSET   : \(self.firstFreeCellOffset)")
        print("CELL COUNT               : \(self.freeCellCount)")
        print("RIGHT POINTER            : \(self.rightPointer)")
        print("KEY ENTRY COUNT          : \(self.keyEntries.count)")
        print("---------------------------------------")
        print("KEY ENTRIES - POINTERS")
        for entry in self.keyEntries
            {
            print("\tKEY \(entry.key.description) OFFSET \(entry.cellOffset)")
            }
        }
        
    private func readKeyEntries()
        {
        var offset = Medusa.kBTreePageHeaderSizeInBytes
        print("OFFSET FOR KEY ENTRIES \(offset)")
        for index in 0..<self.keyEntryCount
            {
            var entryOffset = readIntegerWithOffset(self.buffer,&offset)
            print("     KEY ENTRY \(index) OFFSET \(entryOffset)")
            let entry = KeyEntry<Key,Value>(from: self.buffer,atByteOffset: &entryOffset)
            self.keyEntries.append(entry)
            print("     KEY ENTRY \(index) KEY \(entry.key.description.prefix(20))")
            }
        }
        
    public func insertKeyEntry(key: Key,value: Value,pointer: Medusa.PageAddress) throws
        {
        let keyEntry = KeyEntry<Key,Value>(key: key, value: value, pointer: pointer)
        self.keyEntries.append(keyEntry)
        self.keyEntryCount = self.keyEntries.count
        print("INSERT KEY")
        print("     KEY ENTRY SIZE = \(keyEntry.sizeInBytes) KEY SIZE = \(keyEntry.key.sizeInBytes) VALUE SIZE = \(keyEntry.value.sizeInBytes)")
        var byteOffset = try self.allocate(sizeInBytes: keyEntry.sizeInBytes)
        print("     ALLOCATED \(keyEntry.sizeInBytes) BYTES AT \(byteOffset)")
        keyEntry.setCellOffset(byteOffset)
        let savedOffset = byteOffset
        keyEntry.write(to: self.buffer,atByteOffset: &byteOffset)
        var offsetOffset = self.keyEntries.count * MemoryLayout<Medusa.Integer64>.size + Medusa.kBTreePageHeaderSizeInBytes
        print("     WRITING CELL OFFSET \(savedOffset) OF KEY ENTRY AT \(offsetOffset)")
        writeIntegerWithOffset(self.buffer,savedOffset,&offsetOffset)
        self.freeList.write(to: self.buffer)
        self.keyPointersNeedSorting = true
        self.isDirty = true
        }
        
    private func writeKeyPointers()
        {
        var offset = Medusa.kBTreePageHeaderSizeInBytes
        if self.keyPointersNeedSorting
            {
            self.keyEntries = self.keyEntries.sorted(by: {$0.key < $1.key})
            }
        for entry in self.keyEntries
            {
            writeIntegerWithOffset(self.buffer,entry.cellOffset,&offset)
            }
        self.isDirty = true
        }
        
    private func writeKeyEntries()
        {
        print("WRITING \(self.keyEntries.count) KEY ENTRIES")
        var count = 0
        for entry in self.keyEntries
            {
            var offset = entry.cellOffset
            print("WRITING KEY ENTRY \(count)")
            entry.write(to: self.buffer,atByteOffset: &offset)
            count += 1
            }
        self.isDirty = true
        }
    }
