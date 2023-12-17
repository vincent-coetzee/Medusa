//
//  File.swift
//  
//
//  Created by Vincent Coetzee on 17/12/2023.
//

import Foundation

extension Thread
    {
    public class ObjectWranglerHolder: NSObject
        {
        let objectWrangler: ObjectWrangler!
        
        public init(objectWrangler: ObjectWrangler)
            {
            self.objectWrangler = objectWrangler
            }
        }
        
    public var objectWrangler: ObjectWrangler
        {
        get
            {
            if let holder = self.threadDictionary["ObjectWrangler"] as? ObjectWranglerHolder
                {
                return(holder.objectWrangler!)
                }
            fatalError("Thread object wrangler was not initialized.")
            }
        set
            {
            let holder = ObjectWranglerHolder(objectWrangler: newValue)
            self.threadDictionary["ObjectWrangler"] = holder
            }
        }
    }
