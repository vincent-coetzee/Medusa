import XCTest
@testable import MedusaCore

final class MedusaCoreTests: XCTestCase
    {
    func testFileActions()
        {
        let file = FileIdentifier(path: "/Users/vincent/Desktop/TestFile.dat")
        XCTAssertFalse(file.exists,"The file says it exists but it does not.")
        XCTAssertNoThrow(try file.create(truncate: true),"file.create(truncate: true) should have worked but did not.")
        XCTAssertTrue(file.exists,"The file exists but said it doesn't")
        XCTAssertNoThrow(try file.delete(),"The file deletion should have succeeded but did not.")
        }
        
    func testFileReadingAndWriting()
        {
        let file = FileIdentifier(path: "/Users/vincent/Desktop/TestFile.dat")
        if !file.exists
            {
            _ = try? file.create(truncate: true)
            }
        XCTAssertTrue(file.exists,"File should exist by now but does not.")
        try! file.setPOSIXPermissions(owner: .read,.write, group: .read,.write, other: .read)
        XCTAssertNoThrow(try file.open(mode: .readWrite),"File should have opened but did not.")
        let buffer = RawPointer.allocate(byteCount: 1024, alignment: 1)
        buffer.initializeMemory(as: Byte.self, to: 7)
        var firstTotal = 0
        for index in 0..<1024
            {
            let pointer = buffer + index
            firstTotal += Integer64(pointer.load(as: Byte.self))
            }
        XCTAssertNoThrow(try file.write(buffer,atOffset: 0,sizeInBytes: 1024),"File should have written 1024 bytes but failed.")
        XCTAssertNoThrow(try file.close(),"File should have closed but failed.")
        XCTAssertNoThrow(try file.open(mode: .readWrite),"File should have opened but did not.")
        XCTAssertNoThrow(try file.seek(toOffset: 0),"File should have positioned at 0 but failed.")
        var readBuffer: RawPointer!
        XCTAssertNoThrow(readBuffer = try file.readBuffer(atOffset: 0, sizeInBytes: 1024),"File should have read buffer of size 1024 but failed.")
        var secondTotal = 0
        for index in 0..<1024
            {
            let pointer = readBuffer + index
            secondTotal += Integer64(pointer.load(as: Byte.self))
            }
        XCTAssertTrue(firstTotal == secondTotal,"Data from first write differs from data from second read.")
        try! file.close()
        try! file.delete()
        }
        
    func testHeader()
        {
        let header = Header(bitPattern: 0)
        header.sign = 1
        XCTAssertTrue(header.bitPattern == Header.kSignMask,"Sign bit should be set and is not. Bits are \(header.bitPattern.bitString)")
        XCTAssertTrue(header.sign == 1,"Sign bit should be 1 and is not.Bits are \(header.bitPattern.bitString)")
        header.sign = 0
        XCTAssertTrue(header.bitPattern == 0,"Sign bit should be 0 and is not.")
        XCTAssertTrue(header.sign == 0,"Sign bit should be 0 and is not.")
        
        header.bitPattern = 0
        header.hasBytes = true
        XCTAssertTrue(header.bitPattern == Header.kHasBytesMask,"HasBytes bit should be set and is not.")
        XCTAssertTrue(header.hasBytes,"HasBytes should be true and is not.")
        header.hasBytes = false
        XCTAssertTrue(header.bitPattern == 0,"HasBytes bit should be 0 and is not.")
        XCTAssertFalse(header.hasBytes,"HasBytes should be false and is not.")
        
        header.bitPattern = 0
        header.isHeader = true
        XCTAssertTrue(header.bitPattern == Header.kIsHeaderMask,"IsHeader bit should be set and is not.")
        XCTAssertTrue(header.isHeader,"IsHeader should be true and is not.")
        header.isHeader = false
        XCTAssertTrue(header.bitPattern == 0,"IsHeader bit should be 0 and is not.")
        XCTAssertFalse(header.isHeader,"IsHeader should be false and is not.")
        
        header.bitPattern = 0
        header.isForwarded = true
        XCTAssertTrue(header.bitPattern == Header.kIsForwardedMask,"IsForwarded bit should be set and is not.")
        XCTAssertTrue(header.isForwarded,"IsForwarded should be true and is not.")
        header.isForwarded = false
        XCTAssertTrue(header.bitPattern == 0,"IsForwarded bit should be 0 and is not.")
        XCTAssertFalse(header.isForwarded,"IsForwarded should be false and is not.")
        
        header.bitPattern = 0
        header.isMarked = true
        XCTAssertTrue(header.bitPattern == Header.kIsMarkedMask,"isMarked bit should be set and is not.")
        XCTAssertTrue(header.isMarked,"isMarked should be true and is not.")
        header.isMarked = false
        XCTAssertTrue(header.bitPattern == 0,"isMarked bit should be 0 and is not.")
        XCTAssertFalse(header.isMarked,"isMarked should be false and is not.")
        
        header.bitPattern = 0
        header.sizeInWords = 0b111111_11111111_11111111_11111111_11111111_1
        XCTAssertTrue(header.bitPattern == Header.kSizeInWordsMask,"sizeInWords bits should be set and are not. Bits are \(header.bitPattern.bitString)")
        XCTAssertTrue(header.sizeInWords == 0b111111_11111111_11111111_11111111_11111111_1,"sizeInWords should be 0b111111_11111111_11111111_11111111_11111111_1 and is not.")
        header.sizeInWords = 0
        XCTAssertTrue(header.bitPattern == 0,"sizeInWords bit should be 0 and is not.")
        XCTAssertTrue(header.sizeInWords == 0,"sizeInWords should be 0 and is not.")
        
        header.bitPattern = 0
        header.flipCount = 0b111111_11111111
        XCTAssertTrue(header.bitPattern == Header.kFlipCountMask,"flipCount bits should be set and are not.")
        XCTAssertTrue(header.flipCount == 0b111111_11111111,"flipCount should be 0b111111_11111111 and is not.")
        header.flipCount = 0
        XCTAssertTrue(header.bitPattern == 0,"flipCount bits should be 0 and are not.")
        XCTAssertTrue(header.flipCount == 0,"flipCount should be 0 and is not.")
        }
    }

func XCTAssertThrowsError<T, E: Error & Equatable>(_ expression: @autoclosure () throws -> T,error: E,in file: StaticString = #file,line: UInt = #line)
    {
    var thrownError: Error?
    XCTAssertThrowsError(try expression(),file: file,line: line)
        {
        thrownError = $0
        }
    XCTAssertTrue(thrownError is E,"Unexpected error type: \(type(of: thrownError))",file: file,line: line)
    XCTAssertEqual(thrownError as? E,error,file: file,line: line)
    }
