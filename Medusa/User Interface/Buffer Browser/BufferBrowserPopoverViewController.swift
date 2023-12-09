//
//  BufferBrowserPopoverViewController.swift
//  Medusa
//
//  Created by Vincent Coetzee on 27/11/2023.
//

import AppKit
import Fletcher
import MedusaCore
import MedusaStorage

public class BufferBrowserPopoverViewController: NSViewController
    {
    @IBOutlet var kindPopUpButton: NSPopUpButton!
    @IBOutlet var nameLabel: NSTextField!
    @IBOutlet var startOffsetLabel: NSTextField!
    @IBOutlet var stopOffsetLabel: NSTextField!
    @IBOutlet var hexLabel: NSTextField!
    @IBOutlet var decimalLabel: NSTextField!
    @IBOutlet var binaryLabel: NSTextField!
    
    public var annotatedBytes: AnnotatedBytes!
        {
        didSet
            {
            if self.annotatedBytes.isNotNil && self.annotation.isNotNil
                {
                self.onKindSelected(self)
                }
            }
        }

    public var annotation: AnnotatedBytes.Annotation!
        {
        didSet
            {
            self.nameLabel.stringValue = annotation.key
            self.startOffsetLabel.stringValue = "\(annotation.startOffset)"
            self.stopOffsetLabel.stringValue = "\(annotation.stopOffset - 1)"
            if annotation.isNotNil && self.annotation.isNotNil
                {
                self.onKindSelected(self)
                }
            }
        }
        
    public override func viewDidLoad()
        {
        super.viewDidLoad()
        let titles = ["Integer64","Integer32","Integer16","Unsigned64","Unsigned32","Unsigned16","Byte","Float"]
        self.kindPopUpButton.addItems(withTitles: titles)
        self.kindPopUpButton.selectItem(withTitle: "Integer64")
        self.kindPopUpButton.target = self
        self.kindPopUpButton.action = #selector(self.onKindSelected)
        }
    
    @objc func onKindSelected(_ sender: Any?)
        {
        let title = self.kindPopUpButton.titleOfSelectedItem
        if let title
            {
            let (decimal,hex,binary) = self.values(forTitle: title,fromByteOffset: self.annotation.startOffset,sizeInBytes: self.annotation.value.sizeInBytes)
            self.decimalLabel.stringValue = decimal
            self.hexLabel.stringValue = hex
            self.binaryLabel.stringValue = binary
            }
        }
        
    private func values(forTitle: String,fromByteOffset: Int,sizeInBytes: Int) -> (String,String,String)
        {
        switch(forTitle)
            {
            case("Integer64"):
            let value = readInteger64(self.annotatedBytes.bytesPointer,fromByteOffset)
                let hex = String(value,radix: 16,uppercase: true)
                let decimal = "\(value)"
                let binary = value.bitString
                return(decimal,hex,binary)
            case("Integer32"):
                let value = readInteger32(self.annotatedBytes.bytesPointer,fromByteOffset)
                let hex = String(value,radix: 16,uppercase: true)
                let decimal = "\(value)"
                let binary = value.bitString
                return(decimal,hex,binary)
            case("Integer16"):
                let value = readInteger16(self.annotatedBytes.bytesPointer,fromByteOffset)
                let hex = String(value,radix: 16,uppercase: true)
                let decimal = "\(value)"
                let binary = value.bitString
                return(decimal,hex,binary)
            case("Unsigned64"):
                let value = readUnsigned64(self.annotatedBytes.bytesPointer,fromByteOffset)
                let hex = String(value,radix: 16,uppercase: true)
                let decimal = "\(value)"
                let binary = value.bitString
                return(decimal,hex,binary)
            case("Unsigned32"):
                let value = readUnsigned32(self.annotatedBytes.bytesPointer,fromByteOffset)
                let hex = String(value,radix: 16,uppercase: true)
                let decimal = "\(value)"
                let binary = value.bitString
                return(decimal,hex,binary)
            case("Unsigned16"):
                let value = readUnsigned16(self.annotatedBytes.bytesPointer,fromByteOffset)
                let hex = String(value,radix: 16,uppercase: true)
                let decimal = "\(value)"
                let binary = value.bitString
                return(decimal,hex,binary)
            case("Byte"):
                let value = readByte(self.annotatedBytes.bytesPointer,fromByteOffset)
                let hex = String(value,radix: 16,uppercase: true)
                let decimal = "\(value)"
                let binary = value.bitString
                return(decimal,hex,binary)
            case("Float"):
                let value = readFloat64(self.annotatedBytes.bytesPointer,fromByteOffset)
                let hex = ""
                let decimal = "\(value)"
                let binary = value.bitString
                return(decimal,hex,binary)
            default:
                return("","","")
            }
        }
    }

//public struct KindReader<Kind>
//    {
//    private let bytes: Array<Byte>
//    
//    public init(bytes: Array<Byte>)
//        {
//        self.bytes = bytes
//        }
//        
//    public func value() -> Kind
//        {
//        let rawPointer = UnsafeMutableRawPointer.allocate(byteCount: MemoryLayout<Kind.Type>.size, alignment: 1)
//        defer
//            {
//            rawPointer.deallocate()
//            }
//        var offset = 0
//        for byte in  self.bytes
//            {
//            rawPointer.storeBytes(of: byte, toByteOffset: offset, as: Byte.self)
//            print("WRITING VALUE BYTE \(String(byte,radix: 16,uppercase: true))")
//            offset += 1
//            }
//        let value = rawPointer.load(fromByteOffset: 0, as: Kind.self)
//        return(value)
//        }
//    }
