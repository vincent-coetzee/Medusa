//
//  AuthenticationToken.swift
//  Medusa
//
//  Created by Vincent Coetzee on 16/11/2023.
//

import Foundation

public struct PermissionsToken
    {
    public struct Scope
        {
        public let startDate: Date
        public let stopDate: Date
        
        public static let kDefaultScope = Scope(startDate: Date(), stopDate: Date.distantFuture)
        }
        
    public enum Permission
        {
        case login(Scope)
        case connect(Scope)
        case read(Scope)
        case write(Scope)
        case delete(Scope)
        case collectGarbage(Scope)
        case backup(Scope)
        case custom(Scope,Int,String)
        
        public var rawValue: Int
            {
            switch(self)
                {
                case .connect:
                    return(10)
                case .read:
                    return(20)
                case .write:
                    return(30)
                case .delete:
                    return(40)
                case .collectGarbage:
                    return(50)
                case .backup:
                    return(60)
                case .custom(_,let rawValue,_):
                    return(rawValue)
                case .login:
                    return(70)
                }
            }
            
        public var scope: Scope
            {
            switch(self)
                {
                case .connect(let scope):
                    return(scope)
                case .read(let scope):
                    return(scope)
                case .write(let scope):
                    return(scope)
                case .delete(let scope):
                    return(scope)
                case .collectGarbage(let scope):
                    return(scope)
                case .backup(let scope):
                    return(scope)
                case .custom(let scope,_,_):
                    return(scope)
                case .login(let scope):
                    return(scope)
                }
            }
            
        public func encode(on buffer: MessageBuffer)
            {
            switch(self)
                {
                case .custom(let scope,let rawValue,let name):
                    buffer.encode(rawValue)
                    buffer.encode(name)
                    buffer.encode(scope.startDate)
                    buffer.encode(scope.stopDate)
                default:
                    buffer.encode(self.rawValue)
                    buffer.encode(self.scope.startDate)
                    buffer.encode(self.scope.stopDate)
                }
            }
            
        public init(from buffer: MessageBuffer)
            {
            let rawValue = buffer.decodeInteger()
            if rawValue == 70
                {
                let name = buffer.decodeString()
                let startDate = Date(timeIntervalSinceReferenceDate: buffer.decodeFloat())
                let stopDate = Date(timeIntervalSinceReferenceDate: buffer.decodeFloat())
                self = Permission.custom(Scope(startDate: startDate,stopDate: stopDate),rawValue,name)
                }
            else
                {
                let startDate = Date(timeIntervalSinceReferenceDate: buffer.decodeFloat())
                let stopDate = Date(timeIntervalSinceReferenceDate: buffer.decodeFloat())
                switch(rawValue)
                    {
                    case 10:
                        self = .connect(Scope(startDate: startDate,stopDate: stopDate))
                    case 20:
                        self = .read(Scope(startDate: startDate,stopDate: stopDate))
                    case 30:
                        self = .read(Scope(startDate: startDate,stopDate: stopDate))
                    case 40:
                        self = .read(Scope(startDate: startDate,stopDate: stopDate))
                    case 50:
                        self = .read(Scope(startDate: startDate,stopDate: stopDate))
                    case 70:
                        self = .read(Scope(startDate: startDate,stopDate: stopDate))
                    default:
                        fatalError("This should not have occurred.")
                    }
                }
            }
        }
        
    private var permissions: Array<Permission>
    
    public var count: Int
        {
        self.permissions.count
        }
        
    public init()
        {
        self.permissions = Array<Permission>()
        }
        
    public init(permissions: Array<Permission>)
        {
        self.permissions = permissions
        }
        
    public init(from buffer: MessageBuffer)
        {
        let count = buffer.decodeInteger()
        self.permissions = Array<Permission>()
        for _ in 0..<count
            {
            self.permissions.append(Permission(from: buffer))
            }
        }
        
    public subscript(_ index: Int) -> Permission
        {
        guard index < self.permissions.count else
            {
            fatalError("Attempt to access permission beyond range of permissions.")
            }
        return(self.permissions[index])
        }
        
    public func encode(on buffer: MessageBuffer)
        {
        buffer.encode(self.permissions.count)
        for permission in self.permissions
            {
            permission.encode(on: buffer)
            }
        }
        
    public mutating func addPermission(_ permission: Permission)
        {
        self.permissions.append(permission)
        }
    }
