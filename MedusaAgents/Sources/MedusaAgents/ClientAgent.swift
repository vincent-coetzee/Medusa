//
//  File 2.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import MedusaCore

open class ClientAgent: AgentControl
    {
    public let ipAddress: IPAddress
    
    public func metrics() -> AgentMetrics
        {
        AgentMetrics(name: "Client Agent \(self.ipAddress.description)", agentKind: .clientAgent, metrics: [])
        }
        
    public init(ipAddress: IPAddress)
        {
        self.ipAddress = ipAddress
        }
        
    public func resetMetrics() 
        {
        fatalError("Still unimplemented.")
        }
        
    public func boot() throws
        {
        fatalError("Still unimplemented.")
        }
        
    public func start() throws
        {
        fatalError("Still unimplemented.")
        }
        
    public func stop() throws
        {
        fatalError("Still unimplemented.")
        }
    }
