//
//  RepositoryBrowserViewController.swift
//  Medusa
//
//  Created by Vincent Coetzee on 02/12/2023.
//

import Cocoa

class RepositoryBrowserViewController: NSViewController
    {
    @IBOutlet weak var outlineView: NSOutlineView!
    
    override func viewDidLoad()
        {
        super.viewDidLoad()
        self.outlineView.reloadData()
        }
    }

extension RepositoryBrowserViewController: NSOutlineViewDataSource
    {
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool
        {
        if let someClass = item as? MOPClass, someClass.hasSubclasses
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
            return(1)
            }
        else if let someClass = item as? MOPClass
            {
            return(someClass.subklasses.count)
            }
        return(0)
        }
        
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any
        {
        if item.isNil
            {
            return(MOPRepository.rootClass)
            }
        else if let someClass = item as? MOPClass
            {
            return(someClass.subklasses[index])
            }
        fatalError()
        }
    }

extension RepositoryBrowserViewController: NSOutlineViewDelegate
    {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView?
        {
        if let someClass = item as? MOPClass
            {
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier("Column.0")
                {
                let textField = NSTextField(frame: .zero)
                textField.font = NSFont.systemFont(ofSize: 12)
                textField.isBordered = false
                textField.isEditable = false
                textField.backgroundColor = self.outlineView.backgroundColor
                textField.textColor = NSColor.argonLivingCoral
                textField.drawsBackground = false
                textField.stringValue = someClass.name
                return(textField)
                }
            }
        return(nil)
        }
    }
