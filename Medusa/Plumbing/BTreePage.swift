//
//  BTreePage.swift
//  Xenon
//
//  Created by Vincent Coetzee on 15/11/2023.
//

import Foundation
import Fletcher32

public class BTreePage<Key,Value>: Page where Key:Fragment,Value:Fragment
    {
    public var headerFields: FieldSet
        {
        let fields = FieldSet()
        fields.append(Field(index: 0,name: "magicNumber",value: .magicNumber(self.magicNumber)))
        fields.append(Field(index: 1,name: "checksum",value: .checksum(self.checksum)))
        fields.append(Field(index: 2,name: "freeByteCount",value: .offset(self.freeByteCount)))
        fields.append(Field(index: 3,name: "firstFreeCellOffset",value: .offset(self.firstFreeCellOffset)))
        fields.append(Field(index: 4,name: "freeCellCount",value: .offset(self.freeCellCount)))
        fields.append(Field(index: 5,name: "rightPointer",value: .pageAddress(self.rightPointer)))
        fields.append(Field(index: 6,name: "keyEntryCount",value: .offset(self.keyEntryCount)))
        fields.append(Field(index: 6,name: "pageAddress",value: .pageAddress(self.pageAddress)))
        fields.append(Field(index: 6,name: "file",value: .string(self.file?.path.string ?? "nil")))
        return(fields)
        }
        
    public var keyEntryFields: FieldSet
        {
        let fields = FieldSet()
        var index = 0
        var count = 0
        for entry in self.keyEntries
            {
            var localOffset = entry.cellOffset
            let pointer = self.pageBuffer.load(fromByteOffset: &localOffset, as: Medusa.PageAddress.self)
            print("READ POINTER \(pointer) AT \(entry.cellOffset)")
            let keyBytes = Medusa.Bytes(from: self.pageBuffer, atByteOffset: &localOffset)
            let valueBytes = Medusa.Bytes(from: self.pageBuffer,atByteOffset: &localOffset)
            fields.append(Field(index: index,name: "Key entry \(count)",value: .keyValueEntry(entry.cellOffset, pointer, keyBytes, valueBytes)))
            count += 1
            index += 1
            }
        return(fields)
        }
        
    public var freeCellFields: FieldSet
        {
        self.freeList.freeListFields
        }
        
    private var keyEntries = Array<KeyEntry<Key,Value>>()
    public var rightPointer: Medusa.PagePointer = 0
    public private(set) var keyEntryCount: Medusa.Integer = 0
    private var keyPointersNeedSorting = false
    
    public required init(magicNumber: Medusa.MagicNumber)
        {
        super.init(magicNumber: magicNumber)
        self.firstFreeCellOffset = Medusa.kBTreePageHeaderSizeInBytes
        self.freeCellCount = 0
        self.checksumOffset = Medusa.kPageChecksumOffset
        }
    
    public override init(from buffer: PageBuffer)
        {
        super.init(from: buffer)
        self.pageAddress = 0
        self.pageBuffer = buffer
        self.readHeader()
        self.readKeyEntries()
        }
        
    @discardableResult
    public func write() -> PageBuffer
        {
        self.writeHeader()
        self.writeKeyPointers()
        self.writeKeyEntries()
        self.writeChecksum()
        self.writeFreeList()
        return(self.pageBuffer)
        }
        
    internal override func writeHeader()
        {
        super.writeHeader()
        self.freeCellCount = self.freeList.count
        self.pageBuffer.storeBytes(of: self.rightPointer,atByteOffset: Medusa.kBTreePageRightPointerOffset, as: Medusa.PageAddress.self)
        self.pageBuffer.storeBytes(of: Int(self.keyEntries.count),atByteOffset: Medusa.kBTreePageKeyEntryCountOffset, as: Medusa.Integer.self)
        }
        
    internal override func readHeader()
        {
        super.readHeader()
        self.rightPointer = self.pageBuffer.load(fromByteOffset: Medusa.kBTreePageRightPointerOffset, as: Medusa.PagePointer.self)
        self.keyEntryCount = self.pageBuffer.load(fromByteOffset: Medusa.kBTreePageKeyEntryCountOffset, as: Int.self)
        }
    
    //
    // Make sure this is called before writeHeader is called
    //
    private func writeChecksum()
        {
        var location = self.checksumOffset
        // set the checksum to 0 before we do the checksum to ensure we get a clean checksum
        self.pageBuffer.storeBytes(of: Medusa.Checksum(0),atByteOffset: &location, as: Medusa.Checksum.self)
        let data = self.pageBuffer.unsignedInt16Pointer
        let length = Medusa.kBTreePageSizeInBytes
        self.checksum = fletcher32(data,length)
        location = self.checksumOffset
        self.pageBuffer.storeBytes(of: self.checksum,atByteOffset: &location, as: Medusa.Checksum.self)
        }
        
    public func dump()
        {
        print("PAGE BUFFER @ \(self.pageBuffer)")
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
        for _ in 0..<self.keyEntryCount
            {
            var entryOffset = self.pageBuffer.load(fromByteOffset: &offset, as: Medusa.Integer.self)
            self.keyEntries.append(KeyEntry(from: self.pageBuffer,atByteOffset: &entryOffset))
            offset += MemoryLayout<Medusa.Integer>.size
            }
        }
        
    public func insertKeyEntry(key: Key,value: Value,pointer: Medusa.PageAddress) throws
        {
        let keyEntry = KeyEntry<Key,Value>(key: key, value: value, pointer: pointer)
        self.keyEntries.append(keyEntry)
        self.keyEntryCount = self.keyEntries.count
        var byteOffset = try self.freeList.allocate(sizeInBytes: keyEntry.sizeInBytes)
        if byteOffset == 0
            {
            print("halt")
            }
        keyEntry.setCellOffset(byteOffset)
        keyEntry.write(to: self.pageBuffer,atByteOffset: &byteOffset)
        var offsetOffset = self.keyEntries.count * MemoryLayout<Medusa.Integer>.size + Medusa.kBTreePageHeaderSizeInBytes
        self.pageBuffer.storeBytes(of: Int(byteOffset), atByteOffset: &offsetOffset,as: Medusa.Integer.self)
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
            self.pageBuffer.storeBytes(of: entry.cellOffset, atByteOffset: &offset,as: Medusa.Integer.self)
            }
        self.isDirty = true
        }
        
    private func writeKeyEntries()
        {
        for entry in self.keyEntries
            {
            var offset = entry.cellOffset
            entry.write(to: self.pageBuffer,atByteOffset: &offset)
            }
        self.isDirty = true
        }
    }
