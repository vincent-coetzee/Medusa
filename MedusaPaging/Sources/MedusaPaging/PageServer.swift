//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation

public actor PageServer
    {
    public private(set) static var shared:PageServer!
    
    private let dataFileHandle: FileHandle
    
    public init(dataFileHandle: FileHandle)
        {
        self.dataFileHandle = dataFileHandle
        }
    }
