//
//  BufferBrowserWindowController.swift
//  Medusa
//
//  Created by Vincent Coetzee on 16/11/2023.
//

import Cocoa

class BufferBrowserWindowController: NSWindowController {

    override func windowDidLoad()
        {
        super.windowDidLoad()
        let browserController = self.contentViewController as! BufferBrowserViewController
        let page = BTreePage<String,String>(magicNumber: Medusa.kBTreePageMagicNumber)
        page.write()
        browserController.leftBuffer = PageWrapper(page: page)
        browserController.rightBuffer = PageWrapper(page: page)
        }
    }
