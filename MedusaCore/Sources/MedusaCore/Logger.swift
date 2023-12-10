//
//  File 2.swift
//  
//
//  Created by Vincent Coetzee on 10/12/2023.
//

import Foundation

public protocol Logger
    {
    func logToConsole()
    func logToFile()
    func log(_ message: String)
    }
