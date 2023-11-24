//
//  BufferBrowserViewController.swift
//  Medusa
//
//  Created by Vincent Coetzee on 16/11/2023.
//

import Cocoa

class BufferBrowserViewController: NSViewController
    {
    @IBOutlet private weak var bufferBrowserView: BufferBrowserView!
    @IBOutlet private weak var byteCountLabel: NSTextField!
    @IBOutlet private weak var currentIndexLabel: NSTextField!
    @IBOutlet private weak var scrollView: NSScrollView!
    @IBOutlet private weak var valueTypeControl: NSSegmentedControl!
    
    public var buffer: Buffer?
        {
        didSet
            {
            self.bufferBrowserView.buffer = self.buffer
            self.byteCountLabel.stringValue = String(format: "%d bytes",self.buffer!.sizeInBytes)
            }
        }
        
    override func viewDidLoad()
        {
        super.viewDidLoad()
        self.valueTypeControl.selectedSegment = 2
        }
        
        
    @IBAction func onValueTypeChanged(_ sender: Any?)
        {
        guard let control = sender as? NSSegmentedControl else
            {
            return
            }
        let value = control.selectedSegment
        if value == 0
            {
            self.bufferBrowserView.valueType = .binary
            }
        else if value == 1
            {
            self.bufferBrowserView.valueType = .decimal
            }
        else if value == 2
            {
            self.bufferBrowserView.valueType = .hexadecimal
            }
        }
    }
