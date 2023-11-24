//
//  LoggingAgent.swift
//  Xenon
//
//  Created by Vincent Coetzee on 15/11/2023.
//

import Foundation

public class LoggingAgent: BaseAgent
    {
    public override class func boot() -> Self
        {
        let agent = LoggingAgent()
        agent.boot()
        return(agent as! Self)
        }
        
    public override func boot()
        {
        self.name = "EventLogger"
        super.boot()
        }
    }
