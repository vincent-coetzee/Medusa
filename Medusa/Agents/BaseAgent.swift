//
//  BaseAgent.swift
//  Xenon
//
//  Created by Vincent Coetzee on 15/11/2023.
//

import Foundation
import os

public class BaseAgent: Agent
    {
    public var name: String = ""
    public var logCategory: String = ""
    public var subSystem: String = "com.macsemantics.xenon"
    public var agentState: AgentState = .none
    internal var eventLog = Logger(subsystem: "",category: "")
    internal var isLogging = false
    
    public class func boot() -> Self
        {
        fatalError()
        }
        
    public func boot()
        {
        self.name = "Agent"
        self.agentState = .booting
        self.eventLog = Logger(subsystem: self.subSystem, category: self.logCategory)
        self.startLogging()
        self.log("Agent \(self.name) booting...")
        self.startDatabaseLogging()
        }
    
    public func shutdown()
        {
        self.agentState = .shutdown
        }
    
    public func startLogging()
        {
        self.isLogging = true
        self.log("Logging started.")
        }
    
    public func stopLogging()
        {
        self.isLogging = false
        }
        
    public func startDatabaseLogging()
        {
        self.log("Database logging started.")
        }
    
    public func stopDatabaseLogging()
        {
        self.log("Database logging stopped.")
        }
    
    public func abort()
        {
        self.log("Abort agent: \(self.name)")
        }
    
    public func commit()
        {
        self.log("Commit agent: \(self.name)")
        }
        
    public func log(_ string: String,_ strings: String...)
        {
        let someStrings = strings.joined(separator: ",")
        self.eventLog.log("\(string) + \(someStrings)")
        }
    }
