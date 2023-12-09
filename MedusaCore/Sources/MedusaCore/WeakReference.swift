//
//  WeakReference.swift
//  Medusa
//
//  Created by Vincent Coetzee on 02/12/2023.
//

import Foundation

public class WeakReference<Kind> where Kind:AnyObject
    {
    public weak var object: Kind?
    
    public init(object: Kind)
        {
        self.object = object
        }
    }
