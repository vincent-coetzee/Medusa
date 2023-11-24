//
//  IPV6Address.swift
//  Medusa
//
//  Created by Vincent Coetzee on 16/11/2023.
//

import Foundation

public struct IPv6Address
    {
    public static let kLoopbackAddress = IPv6Address(bytes: [127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127])
    
    public static let IPv6AddressLength = 16
    
    public let bytes: Array<CChar>
    
    public init(bytes: Array<CChar>)
        {
        self.bytes = bytes
        }
    }
