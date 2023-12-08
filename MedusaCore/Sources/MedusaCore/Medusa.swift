//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 07/12/2023.
//

import Foundation

public struct Medusa
    {
    public static let kMedusaServiceType = "_medusa._tcp."
    public static let kHostName = Host.current().localizedName!
    public static let kPrimaryServicePort: Int32 = 52000
    public static let kDefaultBufferSize: Int = 4096
    public static let kSocketReadBufferSize = 16 * 1024
    }
