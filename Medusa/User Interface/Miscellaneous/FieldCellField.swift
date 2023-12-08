////
////  FieldCellField.swift
////  Medusa
////
////  Created by Vincent Coetzee on 22/11/2023.
////
//
//import AppKit
//
//public class FieldCellField: NSTableCellView
//    {
//    public override var intrinsicContentSize: CGSize
//        {
//        if self.labelField.isNotNil && self.valueField.isNotNil
//            {
//            let font = self.labelField.font!
//            let labelSize = NSAttributedString(string: self.labelField.stringValue,attributes: [.font: font]).size()
//            let valueSize = NSAttributedString(string: self.valueField.stringValue,attributes: [.font: font]).size()
//            let size = CGSize(width: labelSize.width + valueSize.width + 20,height: max(labelSize.height,valueSize.height))
//            return(size)
//            }
//        return(.zero)
//        }
//        
//    public override var objectValue: Any?
//        {
//        didSet
//            {
//            self.field = self.objectValue as? Field
//            }
//        }
//        
//    public var field: Field?
//        {
//        didSet
//            {
//            self.valueField.field = self.field
//            self.valueField.alignment = .right
//            self.labelField.stringValue = String(format: "%05d",field?.offset ?? 0) + (self.field?.name ?? "")
//            self.invalidateIntrinsicContentSize()
//            }
//        }
//        
//    private var labelField: NSTextField!
//    private var valueField: FieldValueField!
//    private var paddingField: NSView!
//    
//    public override init(frame: NSRect)
//        {
//        super.init(frame: frame)
//        self.initFields()
//        }
//        
//    public required init?(coder: NSCoder)
//        {
//        super.init(coder: coder)
//        self.initFields()
//        }
//        
//    private func initFields()
//        {
//        self.translatesAutoresizingMaskIntoConstraints = false
//        self.wantsLayer = true
//        self.layer!.borderWidth = 1
//        self.layer!.borderColor = NSColor.orange.cgColor
//        self.labelField = NSTextField(frame: .zero)
//        self.labelField.translatesAutoresizingMaskIntoConstraints = false
//        self.addSubview(self.labelField)
//        self.labelField.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
//        self.labelField.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
//        self.labelField.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
//        self.valueField = FieldValueField(frame: .zero)
//        self.valueField.translatesAutoresizingMaskIntoConstraints = false
//        self.addSubview(self.valueField)
//        self.valueField.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
//        self.valueField.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
//        self.valueField.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
//        self.paddingField = NSView(frame: .zero)
//        self.paddingField.translatesAutoresizingMaskIntoConstraints = false
//        self.addSubview(self.paddingField)
//        self.paddingField.leftAnchor.constraint(equalTo: self.labelField.rightAnchor).isActive = true
//        self.paddingField.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
//        self.paddingField.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
//        self.paddingField.rightAnchor.constraint(equalTo: self.valueField.leftAnchor).isActive = true
//        self.paddingField.widthAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true
//        }
//    }
