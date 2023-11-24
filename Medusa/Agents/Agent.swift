//
//  Agent.swift
//  Xenon
//
//  Created by Vincent Coetzee on 15/11/2023.
//

import Foundation

public protocol Agent
    {
    var name: String { get set }
    var agentState: AgentState { get set }
    var logCategory: String { get }
    var subSystem: String { get }
    
    func boot()
    func shutdown()
    func startDatabaseLogging()
    func startLogging()
    func stopLogging()
    func stopDatabaseLogging()
    }
