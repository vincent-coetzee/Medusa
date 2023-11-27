//
//  Medusa.swift
//  Medusa
//
//  Created by Vincent Coetzee on 16/11/2023.
//

import AppKit
import Fletcher

public struct Medusa
    {
    public typealias Float = Swift.Double
    public typealias Integer64 = Swift.Int
    public typealias Integer32 = Swift.Int32
    public typealias Integer16 = Swift.Int16
    public typealias String = Swift.String
    public typealias Byte = Swift.UInt8
    public typealias ObjectID = Swift.UInt64
    public typealias Atom = ObjectID
    public typealias Boolean = Swift.Bool
    public typealias Enumeration = MOPEnumeration
    public typealias MagicNumber = UInt64
    public typealias Offset = Integer64
    public typealias Checksum = UInt64
    public typealias PagePointer = Integer64
    public typealias Bytes = MedusaBytes
    public typealias PageAddress = Integer64
    public typealias Unsigned64 = UInt64
    public typealias Unsigned32 = UInt32
    public typealias Unsigned16 = UInt16
    public typealias FileIdentifier = Int
    
    public static let kMedusaServiceType = "_medusa._tcp."
    public static let kHostName = Host.current().localizedName!
    public static let kPrimaryServicePort: Int32 = 52000
    public static let kDefaultBufferSize: Int = 4096
    public static let kSocketReadBufferSize = 16 * 1024
    public static let kPageOffsetBits = 14
    public static let kPageOffsetMask = 0b11111111111111
    public static let kPagePageMask = 9_223_372_036_854_767_616
    public static let kPageBitsMask = 1_125_899_906_842_623
    
    public static let kPageMagicNumberOffset                = 0
    public static let kPageChecksumOffset                   = 8
    public static let kPageFreeByteCountOffset              = 16
    public static let kPageFirstFreeCellOffsetOffset        = 24
    public static let kPageFreeCellCountOffset              = 32
    public static let kPageHeaderSizeInBytes                = 40
    
    public static let kBTreePageRightPointerOffset               = 40
    public static let kBTreePageKeyEntryCountOffset              = 48
    public static let kBTreePageKeysPerPageOffset                = 56
    public static let kBTreePageHeaderSizeInBytes                = 64
    
    public static let kPageSizeInBytes                           = 16 * 1024
    public static let kBTreePageSizeInBytes                      = Medusa.kPageSizeInBytes
    public static let kBTreePageDefaultKeysPerPage               = 50
    public static let kBTreePageFirstCellOffset                  = 50 * MemoryLayout<Int>.size + Self.kBTreePageHeaderSizeInBytes
    
    public static let kBTreePageMagicNumber: MagicNumber    = 0xFADE0000D00DF00D
    
    public static func bitString(_ word: Word) -> String
        {
        let little = word.littleEndian
        var bit: Word = 1
        var string = String()
        for index in 0..<64
            {
            if index % 8 == 0 && index != 0
                {
                string += " "
                }
            string += (little & bit == bit ? "1" : "0")
            bit <<= 1
            }
        return(String(string.reversed()))
        }

    public static func bitString(_ integer: Int) -> String
        {
        let little = integer.littleEndian
        var bit: Int = 1
        var string = String()
        for index in 0..<64
            {
            if index % 8 == 0 && index != 0
                {
                string += " "
                }
            string += (little & bit == bit ? "1" : "0")
            bit <<= 1
            }
        return(String(string.reversed()))
        }
        
    public static func bitString(_ integer32: Int32) -> String
        {
        let little = integer32.littleEndian
        var bit: Int32 = 1
        var string = String()
        for index in 0..<32
            {
            if index % 8 == 0 && index != 0
                {
                string += " "
                }
            string += (little & bit == bit ? "1" : "0")
            bit <<= 1
            }
        return(String(string.reversed()))
        }
        
    public static func bitString(_ integer16: Int16) -> String
        {
        let little = integer16.littleEndian
        var bit: Int16 = 1
        var string = String()
        for index in 0..<16
            {
            if index % 8 == 0 && index != 0
                {
                string += " "
                }
            string += (little & bit == bit ? "1" : "0")
            bit <<= 1
            }
        return(String(string.reversed()))
        }
        
    public static func bitString(_ integer16: UInt16) -> String
        {
        let little = integer16.littleEndian
        var bit: UInt16 = 1
        var string = String()
        for index in 0..<16
            {
            if index % 8 == 0 && index != 0
                {
                string += " "
                }
            string += (little & bit == bit ? "1" : "0")
            bit <<= 1
            }
        return(String(string.reversed()))
        }
        
    public static func bitString(_ integer64: UInt32) -> String
        {
        let little = integer64.littleEndian
        var bit: UInt32 = 1
        var string = String()
        for index in 0..<32
            {
            if index % 8 == 0 && index != 0
                {
                string += " "
                }
            string += (little & bit == bit ? "1" : "0")
            bit <<= 1
            }
        return(String(string.reversed()))
        }
        
    public static func bitString(_ integer8: Medusa.Byte) -> String
        {
        let little = integer8.littleEndian
        var bit: Medusa.Byte = 1
        var string = String()
        for index in 0..<8
            {
            if index % 8 == 0 && index != 0
                {
                string += " "
                }
            string += (little & bit == bit ? "1" : "0")
            bit <<= 1
            }
        return(String(string.reversed()))
        }
        
    public static func bitString(_ float: Medusa.Float) -> String
        {
        let floatPointer = UnsafeMutablePointer<Medusa.Float>.allocate(capacity: 1)
        floatPointer.pointee = float
        let rawPointer = UnsafeRawPointer(OpaquePointer(floatPointer))
        var string = String()
        for index in 0..<8
            {
            let byte = rawPointer.load(fromByteOffset: index, as: Medusa.Byte.self)
            let smallString = Medusa.bitString(byte)
            string += smallString + " "
            }
        return(string)
        }
        
    public static func runTests()
        {
        testFields()
        testFletcher()
        testTags()
        testBTreePages()
        }
    }

extension Medusa.PagePointer
    {
    public init(page: Int,offset: Int)
        {
        var number: Medusa.Integer64
        
        number = Medusa.Integer64(offset) & Medusa.kPageOffsetMask
        number |= (Medusa.Integer64(page) & Medusa.kPageBitsMask) << Medusa.kPageOffsetBits
        self = number
        }
        
    public var pageValue: Int
        {
        Int(self >> Medusa.kPageOffsetBits)
        }
        
    public var offsetValue: Int
        {
        Int(self & Medusa.kPageOffsetMask)
        }
    }

extension Medusa.PageAddress
    {
    public var fileOffset: Int
        {
        Int(self & ~Medusa.kPageOffsetMask)
        }
    }
    


extension Word
    {
    public var bitString: String
        {
        Medusa.bitString(self)
        }
    }

public func testFletcher()
    {
    let buffer = UnsafeMutableRawPointer.allocate(byteCount: 200, alignment: 1)
    let integer = 1_000_001
    writeInteger(buffer,integer,20)
    var readInteger = readInteger(buffer,20)
    assert(readInteger == integer,"readInteger != integer and should be.")
    var offset = 55
    writeIntegerWithOffset(buffer,integer,&offset)
    let before = 55
    offset = 55
    readInteger = readIntegerWithOffset(buffer,&offset)
    assert(integer == readInteger,"integer != readInteger and sbhould be.")
    assert(before + 8 == offset,"offset != before + 8 and should be.")
    }
    
public func testTags()
    {
    var word = Word(0)
    word.tag = .zilch
    print("BITS OF zilch ARE   : \(word.bitString)")
    var wordTag = word.tag
    assert(wordTag.rawValue == Tag.zilch.rawValue,"TAG OF zilch SHOULD BE \(Tag.zilch.rawValue.bitString) BUT IS \(wordTag.rawValue.bitString).")
    let minusOne = Int(-1)
    let minusOneWord = Word(bitPattern: minusOne)
    print("BITS OF -1 ARE      : \(minusOneWord.bitString)")
    print("BITS OF 1 ARE       : \(Word(1).bitString)")
    print("BITS OF 255 ARE     : \(Word(255).bitString)")
    print("BITS OF true ARE    : \(Word(boolean: true).bitString)")
    print("BITS OF object ARE  : \(Word(object: 1_000_000).bitString)")
    print("BITS OF enum ARE    : \(Word(enumeration: 27).bitString)")
    word = Word(object: 1_000_000)
    wordTag = word.tag
    assert(wordTag.rawValue == Tag.object.rawValue,"TAG OF object SHOULD BE \(Tag.object.rawValue.bitString) BUT IS \(wordTag.rawValue.bitString).")
    assert(word.payload == 1_000_000,"PAYLOAD OF OBJECT SHOULD BE 1_000_000 BUT IS \(word.payload).")
    print("PAYLOAD OF object IS: \(word.payload).")
    print("SIGN OF -1 IS       : \(minusOneWord.sign).")
    assert(minusOneWord.sign == -1,"SIGN OF -1 SHOULD BE -1 BUT IS \(minusOneWord.sign).")
    let plusOne = Word(bitPattern: 1)
    print("SIGN OF 1 IS        : \(plusOne.sign).")
    assert(plusOne.sign == 1,"SIGN OF 1 SHOULD BE 1 BUT IS \(plusOne.sign).")
    var someWord = Word(0)
    someWord.tag = .boolean
    print("BITS OF boolean ARE : \(someWord.bitString).")
    assert(someWord.tag == .boolean,"TAG OF boolean SHOULD BE .boolean BUT IS \(someWord.tag).")
    }

public func testFields()
    {
    let field = Field(index: 1, name: "field", value: .fixedLengthString(21,""), offset: 11)
    let sections = field.sections(withRowWidth: 4)
    print(sections)
    }
    
public func testBTreePages()
    {
    let page1 = BTreePage<String,String>(magicNumber: 0xDEADB00BDEADB00B)
//    let page2 = BTreePage<String,String>(magicNumber: 0xCAFEBABEDEADBEEF)
    do
        {
        try page1.insertKeyEntry(key: "George VI",value: "This is a royal string.",pointer: 27_270_270)
//        try page2.insertKeyEntry(key: "George VI",value: "This is a royal string.",pointer: 27_270_270)
        try page1.insertKeyEntry(key: "Charles III",value: "He is the latest king of England. Son of the later Queen.",pointer: 3_333_333)
//        try page2.insertKeyEntry(key: "Charles III",value: "He is the latest king of England.",pointer: 3_333_333)
        try page1.insertKeyEntry(key: "Wattled Grebe",value: "The plainest of birds to be found in the Kruger Park.",pointer: 9_999_999)
//        try page2.insertKeyEntry(key: "Leopard-Tailed Barbet",value: "A most unusual bird.",pointer: 1_111_111)
        }
    catch let error as SystemIssue
        {
        print("Insertion of key entries failed with error: \(error).")
        }
    catch
        {
        print("error")
        }
    page1.write()
    let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
    let windowController = storyboard.instantiateController(withIdentifier: "bufferBrowserWindowController") as! NSWindowController
    let viewController = windowController.contentViewController as! BufferBrowserViewController
    windowController.showWindow(nil)
    let page3 = BTreePage<String,String>(from: page1)
    viewController.leftBuffer = PageWrapper(page: page1)
    viewController.rightBuffer = PageWrapper(page: page3)
    let windowController1 = storyboard.instantiateController(withIdentifier: "btreePageInspectorWindowController") as! NSWindowController
    let viewController1 = windowController1.contentViewController as! BTreePageInspectorViewController
    windowController1.showWindow(nil)
    windowController1.window?.title = "Page 1"
    viewController1.btreePage = page1
    let windowController2 = storyboard.instantiateController(withIdentifier: "btreePageInspectorWindowController") as! NSWindowController
    let viewController2 = windowController2.contentViewController as! BTreePageInspectorViewController
    windowController2.showWindow(nil)
    windowController2.window?.title = "Page 3"
    viewController2.btreePage = page3
//    let windowController2 = storyboard.instantiateController(withIdentifier: "btreePageInspectorWindowController") as! NSWindowController
//    let viewController2 = windowController2.contentViewController as! BTreePageInspectorViewController
//    windowController2.showWindow(nil)
//    windowController2.window?.title = "Page 3"
//    viewController2.btreePage = page3
//    assert(page1.entryCount == page3.entryCount,"PAGE1.entryCount(\(page1.entryCount)) SHOULD == PAGE3.entryCount(\(page3.entryCount)) BUT DOES NOT.")
//    for (entry1,entry2) in zip(page1.keyEntries,page3.keyEntries)
//        {
//        assert(entry1.key == entry2.key,"ENTRY1.key SHOULD == ENTRY2.key BUT DOES NOT.")
//        assert(entry1.value == entry2.value,"ENTRY1.value SHOULD == ENTRY2.value BUT DOES NOT.")
//        assert(entry1.pointer == entry2.pointer,"ENTRY1.pointer SHOULD == ENTRY2.pointer BUT DOES NOT.")
//        }
    }
