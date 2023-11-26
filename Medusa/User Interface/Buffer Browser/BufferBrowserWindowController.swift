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
//        let buffer = MessageBuffer()
//        let message = ConnectMessage()
//        message.payloadOffset = 1000
//        message.payloadSize = 1024
//        message.sequenceNumber = 201
//        message.sourceIP = IPv6Address.kLoopbackAddress
//        message.targetIP = IPv6Address.kLoopbackAddress
//        message.totalMessageSize = 4096
//        var token = PermissionsToken()
//        token.addPermission(.connect(.kDefaultScope))
//        token.addPermission(.read(.kDefaultScope))
//        token.addPermission(.write(.kDefaultScope))
//        message.permissionsToken = token
//        message.encode(on: buffer)
        let page = BTreePage<String,String>(magicNumber: Medusa.kBTreePageMagicNumber)
        page.write()
        browserController.buffer = PageWrapper(page: page)
        }
    }
