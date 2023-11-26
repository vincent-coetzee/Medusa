//
//  File.swift
//  Medusa
//
//  Created by Vincent Coetzee on 24/11/2023.
//

import Foundation
import Path

public class File
    {
    public enum Mode
        {
        case reading
        case writing
        case create
        }

    public let path: Path
    public let mode: Mode
    public var handle: UnsafeMutablePointer<FILE>?
    public var seekOffset: Medusa.Integer64 = 0
    
    public init(path: String,mode: Mode) throws
        {
        guard let somePath = Path(path) else
            {
            throw(SystemIssue(code: .invalidPath,agentKind: .storageAgent,agentLocation: .unknown))
            }
        self.path = somePath
        self.mode = mode
        if mode == .reading
            {
            guard self.path.exists else
                {
                throw(SystemIssue(code: .fileDoesNotExist,agentKind: .storageAgent,agentLocation: .unknown))
                }
            self.handle = fopen(self.path.string, "r")
            if handle.isNil
                {
                let errorString = String(describing: strerror(errno))
                throw(SystemIssue(code: .fileOpenFailed,message: "Opening \(self.path.string) failed with error (\(errno)) \(errorString)",agentKind: .storageAgent,agentLocation: .unknown))
                }
            }
        else if mode == .create
            {
            guard !self.path.exists else
                {
                throw(SystemIssue(code: .fileExists,message: "The file \(self.path.string) could not be created because it exists.",agentKind: .storageAgent,agentLocation: .unknown))
                }
            self.handle = fopen(self.path.string, "r")
            if handle.isNil
                {
                let errorString = String(describing: strerror(errno))
                throw(SystemIssue(code: .fileCreationFailed,message: "Opening \(self.path.string) failed with error (\(errno)) \(errorString)",agentKind: .storageAgent,agentLocation: .unknown))
                }
            }
        else
            {
            guard self.path.exists else
                {
                throw(SystemIssue(code: .fileDoesNotExist,message: "The file \(self.path.string) could not be opened because it does not exist.",agentKind: .storageAgent,agentLocation: .unknown))
                }
            self.handle = fopen(self.path.string, "r")
            if handle.isNil
                {
                let errorString = String(describing: strerror(errno))
                throw(SystemIssue(code: .fileOpenFailed,message: "Opening \(self.path.string) failed with error (\(errno)) \(errorString)",agentKind: .storageAgent,agentLocation: .unknown))
                }
            }
        }
        
    public func seek(pageAddress: Medusa.PageAddress) throws
        {
        guard fseek(self.handle, pageAddress.fileOffset, SEEK_SET) == 0 else
            {
            let errorString = String(describing: strerror(errno))
            throw(SystemIssue(code: .filePositioningFailed,message: "Seeking \(self.path.string) failed with error (\(errno)) \(errorString)",agentKind: .storageAgent,agentLocation: .unknown))
            }
        self.seekOffset = pageAddress.fileOffset
        }
        
    public func readBuffer(sizeInBytes: Medusa.Integer64) throws -> UnsafeMutableRawPointer
        {
        guard feof(self.handle) == 0 else
            {
            throw(SystemIssue(code: .endOfFileReached,agentKind: .storageAgent,agentLocation: .unknown))
            }
        let buffer = UnsafeMutableRawPointer.allocate(byteCount: sizeInBytes, alignment: 1)
        let bytesRead = fread(buffer,1,sizeInBytes,self.handle)
        guard bytesRead == sizeInBytes else
            {
            throw(SystemIssue(code: .fileReadFailedShort,agentKind: .storageAgent,agentLocation: .unknown))
            }
        return(buffer)
        }
    }
