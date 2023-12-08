//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 08/12/2023.
//

import Foundation

open class IPAddress
    {
    public var description: String
        {
        ""
        }
        
    public init(_ string: String)
        {
        }
        
    public init()
        {
        }
    }

open class IPv4Address: IPAddress
    {
    public override init(_ string: String)
        {
        super.init()
        }
    }
    
open class IPv6Address: IPAddress
    {
    public override init(_ string: String)
        {
        super.init()
        }
    }
