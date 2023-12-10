//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import MedusaCore
import MedusaPaging
import Path

extension Medusa
    {
    public static let kMappedSegmentAddress: Integer64      = 0b01000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    public static let kMappedSegmentSizeInBytes: Integer64  = 0b00000000_00000000_00011111_11111111_11111111_11111111_11111111_11111111
    public static let kMedusaDirectoryPath                  = Path("/Users/vincent/Medusa")!
    public static let kMedusaDataDirectoryPath              = Medusa.kMedusaDirectoryPath + "/Data"
    public static let kMedusaLogDirectoryPath               = Medusa.kMedusaDirectoryPath + "/Logs"
    public static let kMedusaDataFilePath                   = Medusa.kMedusaDataDirectoryPath + "/Data.medusa"
    public static let kMedusaIndexFilePath                  = Medusa.kMedusaDataDirectoryPath + "/Index.medusa"
    public static let kMedusaReplicateFilePath              = Medusa.kMedusaDataDirectoryPath + "/Replicate.medusa"
    
    public static func boot()
        {
        let _ = LoggingAgent()
        self.checkPageSize()
        var dataFileNeedsInitialization = false
        let dataFileHandle = self.openOrCreateDataFile(needsInitialization: &dataFileNeedsInitialization)
        Self.initMemorySegment(using: dataFileHandle)
        Self.initAgents(with: dataFileHandle,dataFileNeedsInitialization:  dataFileNeedsInitialization)
        self.finalizeBoot()
        }
        
    public static func checkPageSize()
        {
        let pageSize = Unsigned16(getpagesize())
        if pageSize != Page.kPageSizeInBytes
            {
            LoggingAgent.shared.log("System page size is \(pageSize), Medusa expects a page size of \(Page.kPageSizeInBytes).")
            LoggingAgent.shared.log("Medusa was designed for a page size of \(Page.kPageSizeInBytes) it can not run with a different page size.")
            LoggingAgent.shared.log("Medusa will now terminate.")
            fatalError("Medusa terminating due to page size conflict.")
            }
        }
        
    private static func initMemorySegment(using fileHandle: FileIdentifier)
        {
        LoggingAgent.shared.log("Initializing data file mapped segment.")

        var hexString = String(self.kMappedSegmentSizeInBytes,radix: 16,uppercase: true)
        LoggingAgent.shared.log("Mapped data file segment length is 0x\(hexString) ( \(self.kMappedSegmentSizeInBytes) ) bytes.")

        hexString = String(self.kMappedSegmentAddress,radix: 16,uppercase: true)
        LoggingAgent.shared.log("Mapped data file segment will be mapped at  0x\(hexString) ( \(self.kMappedSegmentAddress) ).")
        do
            {
            try fileHandle.map(to: self.kMappedSegmentAddress, sizeInBytes: self.kMappedSegmentSizeInBytes, offset: 0)
            LoggingAgent.shared.log("Mapping of data file segment was successful.")
            }
        catch let issue as SystemIssue
            {
            let message = "Error mapping data file segment \(issue.code) \(issue.message), Medusa can not proceed, it will now terminate."
            LoggingAgent.shared.log(message)
            fatalError(message)
            }
        catch let error
            {
            let message = "Unknown error ( \(error) ) occurred in Medusa.initMemorySegment(using:), Medusa is terminating."
            LoggingAgent.shared.log(message)
            fatalError(message)
            }
        }
            
    private static func openOrCreateDataFile(needsInitialization: inout Bool) -> FileIdentifier
        {
        if !Self.kMedusaDataDirectoryPath.isDirectory
            {
            LoggingAgent.shared.log("\(Self.kMedusaDataDirectoryPath.string) does not exist, files will be created.")
            do
                {
                try FileManager.default.createDirectory(at: Self.kMedusaDataDirectoryPath.url, withIntermediateDirectories: true)
                needsInitialization = true
                LoggingAgent.shared.log("Successfully created Data directory \(Self.kMedusaDataDirectoryPath.string).")
                }
            catch let error
                {
                LoggingAgent.shared.log("Creation of directory \(Self.kMedusaDataDirectoryPath.string) failed with \(error).")
                fatalError("Creation of Data directory failed, Medusa will now terminate.")
                }
            }
        else
            {
            LoggingAgent.shared.log("Found directory \(Self.kMedusaDataDirectoryPath.string).")
            }
        let handle = FileIdentifier(path: kMedusaDataFilePath,logger: LoggingAgent.shared)
        if handle.fileExists
            {
            LoggingAgent.shared.log("Found data file \(Self.kMedusaDataFilePath.string).")
            do
                {
                try handle.open(mode: .write)
                LoggingAgent.shared.log("Successfully opened data file \(Self.kMedusaDataFilePath.string).")
                return(handle)
                }
            catch let error
                {
                LoggingAgent.shared.log("Data file failed on opening with \(error).")
                fatalError("Opening of database files failed, Medusa will now terminate.")
                }
            }
        else
            {
            needsInitialization = true
            do
                {
                try handle.open(mode: .write,.create,.truncate)
                LoggingAgent.shared.log("Successfully created data file \(Self.kMedusaDataFilePath.string).")
                return(handle)
                }
            catch let error
                {
                LoggingAgent.shared.log("Creation of data file failed with \(error).")
                fatalError("Creation of database failed, Medusa will now terminate.")
                }
            }
        fatalError()
        }
        
    private static func initDataFile(using handle: FileIdentifier)
        {
        LoggingAgent.shared.log("Initializing Medusa data file...")
        }

    public static func initAgents(with fileHandle: FileIdentifier,dataFileNeedsInitialization: Boolean)
        {
        LoggingAgent.shared.log("Initializing agents.")
        PageServer.initialize(with: fileHandle,logger: LoggingAgent.shared,dataFileNeedsInitialization: dataFileNeedsInitialization)
//        let pageServer = PageServer(dataFileHandle: fileHandle)
        }
        
    public static func finalizeBoot()
        {
        LoggingAgent.shared.log("Finalizing Medusa boot sequence.")
        LoggingAgent.shared.log("Medusa successfully completed boot sequence, Medusa now available.")
        }
    }
