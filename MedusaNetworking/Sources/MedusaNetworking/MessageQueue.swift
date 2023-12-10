//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 08/12/2023.
//

import Foundation

public class MessageQueue
    {
    private var messages: Messages
    private var sequenceNumber = 0
    private let accessLock: NSLock
    
    public init()
        {
        self.messages = Messages()
        self.accessLock = NSLock()
        }
        
    public func enqueue(_ message: Message)
        {
        self.accessLock.lock()
        self.messages.append(message)
        self.accessLock.unlock()
        }
        
    public func dequeue() -> Message?
        {
        self.accessLock.lock()
        defer
            {
            self.accessLock.unlock()
            }
        if self.messages.isEmpty
            {
            return(nil)
            }
        return(self.messages.removeFirst())
        }
    }
