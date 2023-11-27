//
//  BufferBrowserViewController.swift
//  Medusa
//
//  Created by Vincent Coetzee on 16/11/2023.
//

import Cocoa

class BufferBrowserViewController: NSViewController
    {
    @IBOutlet private weak var bufferBrowserViewLeft: BufferBrowserView!
    @IBOutlet private weak var bufferBrowserViewRight: BufferBrowserView!
    @IBOutlet private weak var byteCountLabel: NSTextField!
    @IBOutlet private weak var valueTypeControl: NSSegmentedControl!
    
    public var leftBuffer: Buffer?
        {
        didSet
            {
            self.bufferBrowserViewLeft.buffer = self.leftBuffer
            self.byteCountLabel.stringValue = String(format: "%d bytes",self.leftBuffer!.sizeInBytes)
            }
        }
        
    public var rightBuffer: Buffer?
        {
        didSet
            {
            self.bufferBrowserViewRight.buffer = self.rightBuffer
            }
        }
        
    override func viewDidLoad()
        {
        super.viewDidLoad()
        self.valueTypeControl.selectedSegment = 2
        let left = BufferBrowserView(frame: .zero)
        
        }
        
    override func viewWillLayout()
        {
        super.viewWillLayout()
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
            self.bufferBrowserViewLeft.valueType = .binary
            self.bufferBrowserViewRight.valueType = .binary
            }
        else if value == 1
            {
            self.bufferBrowserViewLeft.valueType = .decimal
            self.bufferBrowserViewRight.valueType = .decimal
            }
        else if value == 2
            {
            self.bufferBrowserViewLeft.valueType = .hexadecimal
            self.bufferBrowserViewRight.valueType = .hexadecimal
            }
        }
    }
