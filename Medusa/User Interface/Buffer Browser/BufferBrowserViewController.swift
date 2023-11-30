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
    @IBOutlet private weak var valueTypeControl: NSSegmentedControl!
    @IBOutlet private weak var allocateButton: NSButton!
    @IBOutlet private weak var allocationField: NSTextField!
    @IBOutlet private weak var scrollView: NSScrollView!
    
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
        let scroller = NSScrollView()
        self.view.addSubview(scroller)
        self.scrollView = scroller
        scroller.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.scrollView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor,constant: 60).isActive = true
        let clipView = NSClipView()
        clipView.translatesAutoresizingMaskIntoConstraints = false
        let browserView = BufferBrowserView()
        clipView.documentView = browserView
        browserView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.contentView = clipView
        self.bufferBrowserView = browserView
        self.scrollView.hasHorizontalScroller = false
        self.scrollView.hasVerticalScroller = true
        self.scrollView.autohidesScrollers = true
        self.scrollView.postsFrameChangedNotifications = true
        self.allocateButton.target = self
        self.allocateButton.action = #selector(Self.onAllocateClicked)
        NotificationCenter.default.addObserver(browserView, selector: #selector(BufferBrowserView.scrollViewFrameChanged), name: NSView.frameDidChangeNotification, object: self.scrollView)
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
        
    @IBAction public func onAllocateClicked(_ any: Any?)
        {
        let sizeInBytes = self.allocationField.integerValue
        do
            {
            if let offset = try self.buffer?.allocate(sizeInBytes: sizeInBytes)
                {
                self.buffer?.flush()
                self.bufferBrowserView.needsLayout = true
                print("ALLOCATION OFFSET = \(offset)")
                }
            }
        catch let error
            {
            print(error)
            }
        }
    }
