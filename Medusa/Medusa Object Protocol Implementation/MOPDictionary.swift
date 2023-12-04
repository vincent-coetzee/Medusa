//
//  MOPDictionary.swift
//  Medusa
//
//  Created by Vincent Coetzee on 04/12/2023.
//

import Foundation

//
// This class defines basic routines used by dictionaries that
// are page based. It's behaviour is inherited by IdentityDictionary
// and in turn by SystemDictionary. Dictionaries in Medusa are
// backed by Medusa's BTree implementation. Dictionaries use
// the isEqual(to:) method to check the equality of their keys.
//
public class MOPDictionary
    {
    private var objectID: ObjectID
    private var page: MOPBTreePage
    private var byteOffset: Integer64
    
    public init(page: MOPBTreePage,atByteOffset: Integer64)
        {
        self.page = page
        self.byteOffset = atByteOffset
        }
        
    public subscript(_ key: any MOPKey) -> Instance
        {
        get
            {
            fatalError("Unimplemented")
            }
        set
            {
            fatalError("Unimplemented")
            }
        }
    }
