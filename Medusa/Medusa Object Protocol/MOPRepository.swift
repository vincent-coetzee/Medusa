//
//  MOPRepository.swift
//  Medusa
//
//  Created by Vincent Coetzee on 17/11/2023.
//

import Foundation

@dynamicMemberLookup
public class MOPRepository
    {
    private var klasses = Dictionary<String,MOPClass>()
    
    public init()
        {
        self.initClasses()
        }
        
    private func initClasses()
        {
        var klass: MOPClass = self.initMessageClass()
        self.klasses[klass.name] = klass
        klass = self.initConnectMessageClass()
        self.klasses[klass.name] = klass
        klass = self.initConnectConfirmMessageClass()
        self.klasses[klass.name] = klass
        klass = self.initPingMessageClass()
        self.klasses[klass.name] = klass
        klass = self.initPongMessageClass()
        self.klasses[klass.name] = klass
        klass = self.initRequestMessageClass()
        self.klasses[klass.name] = klass
        klass = self.initResponseMessageClass()
        self.klasses[klass.name] = klass
        }
        
    private func initMessageClass() -> MOPClass
        {
        let someKlass = MOPClass(module: MOPClass.argonModule,name: "Message")
        someKlass.addInstanceVariable(name: "messageType", klass: .messageType)
        someKlass.addInstanceVariable(name: "sequenceNumber", klass: .integer)
        someKlass.addInstanceVariable(name: "sourceIP", klass: .ipv6Address)
        someKlass.addInstanceVariable(name: "targetIP", klass: .ipv6Address)
        someKlass.addInstanceVariable(name: "totalMessageSize", klass: .integer)
        someKlass.addInstanceVariable(name: "payloadSize", klass: .integer)
        someKlass.addInstanceVariable(name: "payloadOffset", klass: .integer)
        return(someKlass)
        }
        
    private func initConnectMessageClass() -> MOPClass
        {
        MOPClass(module: MOPClass.argonModule,name: "ConnectMessage")
        }
        
    private func initConnectConfirmMessageClass() -> MOPClass
        {
        MOPClass(module: MOPClass.argonModule,name: "ConnectConfirmMessage")
        }
        
    private func initPingMessageClass() -> MOPClass
        {
        MOPClass(module: MOPClass.argonModule,name: "PingMessage")
        }
        
    private func initPongMessageClass() -> MOPClass
        {
        MOPClass(module: MOPClass.argonModule,name: "PongMessage")
        }
        
    private func initRequestMessageClass() -> MOPClass
        {
        MOPClass(module: MOPClass.argonModule,name: "RequestMessage")
        }
        
    private func initResponseMessageClass() -> MOPClass
        {
        MOPClass(module: MOPClass.argonModule,name: "ResponseMessage")
        }
        
    public subscript(dynamicMember key: String) -> MOPClass
        {
        fatalError()
        }
    }
