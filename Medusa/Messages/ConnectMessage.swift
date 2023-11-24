//
//  ConnectMessage.swift
//  Medusa
//
//  Created by Vincent Coetzee on 16/11/2023.
//

import Foundation

public class ConnectMessage: RequestMessage
    {
    public var permissionsToken: PermissionsToken
    
    public required init()
        {
        self.permissionsToken = PermissionsToken()
        super.init()
        }
        
    public init(from buffer: MessageBuffer)
        {
        self.permissionsToken = PermissionsToken()
        super.init()
        }
        
    public required init(type: MessageType)
        {
        self.permissionsToken = PermissionsToken()
        super.init()
        }
        
    public override func encode(on buffer: MessageBuffer)
        {
        super.encode(on: buffer)
        buffer.encode(self.permissionsToken)
        print("After encode buffer checksum is \(buffer.checksum)")
        }
    }
