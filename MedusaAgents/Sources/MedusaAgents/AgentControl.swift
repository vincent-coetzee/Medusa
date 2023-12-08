//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import MedusaCore

public protocol AgentControl
    {
    func metrics() -> AgentMetrics
    func resetMetrics()
    func boot() throws
    func start() throws
    func stop() throws
    }
