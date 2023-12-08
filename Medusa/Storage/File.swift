////
////  File.swift
////  Medusa
////
////  Created by Vincent Coetzee on 24/11/2023.
////
//
//import Foundation
//import Path
//
//public class File
//    {
//    public enum Mode
//        {
//        case reading
//        case writing
//        case create
//        }
//
//    public let path: Path
//    public let mode: Mode
//    public var handle: UnsafeMutablePointer<FILE>?
//    public var seekOffset: Integer64 = 0
//    
//    public init(path: String,mode: Mode) throws
//        {
//        guard let somePath = Path(path) else
//            {
//            throw(SystemIssue(code: .invalidPath,agentKind: .storageAgent))
//            }
//        self.path = somePath
//        self.mode = mode
//        if mode == .reading
//            {
//            guard self.path.exists else
//                {
//                throw(SystemIssue(code: .fileDoesNotExist,agentKind: .storageAgent))
//                }
//            self.handle = fopen(self.path.string, "r")
//            if handle.isNil
//                {
//                let errorString = String(describing: strerror(errno))
//                throw(SystemIssue(code: .fileOpenFailed,agentKind: .storageAgent,message: "Opening \(self.path.string) failed with error (\(errno)) \(errorString)"))
//                }
//            }
//        else if mode == .create
//            {
//            guard !self.path.exists else
//                {
//                throw(SystemIssue(code: .fileExists,agentKind: .storageAgent,message: "The file \(self.path.string) could not be created because it exists."))
//                }
//            self.handle = fopen(self.path.string, "r")
//            if handle.isNil
//                {
//                let errorString = String(describing: strerror(errno))
//                throw(SystemIssue(code: .fileCreationFailed,agentKind: .storageAgent,message: "Opening \(self.path.string) failed with error (\(errno)) \(errorString)"))
//                }
//            }
//        else
//            {
//            guard self.path.exists else
//                {
//                throw(SystemIssue(code: .fileDoesNotExist,agentKind: .storageAgent,message: "The file \(self.path.string) could not be opened because it does not exist."))
//                }
//            self.handle = fopen(self.path.string, "r")
//            if handle.isNil
//                {
//                let errorString = String(describing: strerror(errno))
//                throw(SystemIssue(code: .fileOpenFailed,agentKind: .storageAgent,message: "Opening \(self.path.string) failed with error (\(errno)) \(errorString)"))
//                }
//            }
//        }
//        
//    public func seek(pageAddress: Medusa.Address) throws
//        {
//        guard fseek(self.handle, pageAddress.fileOffset, SEEK_SET) == 0 else
//            {
//            let errorString = String(describing: strerror(errno))
//            throw(SystemIssue(code: .filePositioningFailed,agentKind: .storageAgent,message: "Seeking \(self.path.string) failed with error (\(errno)) \(errorString)"))
//            }
//        self.seekOffset = pageAddress.fileOffset
//        }
//        
//    public func readBuffer(sizeInBytes: Integer64) throws -> UnsafeMutableRawPointer
//        {
//        guard feof(self.handle) == 0 else
//            {
//            throw(SystemIssue(code: .endOfFileReached,agentKind: .storageAgent))
//            }
//        let buffer = UnsafeMutableRawPointer.allocate(byteCount: sizeInBytes, alignment: 1)
//        let bytesRead = fread(buffer,1,sizeInBytes,self.handle)
//        guard bytesRead == sizeInBytes else
//            {
//            throw(SystemIssue(code: .fileReadFailedShort,agentKind: .storageAgent))
//            }
//        return(buffer)
//        }
//    }
