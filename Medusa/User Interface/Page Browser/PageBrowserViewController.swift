//
//  PageBrowserViewController.swift
//  Medusa
//
//  Created by Vincent Coetzee on 17/12/2023.
//

import Cocoa
import MedusaCore
import MedusaPaging

class PageBrowserViewController: NSViewController
    {
    @IBOutlet weak var pageIndexField: NSTextField!
    @IBOutlet weak var leftArrowButton: NSButton!
    @IBOutlet weak var rightArrowButton: NSButton!
    @IBOutlet weak var chainPopUpButton: NSPopUpButton!
    @IBOutlet weak var bufferView: BufferBrowserView!
    
    private var currentPage: Page!
    
    override func viewDidLoad()
        {
        super.viewDidLoad()
        self.chainPopUpButton.target = self
        self.chainPopUpButton.action = #selector(Self.onChainSelected)
        }
    
    @IBAction func onLeftArrowClicked(_ sender: Any?)
        {
        }
        
    @IBAction func onRightArrowClicked(_ sender: Any?)
        {
        }
        
    @IBAction func onChainSelected(_ sender: Any?)
        {
        let selectedChain = self.chainPopUpButton.titleOfSelectedItem
        switch(selectedChain)
            {
            case "Free Pages":
                self.currentPage = PageServer.shared.firstFreePageStub()
            case "Block Pages":
                self.currentPage = PageServer.shared.firstBlockPageStub()
            case "Object Pages":
                self.currentPage = PageServer.shared.firstObjectPageStub()
            case "BTree Pages":
                self.currentPage = PageServer.shared.firstBTreeRootPageStub()
            case "Overflow Pages":
                self.currentPage = PageServer.shared.firstOverflowPageStub()
            case "Root":
                self.currentPage = PageServer.shared.rootPage
            default:
                fatalError()
            }
        do
            {
            try PageServer.shared.loadContents(of: self.currentPage)
            self.bufferView.annotatedBytes = self.currentPage.annotatedBytes
            }
        catch let issue as SystemIssue
            {
            }
        catch let error
            {
            }
        }
    }
