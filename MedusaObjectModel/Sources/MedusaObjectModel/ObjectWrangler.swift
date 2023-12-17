//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 09/12/2023.
//

import Foundation
import MedusaCore
import MedusaPaging

//
//
// ObjectWranglers are not thread safe so there should be one ObjectWrangler per thread.
// ClientAgents have a single thread and they have a single ObjectWrangler that is dediciated
// to their use. ObjectWranglers are also used in the Monitor and the GarbageCollector.
// ObjectWranglers are responsible for transcoding objects from one form ( buffer based or page based) to
// another ( page based or buffer based ). They also allocate objects to pages and handle the
// complexities of overflow, relocation of objects from one pgae to another and object blocks.
//
//
public class ObjectWrangler
    {
    private let pageServer: PageServer
    private let accessLock = NSRecursiveLock()
    private let logger: Logger
    @LockedAccess(value: Dictionary<ObjectAddress,any Instance>()) var objectCache
    
    public init(pageServer: PageServer,logger: Logger)
        {
        self.pageServer = pageServer
        self.logger = logger
        Thread.current.objectWrangler = self
        }
        
    public static func localObjectWrangler() -> ObjectWrangler
        {
        // This method must fetch the thread local object wrangler.
        // The local object wrangler is owned by the ClientBroker and
        // there is only a single wrangler per broker and per thread.
        // Most wrangler methods are reentrant bar the ones that fiddle
        // with caches.
        fatalError()
        }
        
    public func lookupObject(at: ObjectAddress) -> (any Instance)?
        {
        if let object = self.objectCache[at]
            {
            return(object)
            }
        let pointer = self.pageServer.objectPointer(forAddress: at)
        var object = Object(objectAddress: at,pointer: pointer)
        let classAddress = object.classAddress
        let someClass = self.objectCache[classAddress] as! Class
        object.class = someClass
        self.objectCache[at] = object
        return(object)
        }
        
    public func instanciateObject(ofClass: Class) throws -> Object
        {
        let sizeInBytes = ofClass.instanceSizeInBytes
        var page = self.pageServer.findObjectPage(withFreeSpaceInBytes: sizeInBytes)
        if page.isNil
            {
            page = self.pageServer.allocateObjectPage()
            }
        if ofClass.hasBytes
            {
            
            }
        fatalError()
        }
        
    public func loadInstance(address: ObjectAddress) -> any Instance
        {
        fatalError()
        }
        
    public func append(_ instance: any Instance,to blockPage: BlockPage)
        {
        
        }
        
    public func store(_ object: Object) -> ObjectAddress
        {
        let (page,index) = self.findObjectPage(withSpaceInBytes: object.sizeInBytes)
        do
            {
            try object.write(into: page,atIndex: index)
            let address = ObjectAddress(pageOffset: page.pageOffset,objectIndex: index)
            object.objectAddress = address
            return(address)
            }
        catch let issue as SystemIssue
            {
            self.logger.log(issue)
            fatalError(issue.description)
            }
        catch let error
            {
            self.logger.log("\(error)")
            fatalError("\(error)")
            }
        }
        
    public func store(_ class: Class) -> ObjectAddress
        {
        let (page,index) = self.findObjectPage(withSpaceInBytes: `class`.sizeInBytes)
        do
            {
            try `class`.writeClass(into: page,atIndex: index)
            let address = ObjectAddress(pageOffset: page.pageOffset,objectIndex: index)
            `class`.objectAddress = address
            return(address)
            }
        catch let issue as SystemIssue
            {
            self.logger.log(issue)
            fatalError(issue.description)
            }
        catch let error
            {
            self.logger.log("\(error)")
            fatalError("\(error)")
            }
        }
        
    public func findObjectPage(withSpaceInBytes: Integer64) -> (ObjectPage,Integer64)
        {
        if let page = self.pageServer.findObjectPage(withFreeSpaceInBytes: withSpaceInBytes)
            {
            do
                {
                let index = try page.allocateObjectBytes(sizeInBytes: withSpaceInBytes)
                return((page,index))
                }
            catch let issue as SystemIssue
                {
                self.logger.log(issue)
                fatalError(issue.description)
                }
            catch let error
                {
                self.logger.log("\(error)")
                fatalError("\(error)")
                }
            }
        else
            {
            let page = self.pageServer.allocateObjectPage()
            do
                {
                let index = try page.allocateObjectBytes(sizeInBytes: withSpaceInBytes)
                return((page,index))
                }
            catch let issue as SystemIssue
                {
                self.logger.log(issue)
                fatalError(issue.description)
                }
            catch let error
                {
                self.logger.log("\(error)")
                fatalError("\(error)")
                }
            }
        }
    }



