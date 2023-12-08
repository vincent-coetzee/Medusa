//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation
import MedusaCore

public struct AgentMetrics
    {
    public let name: String
    public let agentKind: AgentKind
    public var metrics = Array<AgentMetric>()
    }

public enum AgentMetricValue
    {
    case timeInMilliseconds(Integer64)
    case pageCount(Integer64)
    case byteCount(Integer64)
    case date(Integer64)
    case count(Integer64)
    case index(Integer64)
    }
    
public struct AgentMetric
    {
    public let key: String
    public var timestampInMilliseconds: Integer64
    public let value: AgentMetricValue
    }

