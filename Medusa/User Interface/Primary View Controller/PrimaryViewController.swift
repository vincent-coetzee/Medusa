//
//  ViewController.swift
//  Medusa
//
//  Created by Vincent Coetzee on 15/11/2023.
//

import Cocoa

class PrimaryViewController: NSViewController
    {
    private var netService: NetService!
    
    override func viewDidLoad()
        {
        super.viewDidLoad()
        self.initializeBonjour()
        self.browseBuffer(self)
        self.browseBTreePage(self)
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
        
    @IBAction func browseBuffer(_ sender: Any?)
        {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: "bufferBrowserWindowController") as! NSWindowController
        let _ = windowController.contentViewController as! BufferBrowserViewController
        windowController.showWindow(self)
        }
        
    @IBAction func browseBTreePage(_ sender: Any?)
        {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: "btreePageInspectorWindowController") as! NSWindowController
        let _ = windowController.contentViewController as! BTreePageInspectorViewController
        windowController.showWindow(self)
        }
    }

