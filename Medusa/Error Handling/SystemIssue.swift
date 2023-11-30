//
//  SystemIssue.swift
//  Medusa
//
//  Created by Vincent Coetzee on 23/11/2023.
//

import Foundation

public enum SystemIssueCode: String
    {
    case enumerationRawValueNotValidInDecodeEnumeration             = "The raw value of an enumeration is not valid when decoding enumeration."
    case endOfFileReached                                           = "Reading has reached the end of the file."
    
    case fileDoesNotExist                                           = "The specified file does not exist."
    case fileOpenFailed                                             = "Opening the specified file failed."
    case fileExists                                                 = "The specified file already exists."
    case fileCreationFailed                                         = "Creating the specified file failed."
    case filePositioningFailed                                      = "The specified file cursor could not be positioned at the specified offset."
    case fileReadFailedShort                                        = "Reading the specified file returned less bytes than requested."
    
    case messageDecodingClassNotFound                               = "A class needed to decode an encoded message is missing."
    
    case invalidNumberOfBytesReadInRead                             = "Number of bytes read does not match buffer size in ByteBuffer.read(from:)"
    case invalidPath                                                = "The specified path can not be opened."
    case insufficientFreeSpace                                      = "There is not enough space to fit the object"
    case incorrectReadSizeInDecodeMessage                           = "Incorrect byte count found when decoding message."
    case invalidMessageTypeInDecodeMessage                          = "Invalid message type value found when decoding message."
    case invalidFileDescriptor                                      = "The file descriptor is not valid, was the file opened ?"
    case invalidIntraPageAddress                                    = "The specified address is not valid for an intra page address."
    }
    
public enum AgentKind
    {
    case unknown
    case storageAgent
    case edgeAgent
    case pageServer
    case monitorAgent
    case freePageServer
    case executionAgent
    case loggingAgent
    }
    
public struct SystemIssue: Error
    {
    private let _message: String?
    public let code: SystemIssueCode
    public var agentKind: AgentKind
        
    public var message: String
        {
        self._message ?? self.code.rawValue
        }
        
    public init(code: SystemIssueCode,agentKind: AgentKind,message: String? = nil)
        {
        self.code = code
        self._message = message
        self.agentKind = agentKind
        }
    }
    
