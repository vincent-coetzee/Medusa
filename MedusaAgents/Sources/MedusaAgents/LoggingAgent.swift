//
//  File 2.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import MedusaCore

public class LoggingAgent: Logger
    {
    public private(set) static var shared: LoggingAgent!
    
    private let path: String
    private var fileHandle: UnsafeMutablePointer<FILE>!
    private let dateFormatter: DateFormatter
    private var isLoggingToConsole = true
    private var accessLock = NSLock()
    
    public init()
        {
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss.AAAAAAAAAAAA"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM_dddd_HH_mm_ss.AAAAAAAAAAAA"
        self.isLoggingToConsole = true
        self.path = Medusa.kMedusaLogDirectoryPath + "Medusa_" + formatter.string(from: Date()) + ".log"
        self.initLogging()
        Self.shared = self
        }
        
    private func initLogging()
        {
        let file = FileIdentifier(path: Medusa.kMedusaLogDirectoryPath)
        if !file.fileIsDirectory()
            {
            self.log("The logs directory \(Medusa.kMedusaLogDirectoryPath) does not exist, it will be created.")
            do
                {
                try FileManager.default.createDirectory(at: URL(fileURLWithPath: Medusa.kMedusaLogDirectoryPath), withIntermediateDirectories: true)
                }
            catch let error
                {
                self.log("The logs directory could not be created, \(error), Medusa will now terminate.")
                fatalError("Medusa can not proceed.")
                }
            }
        self.fileHandle = fopen(self.path,"w+t")
        if self.fileHandle.isNil
            {
            let message = String(cString: strerror(errno))
            self.log("Unable to create log file \(self.path) error (\(errno)) \(message) - Medusa can not proceed - it will now terminate.")
            fatalError("Medusa can not proceed.")
            }
        self.log("Successfully created \(self.path) for logging - switching output to log file.")
        }
        
    public func logToFile()
        {
        self.log("Logging switching from console to \(self.path).")
        self.accessLock.withLock
            {
            self.isLoggingToConsole = false
            }
        }
        
    public func logToConsole()
        {
        self.log("Logging switched from \(self.path) to console.")
        self.accessLock.withLock
            {
            self.isLoggingToConsole = true
            }
        }
        
    public func log(_ systemIssue: SystemIssue)
        {
        self.log("Issue \(systemIssue.code) occurred \(systemIssue.message).")
        }
        
    public func log(_ message: String)
        {
        let cleanMessage = message.replacingOccurrences(of: ":", with: " ").replacingOccurrences(of: "[", with: "-").replacingOccurrences(of: "]", with: "-")
        let string = "\(self.dateFormatter.string(from: Date())): \(cleanMessage)"
        self.accessLock.withLock
            {
            if self.isLoggingToConsole
                {
                print(string)
                }
            else
                {
                fputs(string + "\n",self.fileHandle)
                fflush(self.fileHandle)
                }
            }
        }
    }
