//
//  MedusaFileIdentifier.swift
//  Medusa
//
//  Created by Vincent Coetzee on 29/11/2023.
//

import Foundation
import Path

public class FileHandle
    {
    public static let empty = try! FileHandle(path: Path("/")!)
    
    public struct Mode: OptionSet
        {
        public static let read = Mode(rawValue: 1 << 1)
        public static let write = Mode(rawValue: 1 << 2)
        public static let execute = Mode(rawValue: 1 << 3)
        public static let create = Mode(rawValue: 1 << 5)
        public static let append = Mode(rawValue: 1 << 6)
        public static let readWrite = Mode(rawValue: 1 << 7)
        public static let nonBlocking = Mode(rawValue: 1 << 8)
        public static let truncate = Mode(rawValue: 1 << 9)
        public static let exclusive = Mode(rawValue: 1 << 10)
        
        public var rawValue: Int
        
        public var modeValue: Int32
            {
            var value: Int32 = 0
            if self.contains(.read)
                {
                value |= O_RDONLY
                }
            if self.contains(.write)
                {
                value |= O_WRONLY
                }
            if self.contains(.readWrite)
                {
                value |= O_RDWR
                }
            if self.contains(.execute)
                {
                value |= O_EXEC
                }
            if self.contains(.nonBlocking)
                {
                value |= O_NONBLOCK
                }
            if self.contains(.append)
                {
                value |= O_APPEND
                }
            if self.contains(.create)
                {
                value |= O_CREAT
                }
            if self.contains(.truncate)
                {
                value |= O_TRUNC
                }
            if self.contains(.exclusive)
                {
                value |= O_EXCL
                }
            return(value)
            }
            
        public init(rawValue: Int)
            {
            self.rawValue = rawValue
            }
        }
        
    public private(set) var fileDescriptor: Int32!
    public let path: Path
    public private(set) var mappedAddress: Medusa.Address?
    
    public init(path: Path) throws
        {
        self.path = path
        }
        
    public func open(mode: Mode...) throws -> Self
        {
        let modeValue = mode.reduce(0) { $0 | $1.modeValue }
        let string = self.path.string
        self.fileDescriptor = Darwin.open(string,modeValue)
        if self.fileDescriptor == -1
            {
            let string = String(cString: strerror(errno))
            let message = "Opening file at \(string) in mode \(mode) failed with error(\(errno)) \(string)"
            LoggingAgent.shared.log(message)
            throw(SystemIssue(code: .fileOpenFailed,agentKind: .pageServer,message: message))
            }
        LoggingAgent.shared.log("File at \(string) in mode \(mode) successfully opened for \(mode).")
        return(self)
        }
        
    public func map(to address: Medusa.Address,sizeInBytes: Integer64,offset: Integer64) throws
        {
        let stringAddress = String(address,radix: 16,uppercase: true)
        LoggingAgent.shared.log("Preparing to map segment at \(stringAddress) to file\(path.string).")
        if self.fileDescriptor < 1
            {
            LoggingAgent.shared.log("Invalid file descriptor (\(String(describing:self.fileDescriptor))) in FileHandle.map(to:sizeInBytes:offset).")
            throw(SystemIssue(code: .invalidFileDescriptor,agentKind: .pageServer))
            }
        var actualAddress = UnsafeMutableRawPointer(bitPattern: address)
        let result = mmap(actualAddress,sizeInBytes,PROT_WRITE,MAP_FIXED | MAP_SHARED,self.fileDescriptor,Int64(offset))
        if result == MAP_FAILED
            {
            let string = String(cString: strerror(errno))
            let message = "Mapping of segment at \(stringAddress) failed with error(\(errno)) \(string)"
            LoggingAgent.shared.log(message)
            throw(SystemIssue(code: .segmentMappingFailed,agentKind: .pageServer,message: message))
            }
        LoggingAgent.shared.log("Advising macOS of mmap usage: MADV_RANDOM,MADV_WILLNEED.")
        actualAddress = UnsafeMutableRawPointer(bitPattern: address)
        if madvise(actualAddress,sizeInBytes,MADV_RANDOM | MADV_WILLNEED) == -1
            {
            let string = String(cString: strerror(errno))
            let message = "Advising OS of segment at \(stringAddress) failed with error(\(errno)) \(string)"
            LoggingAgent.shared.log(message)
            throw(SystemIssue(code: .segmentAdviseFailed,agentKind: .pageServer,message: message))
            }
        LoggingAgent.shared.log("File \(self.path.string) sucessfully mapped into segment at \(stringAddress).")
        self.mappedAddress = address
        }
    }
