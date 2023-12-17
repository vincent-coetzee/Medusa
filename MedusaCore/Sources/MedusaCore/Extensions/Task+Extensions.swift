//
//  Task+Extensions.swift
//  Medusa
//
//  Created by Vincent Coetzee on 03/12/2023.
//

import Foundation

extension Task where Failure == Error
    {
    static func synchronous(priority: TaskPriority? = nil, operation: @escaping @Sendable () async throws -> Success)
        {
        let semaphore = DispatchSemaphore(value: 0)
        Task(priority: priority)
            {
            defer
                {
                semaphore.signal()
                }
            return try await operation()
            }
        semaphore.wait()
        }
    }
