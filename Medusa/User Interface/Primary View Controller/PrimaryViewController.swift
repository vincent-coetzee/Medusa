//
//  ViewController.swift
//  Medusa
//
//  Created by Vincent Coetzee on 15/11/2023.
//

import Cocoa
import MedusaCore
import MedusaNetworking

class PrimaryViewController: NSViewController,NSMenuItemValidation,NSMenuDelegate
    {
    private var netService: NetService!
    
    override func viewDidLoad()
        {
        super.viewDidLoad()
//        NSApplication.shared.mainMenu!.item(withTitle: "Tools")!.submenu!.item(withTitle: "Browse Repository...")!.target = self
//        NSApplication.shared.mainMenu!.item(withTitle: "Tools")!.submenu!.item(withTitle: "Browse Repository...")!.action = #selector(PrimaryViewController.onBrowseRepositoryClicked)
//        NSApplication.shared.mainMenu!.item(withTitle: "Tools")!.submenu!.item(withTitle: "Browse Repository...")!.isEnabled = true
        self.initializeBonjour()
//        self.browseBuffer(self)
//        self.browseBTreePage(self)
        }

    private func initializeBonjour()
        {
        self.netService = NetService(domain: "",type: Medusa.kMedusaServiceType,name: Medusa.kHostName,port: Medusa.kPrimaryServicePort)
        self.netService.publish()
        }
        
    override var representedObject: Any?
        {
        didSet
            {
            // Update the view, if already loaded.
            }
        }
        
    @objc public func validateMenuItem(_ menuItem: NSMenuItem) -> Bool
        {
        true
        }
        
//    @IBAction func browseBuffer(_ sender: Any?)
//        {
//        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
//        let windowController = storyboard.instantiateController(withIdentifier: "bufferBrowserWindowController") as! NSWindowController
//        let _ = windowController.contentViewController as! BufferBrowserViewController
//        windowController.showWindow(self)
//        }
//        
//    @IBAction func browseBTreePage(_ sender: Any?)
//        {
//        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
//        let windowController = storyboard.instantiateController(withIdentifier: "btreePageInspectorWindowController") as! NSWindowController
//        let _ = windowController.contentViewController as! BTreePageInspectorViewController
//        windowController.showWindow(self)
//        }
//        
//    @IBAction func onBrowseRepositoryClicked(_ sender: Any?)
//        {
//        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
//        let windowController = storyboard.instantiateController(withIdentifier: "repositoryBrowserWindowController") as! NSWindowController
//        let _ = windowController.contentViewController as! RepositoryBrowserViewController
//        windowController.showWindow(self)
//        }
    }

