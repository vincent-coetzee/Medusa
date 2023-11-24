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
        let someKlass = MOPClass(name: "Message")
        someKlass.addInstanceVariable(name: "messageType", klass: .messageType, offset: 0,keyPath: \Message.messageType)
        someKlass.addInstanceVariable(name: "sequenceNumber", klass: .integer, offset: 0,keyPath: \Message.sequenceNumber)
        someKlass.addInstanceVariable(name: "sourceIP", klass: .ipv6Address, offset: 0,keyPath: \Message.sourceIP)
        someKlass.addInstanceVariable(name: "targetIP", klass: .ipv6Address, offset: 0,keyPath: \Message.targetIP)
        someKlass.addInstanceVariable(name: "totalMessageSize", klass: .integer, offset: 0,keyPath: \Message.totalMessageSize)
        someKlass.addInstanceVariable(name: "payloadSize", klass: .integer, offset: 0,keyPath: \Message.payloadSize)
        someKlass.addInstanceVariable(name: "payloadOffset", klass: .integer, offset: 0,keyPath: \Message.payloadOffset)
        return(someKlass)
        }
        
    private func initConnectMessageClass() -> MOPClass
        {
        MOPClass(name: "ConnectMessage")
        }
        
    private func initConnectConfirmMessageClass() -> MOPClass
        {
        MOPClass(name: "ConnectConfirmMessage")
        }
        
    private func initPingMessageClass() -> MOPClass
        {
        MOPClass(name: "PingMessage")
        }
        
    private func initPongMessageClass() -> MOPClass
        {
        MOPClass(name: "PongMessage")
        }
        
    private func initRequestMessageClass() -> MOPClass
        {
        MOPClass(name: "RequestMessage")
        }
        
    private func initResponseMessageClass() -> MOPClass
        {
        MOPClass(name: "ResponseMessage")
        }
        
    public subscript(dynamicMember key: String) -> MOPClass
        {
        fatalError()
        }
    }
