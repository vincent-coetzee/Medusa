//
//  MOPChannel.swift
//  Medusa
//
//  Created by Vincent Coetzee on 17/11/2023.
//

import Foundation

public class MOPChannel
    {
    internal var offset: Medusa.Integer64
    internal var sizeInBytes: Int
    private var offsetStack: Stack<Medusa.Integer64>
    internal var buffers: Medusa.Buffers
    
    public init(offset:Medusa.Integer64,buffers: Medusa.Buffers,sizeInBytes: Int)
        {
        self.offset = offset
        self.offsetStack = Stack<Medusa.Integer64>()
        self.sizeInBytes = sizeInBytes
        self.buffers = buffers
        self.initialize()
        }
        
    public init(offset:Medusa.Integer64,sizeInBytes: Int)
        {
        self.offset = offset
        self.offsetStack = Stack<Medusa.Integer64>()
        self.sizeInBytes = sizeInBytes
        self.buffers = Array(arrayLiteral: UnsafeMutableRawPointer.allocate(byteCount: sizeInBytes, alignment: 1))
        self.initialize()
        }
        
    public func pushOffset()
        {
        self.offsetStack.push(self.offset)
        }
        
    public func popOffset()
        {
        self.offset = self.offsetStack.pop()
        }
        
    deinit
        {
        for buffer in self.buffers
            {
            buffer.deallocate()
            }
        }
        
    private func initialize()
        {
        }
    }


