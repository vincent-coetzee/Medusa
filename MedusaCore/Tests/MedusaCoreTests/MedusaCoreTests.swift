import XCTest
@testable import MedusaCore

final class MedusaCoreTests: XCTestCase
    {
    func testReadingAndWritingFileIdentifiers()
        {
        let file = FileIdentifier(path: "/Users/vincent/Desktop.TestFile.dat")
        XCTAssertFalse(file.exists,"The file says it exists but it does not.")
        XCTAssertNoThrow(try file.create(truncate: true),"file.create(truncate: true) should have worked but did not.")
        XCTAssertTrue(file.exists,"The file exists but said it doesn't")
        XCTAssertNoThrow(try file.delete(),"The file deletion should have succeeded but did not.")
        }
        
    func testExample() throws
        {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
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
