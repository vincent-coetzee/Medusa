//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import Path

public class FileIdentifier
    {
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
        
    public var fileExists: Bool
        {
        FileManager.default.fileExists(atPath: self.path.string)
        }
        
    public private(set) var fileDescriptor: Int32!
    public let path: Path
    public private(set) var mappedAddress: Integer64?
    private let logger: Logger
    
    public init(path: Path,logger: Logger)
        {
        self.logger = logger
        self.path = path
        }
        
    @discardableResult
    public func open(mode: Mode...) throws -> Self
        {
        let modeValue = mode.reduce(0) { $0 | $1.modeValue }
        let string = self.path.string
        self.fileDescriptor = Darwin.open(string,modeValue)
        if self.fileDescriptor == -1
            {
            let string = String(cString: strerror(errno))
            let message = "Opening file at \(string) in mode \(mode) failed with error(\(errno)) \(string)"
            self.logger.log(message)
            throw(SystemIssue(code: .fileOpenFailed,agentKind: .pageServer,message: message))
            }
        self.logger.log("File at \(string) in mode \(mode) successfully opened for \(mode).")
        return(self)
        }
        
    public func seek(to offset: Integer64) throws
        {
        self.logger.log("About to seek to offset \(offset) in file \(self.path.string).")
        if lseek(self.fileDescriptor,Int64(offset),SEEK_SET) != Int64(offset)
            {
            let error = String(cString: strerror(errno))
            self.logger.log("Seek to offset \(offset) in file \(self.path.string) failed with error(\(errno),\(error)).")
            throw(SystemIssue(code: .seekFailed, agentKind: .pageServer, message: "Unable to seek to offset \(offset) in file \(self.path.string) with error(\(errno),\(error))."))
            }
        self.logger.log("lseek to offset \(offset) in file \(self.path.string) successful.")
        }
        
    public func readBuffer(at offset: Integer64,sizeInBytes: Integer64) throws -> RawPointer
        {
        try self.seek(to: offset)
        let buffer = RawPointer.allocate(byteCount: sizeInBytes, alignment: 1)
        self.logger.log("Reading \(sizeInBytes) from file \(self.path.string).")
        if read(self.fileDescriptor,buffer,sizeInBytes) != sizeInBytes
            {
            let error = String(cString: strerror(errno))
            buffer.deallocate()
            throw(SystemIssue(code: .readBufferFailed,agentKind: .pageServer,message: "Reading \(sizeInBytes) from \(self.path.string) failed with error(\(errno),\(error))."))
            }
        return(buffer)
        }
        
    public func writeBuffer(_ buffer: RawPointer,at offset: Integer64,sizeInBytes: Integer64) throws
        {
        try self.seek(to: offset)
        self.logger.log("Writing \(sizeInBytes) bytes to file \(self.path.string).")
        if write(self.fileDescriptor,buffer,sizeInBytes) != sizeInBytes
            {
            let error = String(cString: strerror(errno))
            throw(SystemIssue(code: .writeBufferFailed,agentKind: .pageServer,message: "Writing \(sizeInBytes) bytes to \(self.path.string) failed with error(\(errno),\(error))."))
            }
        }
        
    public func map(to address: Integer64,sizeInBytes: Integer64,offset: Integer64) throws
        {
        let stringAddress = String(address,radix: 16,uppercase: true)
        self.logger.log("Preparing to map segment at \(stringAddress) to file\(path.string).")
        if self.fileDescriptor < 1
            {
            self.logger.log("Invalid file descriptor (\(String(describing:self.fileDescriptor))) in FileHandle.map(to:sizeInBytes:offset).")
            throw(SystemIssue(code: .invalidFileDescriptor,agentKind: .pageServer))
            }
        var actualAddress = UnsafeMutableRawPointer(bitPattern: address)
        let result = mmap(actualAddress,sizeInBytes,PROT_WRITE,MAP_FIXED | MAP_SHARED,self.fileDescriptor,Int64(offset))
        if result == MAP_FAILED
            {
            let string = String(cString: strerror(errno))
            let message = "Mapping of segment at \(stringAddress) failed with error(\(errno)) \(string)"
            self.logger.log(message)
            throw(SystemIssue(code: .segmentMappingFailed,agentKind: .pageServer,message: message))
            }
        self.logger.log("Advising macOS of mmap usage: MADV_RANDOM,MADV_WILLNEED.")
        actualAddress = UnsafeMutableRawPointer(bitPattern: address)
        if madvise(actualAddress,sizeInBytes,MADV_RANDOM | MADV_WILLNEED) == -1
            {
            let string = String(cString: strerror(errno))
            let message = "Advising OS of segment at \(stringAddress) failed with error(\(errno)) \(string)"
            self.logger.log(message)
            throw(SystemIssue(code: .segmentAdviseFailed,agentKind: .pageServer,message: message))
            }
        self.logger.log("File \(self.path.string) sucessfully mapped into segment at \(stringAddress).")
        self.mappedAddress = address
        }
        
    public func readInteger64(at offset: Integer64) throws -> Integer64
        {
        try self.seek(to: offset)
        var value: Integer64 = 0
        self.logger.log("Reading Integer64 from file \(self.path.string).")
        if read(self.fileDescriptor,&value,MemoryLayout<Integer64>.size) != MemoryLayout<Integer64>.size
            {
            let error = String(cString: strerror(errno))
            throw(SystemIssue(code: .readBufferFailed,agentKind: .pageServer,message: "Reading Integer64 from \(self.path.string) failed with error(\(errno),\(error))."))
            }
        return(value)
        }
        
    public func readUnsigned64(at offset: Integer64) throws -> Unsigned64
        {
        try self.seek(to: offset)
        var value: Unsigned64 = 0
        self.logger.log("Reading Unsigned64 from file \(self.path.string).")
        if read(self.fileDescriptor,&value,MemoryLayout<Unsigned64>.size) != MemoryLayout<Unsigned64>.size
            {
            let error = String(cString: strerror(errno))
            throw(SystemIssue(code: .readBufferFailed,agentKind: .pageServer,message: "Reading Unsigned64 from \(self.path.string) failed with error(\(errno),\(error))."))
            }
        return(value)
        }
        
    public func writeInteger64(_ integer: Integer64,at offset: Integer64) throws
        {
        try self.seek(to: offset)
        var value: Integer64 = integer
        self.logger.log("Write Integer64 to file \(self.path.string).")
        if write(self.fileDescriptor,&value,MemoryLayout<Integer64>.size) != MemoryLayout<Integer64>.size
            {
            let error = String(cString: strerror(errno))
            throw(SystemIssue(code: .writeBufferFailed,agentKind: .pageServer,message: "Writing Integer64 to \(self.path.string) failed with error(\(errno),\(error))."))
            }
        }
    }
