////
////  BufferBrowserWindowController.swift
////  Medusa
////
////  Created by Vincent Coetzee on 16/11/2023.
////
//
//import Cocoa
//
//class BufferBrowserWindowController: NSWindowController {
//
//    override func windowDidLoad()
//        {
//        super.windowDidLoad()
//        let browserController = self.contentViewController as! BufferBrowserViewController
//        let page = BTreePage<String,String>(fileHandle: .empty,magicNumber: Medusa.kBTreePageMagicNumber,keysPerPage: 50)
//        do
//            {
//            try page.write()
//            }
//        catch let error as SystemIssue
//            {
//            print(error)
//            }
//        catch
//            {
//            }
//        browserController.buffer = PageWrapper(page: page)
//        }
//    }
