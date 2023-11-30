//
//  KeyEntry.swift
//  Medusa
//
//  Created by Vincent Coetzee on 24/11/2023.
//

import Foundation

public struct KeyValue<Key,Value> where Key:Fragment,Value:Fragment
    {
    public let key: Key
    public let value: Value
    }
