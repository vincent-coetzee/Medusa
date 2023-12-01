//
//  MOPMessage.swift
//  Medusa
//
//  Created by Vincent Coetzee on 01/12/2023.
//

import Foundation

public class MOPMessage
    {
    public static var _klass: MOPClass!
    
    private let klass: MOPClass
    
    public class var klass: MOPClass
        {
        if self._klass.isNil
            {
            self._klass = MOPClass(module: MOPClass.argonModule,name: "Message")
            self._klass.addPrimitiveInstanceVariable(name: "sizeInBytes", klass: .integer64)
            }
        return(self._klass)
        }
    
    public init()
        {
        self.klass = Self.klass
        }
    }
    
public class MOPConnectMessage: MOPMessage
    {
    public override class var klass: MOPClass
        {
        if self._klass.isNil
            {
            self._klass = MOPClass(module: MOPClass.argonModule,name: "ConnectMessage")
            }
        return(self._klass)
        }
    }
    
public class MOPConnectAcceptMessage: MOPMessage
    {
    public override class var klass: MOPClass
        {
        if self._klass.isNil
            {
            self._klass = MOPClass(module: MOPClass.argonModule,name: "ConnectAcceptMessage")
            }
        return(self._klass)
        }
    }
    
public class MOPConnectRejectMessage: MOPMessage
    {
    public override class var klass: MOPClass
        {
        if self._klass.isNil
            {
            self._klass = MOPClass(module: MOPClass.argonModule,name: "ConnectRejectMessage")
            }
        return(self._klass)
        }
    }

public class MOPPingMessage: MOPMessage
    {
    public override class var klass: MOPClass
        {
        if self._klass.isNil
            {
            self._klass = MOPClass(module: MOPClass.argonModule,name: "ConnectPingMessage")
            }
        return(self._klass)
        }
    }
    
public class MOPPongConfirmMessage: MOPMessage
    {
    public override class var klass: MOPClass
        {
        if self._klass.isNil
            {
            self._klass = MOPClass(module: MOPClass.argonModule,name: "ConnectPongMessage")
            }
        return(self._klass)
        }
    }

public class MOPRequestMessage: MOPMessage
    {
    public override class var klass: MOPClass
        {
        if self._klass.isNil
            {
            self._klass = MOPClass(module: MOPClass.argonModule,name: "RequestMessage")
            }
        return(self._klass)
        }
    }
    
public class MOPResponseMessage: MOPMessage
    {
    public override class var klass: MOPClass
        {
        if self._klass.isNil
            {
            self._klass = MOPClass(module: MOPClass.argonModule,name: "ResponseMessage")
            }
        return(self._klass)
        }
    }
    
public class MOPInvocationMessage: MOPMessage
    {
    public override class var klass: MOPClass
        {
        if self._klass.isNil
            {
            self._klass = MOPClass(module: MOPClass.argonModule,name: "InvocationMessage")
            }
        return(self._klass)
        }
    }
    
public class MOPInvocationResultMessage: MOPMessage
    {
    public override class var klass: MOPClass
        {
        if self._klass.isNil
            {
            self._klass = MOPClass(module: MOPClass.argonModule,name: "InvocationResultMessage")
            }
        return(self._klass)
        }
    }
