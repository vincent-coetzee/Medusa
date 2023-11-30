//
//  MOPEncoder.swift
//  Medusa
//
//  Created by Vincent Coetzee on 17/11/2023.
//

import Foundation

public class MOPWriter: MOPReader
    {
    private let packetSizeInBytes: Int
    
    public init(offset:Medusa.Integer64,sizeInBytes: Int,packetSizeInBytes: Int)
        {
        self.packetSizeInBytes = packetSizeInBytes
        super.init(offset: offset,sizeInBytes: sizeInBytes)
        }
        
    public func encode(_ integer: Medusa.Integer64)
        {
        
        }
    }
