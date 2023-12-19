import XCTest
@testable import MedusaPaging
import MedusaCore

final class MedusaPagingTests: XCTestCase
    {
    func testPage() throws
        {
        let page = Page()
        XCTAssertTrue(page.bufferSizeInBytes == Page.kPageSizeInBytes,"bufferSizeInBytes should equal page sizeInBytes but does not.")
        XCTAssertEqual(page.freeList.firstCell.byteOffset,page.initialFreeCellOffset,"FreeList.first.byteOffset should == initialFreeCellOffset but does not.")
        var allocationSize = 512
        var offset = 0
        var startFreeCount = page.freeByteCount
        XCTAssertNoThrow(offset = try page.allocate(sizeInBytes: allocationSize),"Allocation of 512 bytes should have worked.")
        XCTAssertEqual(startFreeCount,page.freeByteCount + FreeBlockListCell.kCellHeaderSizeInBytes + allocationSize,"page.freeByteCount is not what it should be.")
        var targetOffset = page.initialFreeCellOffset - (allocationSize + FreeBlockListCell.kCellHeaderSizeInBytes) + FreeBlockListCell.kCellHeaderSizeInBytes
        XCTAssertEqual(offset,targetOffset,"Allocated offset and calculated offset don't agree.")
        allocationSize = 1029
        offset = 0
        startFreeCount = page.freeByteCount
        XCTAssertNoThrow(offset = try page.allocate(sizeInBytes: allocationSize),"Allocation of 1029 bytes should have worked.")
        XCTAssertEqual(startFreeCount,page.freeByteCount + FreeBlockListCell.kCellHeaderSizeInBytes + allocationSize,"page.freeByteCount is not what it should be.")
        targetOffset -= FreeBlockListCell.kCellHeaderSizeInBytes
        targetOffset = targetOffset - (allocationSize + FreeBlockListCell.kCellHeaderSizeInBytes) + FreeBlockListCell.kCellHeaderSizeInBytes
        XCTAssertEqual(offset,targetOffset,"Allocated offset and calculated offset don't agree.")
        XCTAssertThrowsError(try page.allocate(sizeInBytes: 65535),"Allocation of 65535 bytes should have failed.")
        }
        
    func testPageReadsAndWrites()
        {
        let page = Page()
        let allocationSize = 2034
        let allocatedOffset = try! page.allocate(sizeInBytes: allocationSize)
        let freeByteCount = page.freeByteCount
        let freeBlockListCount = page.freeList.count
        let magicNumber = page.magicNumber
        let pointer = page.buffer + allocatedOffset
        for index in 0..<1029
            {
            pointer.storeBytes(of: Byte(index % 256), as: Byte.self)
            }
        page.storeChecksum()
        let file = FileIdentifier(path: "/Users/vincent/Desktop/page.dat")
        if !file.exists
            {
            try! file.create(truncate: true)
            }
        try! file.setPOSIXPermissions(owner: .read,.write, group: .read,.write, other: .read)
        try! file.open(mode: .readWrite)
        XCTAssertNoThrow(try file.write(page.buffer,atOffset: 34567,sizeInBytes: Page.kPageSizeInBytes),"Page buffer should have written but it failed.")
        try! file.close()
        try! file.open(mode: .readWrite)
        var newBuffer: RawPointer!
        XCTAssertNoThrow(newBuffer = try file.readBuffer(atOffset: 34567, sizeInBytes: Page.kPageSizeInBytes),"Page buffer should have been read but read failed.")
        let newPage = Page(buffer: newBuffer, sizeInBytes: Page.kPageSizeInBytes)
        XCTAssertEqual(freeByteCount,newPage.freeByteCount,"Read page and written page free byte counts differ.")
        XCTAssertEqual(magicNumber,newPage.magicNumber,"Read magicNumber and written magicNumber differ.")
        XCTAssertEqual(freeBlockListCount,newPage.freeList.count,"Read freeList.count and written freeList.count don't agree.")
        XCTAssertNoThrow(try newPage.validateChecksum(),"The stored checksum and the calculated checksum do not agree.")
        }
    }
