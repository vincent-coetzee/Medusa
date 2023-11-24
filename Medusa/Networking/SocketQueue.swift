//
//  SocketQueue.swift
//  Medusa
//
//  Created by Vincent Coetzee on 16/11/2023.
//

import Foundation
import Socket

public class SocketQueue
    {
    private let inputLock = NSLock()
    private var outgoingMessages = Array<Message>()
    private var incomingMessages = Array<Message>()
    private var readSocket: Socket
    private var writeSocket: Socket
    
    public init(socket: Socket) throws
        {
        self.readSocket = try Socket.create(fromNativeHandle: socket.socketfd, address: socket.signature?.address)
        readSocket.readBufferSize = Medusa.kSocketReadBufferSize
        self.writeSocket = try Socket.create(fromNativeHandle: socket.socketfd, address: socket.signature?.address)
        }
        
    public func enqueue(_ message: Message)
        {
        self.inputLock.lock()
        self.outgoingMessages.append(message)
        self.inputLock.lock()
        }
        
    public func start()
        {
        DispatchQueue.global(qos: .userInitiated).async
            {
            self.readFromSocket()
            }
        DispatchQueue.global(qos: .userInitiated).async
            {
            self.writeToSocket()
            }
        }
        
    private func readFromSocket()
        {
        
        }
        
    private func writeToSocket()
        {
        }
    }
