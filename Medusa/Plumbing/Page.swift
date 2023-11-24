//
//  MedusaPage.swift
//  Medusa
//
//  Created by Vincent Coetzee on 20/11/2023.
//

import Foundation

public class Page
    {
    internal var bufferSizeInBytes: Medusa.Integer = 0
    internal var pageBuffer: PageBuffer
    internal var magicNumber: Medusa.MagicNumber = 0xDEADB00BCAFED00D
    internal var freeByteCount: Medusa.Integer = 0
    internal var checksum: Medusa.Checksum = 0
    internal var freeList: FreeList!
    internal var firstFreeCellOffset: Medusa.Integer
    internal var freeCellCount: Medusa.Integer = 0
    internal var checksumOffset: Medusa.Integer = 0
    internal var pageAddress: Medusa.PageAddress = 0
    internal var file: File!
    internal var isDirty = false
    
    public required init(magicNumber: Medusa.MagicNumber)
        {
        self.pageBuffer = PageBuffer(sizeInBytes: Medusa.kPageSizeInBytes)
        self.bufferSizeInBytes = pageBuffer.count
        self.magicNumber = magicNumber
        self.firstFreeCellOffset = Medusa.kBTreePageHeaderSizeInBytes
        self.freeCellCount = 0
        self.checksumOffset = Medusa.kPageChecksumOffset
        self.pageAddress = 0
        self.initFreeCellList()
        }
        
    public init(from buffer: PageBuffer)
        {
        self.pageBuffer = buffer
        self.pageAddress = 0
        self.firstFreeCellOffset = 0
        self.readHeader()
        self.freeList = FreeList(pageBuffer: buffer, atByteOffset: self.firstFreeCellOffset)
        }
        
    public init(file: File,pageAddress: Medusa.PageAddress) throws
        {
        self.file = file
        self.pageAddress = pageAddress
        try self.file.seek(pageAddress: pageAddress)
        self.pageBuffer = try self.file.readPageBuffer(sizeInBytes: Medusa.kPageSizeInBytes)
        self.firstFreeCellOffset = 0
        self.readHeader()
        }
        
    internal func writeFreeList()
        {
        self.firstFreeCellOffset = self.freeList.firstCell?.byteOffset ?? 0
        self.freeList.write(to: self.pageBuffer)
        }
        
    internal func writeHeader()
        {
        self.freeCellCount = self.freeList.count
        self.pageBuffer.storeBytes(of: self.magicNumber,atByteOffset: Medusa.kPageMagicNumberOffset, as: Medusa.MagicNumber.self)
        self.pageBuffer.storeBytes(of: self.checksum,atByteOffset: Medusa.kPageChecksumOffset, as: Medusa.Checksum.self)
        self.pageBuffer.storeBytes(of: self.freeByteCount,atByteOffset: Medusa.kPageFreeByteCountOffset, as: Medusa.Integer.self)
        self.pageBuffer.storeBytes(of: self.freeList.firstCell?.byteOffset ?? 0,atByteOffset: Medusa.kPageFirstFreeCellOffsetOffset, as: Medusa.Integer.self)
        self.pageBuffer.storeBytes(of: self.freeCellCount,atByteOffset: Medusa.kPageFreeCellCountOffset, as: Medusa.Integer.self)
        }
        
    internal func readHeader()
        {
        self.magicNumber = self.pageBuffer.load(fromByteOffset: Medusa.kPageMagicNumberOffset, as: Medusa.MagicNumber.self)
        self.checksum = self.pageBuffer.load(fromByteOffset: Medusa.kPageChecksumOffset, as: Medusa.Checksum.self)
        // Store 0 into the checksum after we have loaded it so when we check the checksum it uses a value of 0 for the checksum in the calculation
        self.pageBuffer.storeBytes(of: Medusa.Checksum(0),atByteOffset: Medusa.kPageChecksumOffset, as: Medusa.Checksum.self)
        self.freeByteCount = self.pageBuffer.load(fromByteOffset: Medusa.kPageFreeByteCountOffset, as: Int.self)
        self.firstFreeCellOffset = self.pageBuffer.load(fromByteOffset: Medusa.kPageFirstFreeCellOffsetOffset, as: Int.self)
        self.freeCellCount = self.pageBuffer.load(fromByteOffset: Medusa.kPageFreeCellCountOffset, as: Int.self)
        }
        
    internal func initFreeCellList()
        {
        let offset = Medusa.kBTreePageHeaderSizeInBytes + MemoryLayout<Medusa.Integer>.size * Medusa.kBTreePageKeysPerPage
        self.firstFreeCellOffset = Int(offset)
        self.freeByteCount = Medusa.kBTreePageSizeInBytes - Medusa.kBTreePageHeaderSizeInBytes - Medusa.kBTreePageKeysPerPage * MemoryLayout<Medusa.Integer>.size
        self.freeList = FreeList(pageBuffer: self.pageBuffer,atByteOffset: self.firstFreeCellOffset,sizeInBytes: self.freeByteCount)
        self.freeList.write(to: self.pageBuffer)
        self.isDirty = true
        }
        
    internal func read()
        {
        self.readHeader()
        }
    }
