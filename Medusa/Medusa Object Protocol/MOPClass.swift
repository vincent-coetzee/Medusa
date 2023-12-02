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
//            0   011     Bits                 = 3     Copy
//            0   100     Header               = 4     Copy
//            0   101     Object               = 5     Follow
//            0   110     Address              = 6     Follow
//            0   111     Nothing              = 7     Copy
//
//            
//Object Structure
//
//            Header 64 Bits           Sign ( 1 bit )           0                                                                          0   1
//                                     Tag ( 3 bits )            000                                                                       1   4
//                                     SizeInWords ( 36 bits )      0000 00000000 00000000 00000000 00000000                               4  40
//                                     HasBytes ( 1 bit )                                                   0                            40  41
//                                     FlipCount ( 13 bits = 8191 )                                          0000000 000000              41  54
//                                     IsForwarded ( 1 bit )                                                               0             54  55
//                                     Reserved ( 9 bits = 512 )                                                            0 00000000   55  64
//
//            Header                                            00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
//            Class Pointer                                     00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
//            Slot 0                                            00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
//
//            Slot N                                            00000000 00000000 00000000 00000000 000000000 00000000 00000000 00000000
//            Block Header             Sign Bit ( 1 bit )       0
//                                     Overflow Bit ( 1 bit )    0
//                                     Size in Words ( 36 bits )  000000 00000000 00000000 00000000 0000000
//                                                                                                         00 00000000 00000000 00000000
//
//            Next Block Address                                00000000 00000000 00000000 00000000 000000000 00000000 00000000 00000000
//            Bytes                                             0011???? ???????? ???????? ???????? ????????? ???????? ???????? ????????
//                                                              0011???? ???????? ???????? ???????? ????????? ???????? ???????? ????????
//                                                              0011???? ???????? ???????? ???????? ????????? ???????? ???????? ????????
//

public class MOPClass: MOPObject
    {
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
        
    public static let writeFileClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "WriteFile")!
        }()
        
    public static let writeStreamClass: MOPClass =
        {
        MOPArgonModule.shared.lookupClass(named: "WriteStream")!
        }()

        

        

        

        
    public static let ipv6Address = MOPIPv6Address(module: .argonModule,name: "IPv6Address").initialize()
    public static let messageType = MOPEnumeration(module: .argonModule,name: "MessageType",caseNames: "none","ping","pong","connect","connectAccept","connectReject","disconnect","disconnectAccept","Request","Response").initialize()
    public static let integer64 = MOPInteger64().setClass(.primitive)
    public static let string = MOPString().setClass(.primitive)
    public static let boolean = MOPBoolean().setClass(.primitive)
    public static let float64 = MOPFloat64().setClass(.primitive)
    public static let byte = MOPByte().setClass(.primitive)
    public static let unsigned64 = MOPUnsigned64().setClass(.primitive)
    public static let module = MOPModuleClass(module: .argonModule, name: "Module",ofClass: .class).initialize()
    public static let object = MOPClass(module: .argonModule,name: "Object",ofClass: .class)
    public static let `class` = MOPClass(module: .argonModule,name: "Class")
    public static let metaclass = MOPClass(module: .argonModule,name: "Metaclass")
    public static let primitive = MOPPrimitive(module: .argonModule,name: "Primitive")
    
    public var superklasses = WeakArray<MOPClass>()
    public var instanceVariables = Dictionary<String,MOPInstanceVariable>()
    public let name: String
    private var nextOffset = 8
    public private(set) var module: MOPModule
    private var _sizeInBytes: Integer64 = 0
    public private(set) var subklasses = Array<MOPClass>()
    
    public var isRootClass: Bool
        {
        self.name == "Object"
        }
    
    public var hasSubclasses: Bool
        {
        return(!self.subklasses.isEmpty)
        }
        
    public override var sizeInBytes: Integer64
        {
        self._sizeInBytes
        }
        
    public var identifier: Identifier
        {
        self.module.identifier + self.name
        }
        
    public init(module: MOPModule,name: String,ofClass: MOPClass? = nil,hasBytes: Bool = false)
        {
        self.name = name
        self.module = module
        super.init(ofClass: ofClass,hasBytes: hasBytes)
        }
        
    public func addInstanceVariable(name: String,klass: MOPClass)
        {
        let instanceVariable = MOPInstanceVariable(name: name,klass: klass,offset: self.nextOffset)
        self.instanceVariables[name] = instanceVariable
        self.nextOffset += instanceVariable.sizeInBytes
        }
        
    public func addPrimitiveInstanceVariable<R,T>(name: String,klass: MOPClass,keyPath: KeyPath<R,T>)
        {
        let instanceVariable = MOPPrimitiveInstanceVariable(name: name,klass: klass,offset: self.nextOffset,keyPath: keyPath)
        self.instanceVariables[name] = instanceVariable
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
    }

public typealias MOPClasses = Array<MOPClass>

public class MOPModuleClass: MOPClass
    {
    }
