//
//  ExecutionAgent.swift
//  Xenon
//
//  Created by Vincent Coetzee on 15/11/2023.
//

import Foundation

public class ExecutionAgent: BaseAgent
    {
    public override class func boot() -> Self
        {
        let agent = ExecutionAgent()
        agent.boot()
        return(agent as! Self)
        }
        
    public override func boot()
        {
        self.name = "Overseer"
        super.boot()
        }
    }
