//
//  NOPSystemDictionary.swift
//  Medusa
//
//  Created by Vincent Coetzee on 04/12/2023.
//

import Foundation

//
//
// There is one and only one instance of the SystemDictionary in the system, a reference
// to it is stored in the first page in the databse data file. All objects in the system
// can be reached either directly or indirectly from the SystemDictionary instance. The
// SystemDictionary instance is stored in the DatabasePage that is the first page in Medusa's
// data file. That page contains all the global variables defined by Medusa and if an object
// is added to the database without somehow being referenced by the SystemDictionary ( e.g.
// being stored in a dictionary that is in turn stored in the SystemDictionary ) then it
// can not be found and will be garbage collected the next time the GarbageCollector is
// run. SystemDictionary is keyed by Atoms because they are easy to read, represent a
// string but are canoncial which means they can be directly compared unlike strings.
//

public class MOPSystemDictionary: MOPIdentityDictionary
    {
    private var rootPage: MOPBTreePage!
    //
    // This initlaizer is called when the databse boots and
    // configures itself from the database data file. This can
    // only be used once the database has been initialized. If
    // it is necessary that the SystemDictionary be set up in order for it
    // to store itself in a freshly initialized databse then use
    // the init() initializer.
    //
    public init(rootPage: MOPBTreePage)
        {
        self.rootPage = rootPage
        self.readRoots()
        }
        
    //
    // Initialize a completely virgin SystemDictionary
    //
    public override init()
        {
        super.init()
        }
    //
    // Read in all the root objects which are stored in the
    // SystemDictionary instance under their names ( represented
    // as Atoms ). Tthis obviously can only be done once a database
    // has been initialzied. Prior to database initialization a
    // SystemDictionary should be manually populated.
    //
    private func readRoots()
        {
        }
    }
