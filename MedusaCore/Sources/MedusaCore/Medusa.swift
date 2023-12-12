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
    
    public static var timeInMicroseconds: Integer64
        {
        var time:timeval = timeval()
        time.tv_sec = 0
        time.tv_usec = 0
        gettimeofday(&time,nil)
        let micros = time.tv_sec * 1_000_000 + Int(time.tv_usec)
        return(micros)
        }
    }
