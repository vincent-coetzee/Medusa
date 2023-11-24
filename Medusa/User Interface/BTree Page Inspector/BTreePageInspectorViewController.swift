//
//  BtreePageInspectorViewController.swift
//  Medusa
//
//  Created by Vincent Coetzee on 22/11/2023.
//

import Cocoa

class BTreePageInspectorViewController: NSViewController
    {
    private var btreePage: BTreePage<String,String>?
    private var highlightColor = NSColor.argonLivingCoral
    private var regularColor = NSColor.argonWhite80
    private var lowlightColor = NSColor.argonTribalSeaGreen
    
    @IBOutlet weak var outlineView: NSOutlineView!
    
    override func viewDidLoad()
        {
        super.viewDidLoad()
        self.btreePage = BTreePage(magicNumber: Medusa.kBTreePageMagicNumber)
        do
            {
            try self.btreePage?.insertKeyEntry(key: "Vincent", value: "Some text that will be stuffed in.", pointer: Medusa.PageAddress(1_000_000_000))
            try self.btreePage?.insertKeyEntry(key: "Joan", value: "More text.", pointer: Medusa.PageAddress(2_000_000))
            try self.btreePage?.insertKeyEntry(key: "Jen", value: "Jennifer has no problem speaking in public and can say a lot of things in a short space of time.", pointer: Medusa.PageAddress(11_000_000))
            try self.btreePage?.insertKeyEntry(key: "Stevie", value: "Stevie is now all grown up and married.", pointer: Medusa.PageAddress(2_000_000))
            try self.btreePage?.insertKeyEntry(key: "Daniel", value: "Daniel is very boring I am told.", pointer: Medusa.PageAddress(2_000_000))
            }
        catch let issue as SystemIssue
            {
            print("Issue occurred: \(issue.message)")
            }
        catch
            {
            }
        self.btreePage?.rightPointer = Medusa.PageAddress(5_555_555_555)
        self.btreePage?.write()
        self.outlineView.backgroundColor = NSColor.argonBlack50
        self.outlineView.font = NSFont.systemFont(ofSize: 13)
        let pp = Medusa.PagePointer(page: 1000,offset: 400)
        print(bitString(of: pp))
        print(pp.pageValue)
        print(pp.offsetValue)
        self.outlineView.rowHeight = 20
        self.outlineView.reloadData()
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: "bufferBrowserWindowController") as! NSWindowController
        let viewController = windowController.contentViewController as! BufferBrowserViewController
        windowController.showWindow(self)
        viewController.buffer = btreePage!.pageBuffer
        }
    }


extension BTreePageInspectorViewController: NSOutlineViewDataSource
    {
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool
        {
        if item is FieldHolder
            {
            return(true)
            }
        else
            {
            return(false)
            }
        }
        
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int
        {
        if item.isNil
            {
            return(3)
            }
        else if let holder = item as? FieldHolder
            {
            return(holder.fields.count)
            }
        else if item is Field
            {
            return(0)
            }
        return(0)
        }
        
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any
        {
        if item.isNil
            {
            if index == 0
                {
                return(FieldHolder(label: "Header Fields",fields: self.btreePage!.headerFields))
                }
            else if index == 1
                {
                return(FieldHolder(label: "Key Entry Fields",fields: self.btreePage!.keyEntryFields))
                }
            else
                {
                return(FieldHolder(label: "Free Cell Fields",fields: self.btreePage!.freeCellFields))
                }
            }
        else
            {
            let holder = item as! FieldHolder
            let field = holder.fields[index]
            return(field)
            }
        }
    }

extension BTreePageInspectorViewController: NSOutlineViewDelegate
    {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView?
        {
        if let holder = item as? FieldHolder
            {
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier("Column.0")
                {
                let textField = NSTextField(frame: .zero)
                textField.font = NSFont.systemFont(ofSize: 12)
                textField.isBordered = false
                textField.isEditable = false
                textField.backgroundColor = self.outlineView.backgroundColor
                textField.textColor = self.lowlightColor
                textField.drawsBackground = true
                textField.stringValue = holder.label
                return(textField)
                }
            return(nil)
            }
        if let field = item as? Field
            {
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier("Column.0")
                {
                let textField = NSTextField(frame: .zero)
                textField.font = NSFont.systemFont(ofSize: 12)
                textField.isBordered = false
                textField.isEditable = false
                textField.textColor = self.lowlightColor
                textField.backgroundColor = self.outlineView.backgroundColor
                textField.drawsBackground = true
                textField.stringValue = field.name
                return(textField)
                }
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier("Column.1")
                {
                let textField = NSTextField(frame: .zero)
                textField.font = NSFont.systemFont(ofSize: 12)
                textField.isBordered = false
                textField.alignment = .right
                textField.textColor = self.highlightColor
                textField.backgroundColor = self.outlineView.backgroundColor
                textField.drawsBackground = true
                textField.stringValue = field.value.description
                return(textField)
                }
            }
        return(nil)
        }
    }

public class FieldHolder
    {
    public let fields: FieldSet
    public let label: String
    
    public init(label: String,fields: FieldSet)
        {
        self.label = label
        self.fields = fields
        }
    }