//
//  AppDelegate.swift
//  Medusa
//
//  Created by Vincent Coetzee on 15/11/2023.
//

import Cocoa
import MedusaCore
import MedusaAgents

@main
class AppDelegate: NSObject, NSApplicationDelegate
    {
    func applicationDidFinishLaunching(_ aNotification: Notification)
        {
        Medusa.boot()
//        LoggingAgent.shared.logToConsole()
//        Medusa.runTests()
//        let module = MOPArgonModule.shared
//        module.initHierarchy()
        }

    func applicationWillTerminate(_ aNotification: Notification)
        {
        // Insert code here to tear down your application
        }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool
        {
        return true
        }
    }

