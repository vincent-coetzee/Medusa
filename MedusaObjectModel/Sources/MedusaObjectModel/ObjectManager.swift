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
    
    init(pageServer: PageServer)
        {
        self.pageServer = pageServer
        }
        
    public func instanciateObject(ofClass: Class) -> Instance
        {
        }
    }
    
public class MOMEncoder
    {
    }
    
public class MOMPageBasedEncoder: MOMEncoder
    {
    }
    
public class MOMBufferBasedEncoder: MOMEncoder
    {
    }
