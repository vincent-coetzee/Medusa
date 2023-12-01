//
//  MedusaFileIdentifier.swift
//  Medusa
//
//  Created by Vincent Coetzee on 29/11/2023.
//

import Foundation
import Path

public struct FileIdentifier
    {
    public static let empty = try! FileIdentifier(path: "/")
    
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
        
    public var fileDescriptor: Int32!
    public let path: Path
    public var address: Medusa.Address?
    
    public init(path: String) throws
        {
        if let somePath = Path(path)
            {
            self.path = somePath
            }
        else
            {
            throw(SystemIssue(code: .invalidPath,agentKind: .pageServer))
            }
        }
        
    public mutating func open(mode: Mode) throws
        {
        let string = self.path.string
        self.fileDescriptor = Darwin.open(string,mode.modeValue)
        if self.fileDescriptor == -1
            {
            let message = String(cString: strerror(errno))
            throw(SystemIssue(code: .fileOpenFailed,agentKind: .pageServer,message: message))
            }
        
        }
        
    public func map(to: Medusa.Address) throws
        {
        if self.fileDescriptor < 1
            {
            throw(SystemIssue(code: .invalidFileDescriptor,agentKind: .pageServer))
            }
        }
    }
