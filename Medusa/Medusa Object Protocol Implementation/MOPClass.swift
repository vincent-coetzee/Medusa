//
//  MOPClass.swift
//  Medusa
//
//  Created by Vincent Coetzee on 17/11/2023.
//

import Foundation

//Values:
//    SIGN BIT    4 TAG BITS     TYPE
//    ===============================
//            1   000     Integer64            = 0     Copy
//            0   001     Float64              = 1     Copy
//            0   010     Atom                 = 2     Copy
//            0   011     Header               = 3     Copy
//            0   100     Object               = 4     Follow
//            0   101     Address              = 5     Follow
//            0   110     Enumeration          = 6     Follow
//            0   111     Nothing              = 7     Copy
//
//            
//Object Structure
//
//            Header 64 Bits           Sign ( 1 bit )                   0                                                                          0   1
//                                     Tag ( 3 bits )                    000                                                                       1   4
//                                     SizeInWords ( 36 bits )              0000 00000000 00000000 00000000 0000000                                4  40
//                                     HasBytes ( 1 bit )                                                          0                              40  41
//                                     FlipCount ( 13 bits = 8191 )                                                  00000000 000000              41  54
//                                     IsForwarded ( 1 bit )                                                                        0             54  55
//                                     IsMarked   ( 1 bit )                                                                          0            55  56
//                                     Reserved ( 8 bits = 512 )                                                                       RESERVED   56  64
//
//            Header                                                    00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000    0   8
//            Class Pointer                                             00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000    8  16
//            Slot 0 ( Hash value )                                     00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000   16  24
//            ...
//            ...
//            ...
//            Slot N                                                    00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000   16 + ( ivar count * 8 )
//
//            In an object with hasBytes = true then the last slot is followed by a count and an address, the count is the number of words in the bytes part of the object and the address is the page address of the first block
//
//            The initial number of slots allocated inside an object 
//            Block Header             Sign + Tag ( 4 bits )            0000
//                                     Block Slot Count ( 30 bits )         CCCC CCCCCCCC CCCCCCCC CCCCCCCC CC                                    The total number of slots in this block ( typically 128 - 2 slots )
//                                     Block Used Slot Count ( 30 bits )                                      UUUUUU UUUUUUUU UUUUUUUU UUUUUUUU   The number of used slots in this block ( 0 in object block i.e. first block header )
//                                     Address Next Block ( 60 bits )   S101AAAA AAAAAAAA AAAAAAAA AAAAAAAA AAAAAAAA AAAAAAAA AAAAAAAA AAAAAAAA   The page/offset address of the next block of slots
//
//
//            Addresses and object pointers are defined as follows
//
//                                     Address:
//                                               Sign ( 1 bit )         0
//                                               Tag ( 3 bits )          101
//                                               Reserved ( 10 bits)        0000 000000
//                                     Page offset ( 40 bits )                         PP PPPPPPPP PPPPPPPP PPPPPPPP PPPP
//                                     Intra page offset ( 14 bits )                                                     PPPP PPPPPPII IIIIIIII
//
//                                     Object Pointer:
//                                               Sign ( 1 bit )         0
//                                               Tag ( 3 bits )          100
//                                               Reserved ( 10 bits )       RRRR RRRRRR
//                                     Page offset ( 40 bits )                         PP PPPPPPPP PPPPPPPP PPPPPPPP PPPP
//                                     Intra page offset ( 14 bits )                                                     PPPP PPPPPPII IIIIIIII
//
//                                     Enumeration Pointer:
//                                           Sign ( 1 bit )             0
//                                           Tag ( 3 bits )              110
//                                           Associates Flag ( 1 bit )      F
//                                           Case Index ( 9 bits )           CCC CCCCC
//                                     Page offset ( 40 bits )                         PP PPPPPPPP PPPPPPPP PPPPPPPP PPPP
//                                     Intra page offset ( 14 bits )                                                     PPPP PPPPPPII IIIIIIII


public class MOPClass: MOPObjectInstance
    {
    //
    //
    // Define convenience accessors for the classes used by the system, these
    // are loaded either manually in prepartion for initalializing a database,
    // or they are loaded from the SystemDictionary called 'Medusa'
    //
    //
    public static let arrayClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "Array")!
        }()
        
    public static let atomClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "Atom")!
        }()
        
    public static let behaviourClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "Behaviour")!
        }()
        
    public static let booleanClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "Boolean")!
        }()
        
    public static let byteClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "Byte")!
        }()
        
    public static let classClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "Class")!
        }()
        
    public static let collectionClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "Collection")!
        }()
        
    public static let dateClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "Date")!
        }()
        
    public static let dictionaryClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "Dictionary")!
        }()
        
    public static let fileClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "File")!
        }()
        
    public static let fixedPointNumberClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "FixedPointNumber")!
        }()
        
    public static let float64Class: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "Float64")!
        }()
        
    public static let floatingPointNumberClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "FloatingPointNumber")!
        }()
        
    public static let identityDictionaryClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "IdentityDictionary")!
        }()
        
    public static let indexedCollectionClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "IndexedCollection")!
        }()
        
    public static let integer64Class: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "Integer64")!
        }()
        
    public static let integer32Class: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "Integer32")!
        }()
        
    public static let ipAddressClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "IPAddress")!
        }()
        
    public static let keyedCollectionClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "KeyedCollection")!
        }()
        
    public static let magnitudeClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "Magnitude")!
        }()
        
    public static let metaclassClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "Metaclass")!
        }()
        
    public static let moduleClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "Module")!
        }()
        
    public static let nothingClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "Nothing")!
        }()
        
    public static let numberClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "Number")!
        }()
        
    public static let objectClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "Object")!
        }()
        
    public static let primitiveClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "Primitive")!
        }()
        
    public static let readFileClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "ReadFile")!
        }()
        
    public static let readStreamClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "ReadStream")!
        }()
        
    public static let streamClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "Stream")!
        }()
        
    public static let stringClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "String")!
        }()
        
    public static let timeClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "Time")!
        }()
        
    public static let unicodeScalarClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "UnicodeScalar")!
        }()
        
    public static let writeFileClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "WriteFile")!
        }()
        
    public static let writeStreamClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "WriteStream")!
        }()

    public var superklasses = WeakArray<MOPClass>()
    public var slots = Dictionary<String,MOPSlot>()
    public let name: String
    private var nextOffset = 8
    public private(set) var module: MOPModule
    public private(set) var isIndexed = false
    public private(set) var isKeyed = false
    public private(set) var subklasses = Array<MOPClass>()
        
    public var isRootClass: Bool
        {
        self.name == "Object"
        }
    
    public var hasSubclasses: Bool
        {
        return(!self.subklasses.isEmpty)
        }
        
    //
    // This is the amount of space you have to allocate in a page to
    // actually write an instance of this class into. Objects are layed
    // out as follows ( as described above ):
    //
    // Object Header        8 bytes         0 offset
    // Class Pointer        8 bytes         8 offset
    // Slot 0               8 bytes         16 offset
    // ...
    // Slot N               8 bytes         N * 8 + 16
    //
    // The size in bytes is merely the sizes totalled EXCEPT
    // for objects that have bytes in which case the object
    // has a ByteBlock at the end of it which consists of
    //
    //  a Block Header which is 8 bytes in size
    //  a Next Block Address which is 8 bytes in size
    // so BytesBlock is of size 16 whihc has to be added
    // to the sum in the previous calculation. This is only
    // for objects that have the hasBytes flag bit set to 1.
    //
    public override var sizeInBytes: Integer64
        {
        var size = Medusa.kMedusaObjectFixedPartSizeInBytes
        size += self.slots.values.reduce(0){$0 + $1.sizeInBytes}
        size += self.hasBytes ? Medusa.kMedusaObjectArrayBlockSizeInBytes : 0
        return(size)
        }
        
    public var slotSizeInBytes: Integer64
        {
        MemoryLayout<Integer64>.size
        }
        
    public var identifier: Identifier
        {
        self.module.identifier + self.name
        }
        
    public init(module: MOPModule,name: String,ofClass: MOPClass? = nil,hasBytes: Bool = false)
        {
        self.name = name
        self.module = module
        self._hasBytes = hasBytes
        super.init(ofClass: ofClass)
        }
        
    public static func ==(lhs: MOPClass,rhs: MOPClass) -> Bool
        {
        lhs.objectID == rhs.objectID
        }
        
    public func addSlot(name: String,class klass: MOPClass)
        {
        let instanceVariable = MOPSlot(name: name,klass: klass,offset: self.nextOffset)
        self.slots[name] = instanceVariable
        self.nextOffset += instanceVariable.sizeInBytes
        }
        
    private func addSubclass(_ someClass: MOPClass)
        {
        self.subklasses.append(someClass)
        self.subklasses = self.subklasses.sorted{$0.name < $1.name}
        }
        
    @discardableResult
    public func initialize() -> Self
        {
        self
        }
        
    @discardableResult
    public func setSuperclasses(_ classes: MOPClass...) -> Self
        {
        self.superklasses = WeakArray<MOPClass>(classes)
        for someClass in classes
            {
            someClass.addSubclass(self)
            }
        return(self)
        }
        
    @discardableResult
    public func setSuperclass(_ someClass: MOPClass) -> Self
        {
        self.superklasses = WeakArray<MOPClass>([someClass])
        someClass.addSubclass(self)
        return(self)
        }
        
    @discardableResult
    public func setModule(_ module: MOPModule) -> Self
        {
        self.module = module
        return(self)
        }
        
    public func writeValue<T>(_ value: T,into buffer: RawBuffer,atByteOffset offset: inout Integer64)
        {
        buffer.storeBytes(of: value, toByteOffset: offset, as: T.self)
        offset += MemoryLayout<T>.size
        }
    }

public typealias MOPClasses = Array<MOPClass>

public class MOPModuleClass: MOPClass
    {
    }
