////
////  BtreePageInspectorViewController.swift
////  Medusa
////
////  Created by Vincent Coetzee on 22/11/2023.
////
//
//import Cocoa
//
//class BTreePageInspectorViewController: NSViewController
//    {
//    public var btreePage: BTreePage<String,String>?
//        {
//        didSet
//            {
//            self.field = self.btreePage!.fields
//            self.outlineView.reloadData()
//            }
//        }
//        
//    private var highlightColor = NSColor.argonLivingCoral
//    private var regularColor = NSColor.argonWhite80
//    private var lowlightColor = NSColor.argonTribalSeaGreen
//    private var field: CompositeField!
//    
//    @IBOutlet weak var outlineView: NSOutlineView!
//    
//    override func viewDidLoad()
//        {
//        super.viewDidLoad()
////        self.btreePage = BTreePage(magicNumber: Medusa.kBTreePageMagicNumber)
////        do
////            {
////            try self.btreePage?.insertKeyEntry(key: "Vincent", value: "Some text that will be stuffed in.", pointer: Medusa.PageAddress(1_000_000_000))
////            try self.btreePage?.insertKeyEntry(key: "Joan", value: "More text.", pointer: Medusa.PageAddress(2_000_000))
////            try self.btreePage?.insertKeyEntry(key: "Jen", value: "Jennifer has no problem speaking in public and can say a lot of things in a short space of time.", pointer: Medusa.PageAddress(11_000_000))
////            try self.btreePage?.insertKeyEntry(key: "Stevie", value: "Stevie is now all grown up and married.", pointer: Medusa.PageAddress(2_000_000))
////            try self.btreePage?.insertKeyEntry(key: "Daniel", value: "Daniel is very boring I am told.", pointer: Medusa.PageAddress(2_000_000))
////            }
////        catch let issue as SystemIssue
////            {
////            print("Issue occurred: \(issue.message)")
////            }
////        catch
////            {
////            }
////        self.btreePage?.rightPointer = Medusa.PageAddress(5_555_555_555)
////        self.btreePage?.write()
//        self.outlineView.backgroundColor = NSColor.argonBlack50
//        self.outlineView.font = NSFont.systemFont(ofSize: 13)
////        let pp = Medusa.PagePointer(page: 1000,offset: 400)
////        print(Medusa.bitString(integer: pp))
////        print(pp.pageValue)
////        print(pp.offsetValue)
//        self.outlineView.rowHeight = 20
//        self.outlineView.reloadData()
////        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
////        let windowController = storyboard.instantiateController(withIdentifier: "bufferBrowserWindowController") as! NSWindowController
////        let viewController = windowController.contentViewController as! BufferBrowserViewController
////        windowController.showWindow(self)
////        viewController.buffer = btreePage!.pageBuffer
//        }
//    }
//
//
//extension BTreePageInspectorViewController: NSOutlineViewDataSource
//    {
//    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool
//        {
//        if item is CompositeField
//            {
//            return(true)
//            }
//        else
//            {
//            return(false)
//            }
//        }
//        
//    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int
//        {
//        if item.isNil
//            {
//            if self.btreePage.isNil
//                {
//                return(0)
//                }
//            return(1)
//            }
//        else if let field = item as? CompositeField
//            {
//            return(field.count)
//            }
//        else if item is Field
//            {
//            return(0)
//            }
//        return(0)
//        }
//        
//    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any
//        {
//        if item.isNil
//            {
//            return(self.field!)
//            }
//        else if let field = item as? CompositeField
//            {
//            return(field[index])
//            }
//        fatalError()
//        }
//    }
//
//extension BTreePageInspectorViewController: NSOutlineViewDelegate
//    {
//    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView?
//        {
//        if let composite = item as? CompositeField
//            {
//            if tableColumn?.identifier == NSUserInterfaceItemIdentifier("Column.0")
//                {
//                let textField = NSTextField(frame: .zero)
//                textField.font = NSFont.systemFont(ofSize: 12)
//                textField.isBordered = false
//                textField.isEditable = false
//                textField.backgroundColor = self.outlineView.backgroundColor
//                textField.textColor = self.lowlightColor
//                textField.drawsBackground = true
//                textField.stringValue = composite.name
//                return(textField)
//                }
//            return(nil)
//            }
//        if let field = item as? Field
//            {
//            if tableColumn?.identifier == NSUserInterfaceItemIdentifier("Column.0")
//                {
//                let textField = NSTextField(frame: .zero)
//                textField.font = NSFont.systemFont(ofSize: 12)
//                textField.isBordered = false
//                textField.isEditable = false
//                textField.alignment = .right
//                textField.textColor = self.lowlightColor
//                textField.backgroundColor = self.outlineView.backgroundColor
//                textField.drawsBackground = true
//                textField.stringValue = field.name
//                return(textField)
//                }
//            if tableColumn?.identifier == NSUserInterfaceItemIdentifier("Column.1")
//                {
//                let textField = NSTextField(frame: .zero)
//                textField.font = NSFont.systemFont(ofSize: 12)
//                textField.isBordered = false
//                textField.textColor = self.highlightColor
//                textField.backgroundColor = self.outlineView.backgroundColor
//                textField.drawsBackground = true
//                textField.stringValue = field.value.description
//                return(textField)
//                }
//            }
//        return(nil)
//        }
//    }
