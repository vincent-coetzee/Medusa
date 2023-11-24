//
//  main.swift
//  MedusaTester
//
//  Created by Vincent Coetzee on 16/11/2023.
//

import Foundation

class MedusaDiscoveryDelegate: NSObject,NetServiceBrowserDelegate
    {
    func netServiceBrowser(_ aNetServiceBrowser: NetServiceBrowser, didFind aNetService: NetService, moreComing: Bool)
        {
        discoveredServices.append(aNetService)
        if !moreComing
            {
            runTests()
            }
        }
    }
    
let serviceDelegate = MedusaDiscoveryDelegate()
var serviceBrowser: NetServiceBrowser!
var discoveredServices = Array<NetService>()

fileprivate func discoverMedusaServices()
    {
    formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm:ss.SSSS"
    log("SEARCHING FOR NetService")
    serviceBrowser = NetServiceBrowser()
    serviceBrowser.delegate = serviceDelegate
    serviceBrowser.searchForServices(ofType: "_medusa._tcp.", inDomain: "")
    }

func runTests()
    {
    let hostName = discoveredServices.first!.hostName!
    let name = discoveredServices.first!.name
    log("FOUND A SERVICE \(name) ON \(hostName)")
    log("ATTEMPTING TO CONNECT TO SERVICE \(name)")
    
    }
    
fileprivate var formatter:DateFormatter!

func log(_ base: String)
    {
    let dateTimeString = formatter.string(for: Date())!
    print("MedusaTester \(dateTimeString) \(base)")
    }

discoverMedusaServices()
dispatchMain()

