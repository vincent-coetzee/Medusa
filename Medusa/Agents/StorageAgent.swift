//
//  StorageAgent.swift
//  Xenon
//
//  Created by Vincent Coetzee on 15/11/2023.
//

import Foundation
import os

public class StorageAgent
    {
    internal static func nextAvailableAgent() -> StorageAgent
        {
        fatalError("Not yet implemented")
        }
        
    private let eventLogger = Logger(subsystem: "com.macsemantics.xenon",category: "Boss")
    
    public func boot()
        {
        }
    }
