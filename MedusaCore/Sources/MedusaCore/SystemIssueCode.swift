//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
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
    case insufficientFreeSpaceInPage                                = "There is not enough space to fit the object in the specified page"
    case incorrectReadSizeInDecodeMessage                           = "Incorrect byte count found when decoding message."
    case invalidMessageTypeInDecodeMessage                          = "Invalid message type value found when decoding message."
    case invalidFileDescriptor                                      = "The file descriptor is not valid, was the file opened ?"
    case invalidIntraPageAddress                                    = "The specified address is not valid for an intra page address."
    case invalidDeallocationAddress                                 = "The specified address is invalid in this allocator."
    
    case segmentMappingFailed                                       = "Memory mapping of segment ( mmap ) failed."
    case segmentAdviseFailed                                        = "Giving OS advise about segment usage failed."
    }
