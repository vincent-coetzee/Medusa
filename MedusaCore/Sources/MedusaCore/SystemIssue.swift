//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation

public struct SystemIssue: Error
    {
    public var description: String
        {
        "In \(self.agentKind) error \(self.code) \(self.message)"
        }
        
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
    
