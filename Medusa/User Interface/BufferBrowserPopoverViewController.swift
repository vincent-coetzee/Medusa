//
//  BufferBrowserPopoverViewController.swift
//  Medusa
//
//  Created by Vincent Coetzee on 27/11/2023.
//

import Cocoa
import Fletcher

public class BufferBrowserPopoverViewController: NSViewController
    {
    @IBOutlet var kindPopUpButton: NSPopUpButton!
    @IBOutlet var nameLabel: NSTextField!
    @IBOutlet var startOffsetLabel: NSTextField!
    @IBOutlet var stopOffsetLabel: NSTextField!
    @IBOutlet var hexLabel: NSTextField!
    @IBOutlet var decimalLabel: NSTextField!
    @IBOutlet var binaryLabel: NSTextField!
    
    public var buffer: Buffer!
        {
        didSet
            {
            self.bufferReader = BufferReader(on: self.buffer)
            if buffer.isNotNil && self.field.isNotNil
                {
                self.onKindSelected(self)
                }
            }
        }
        
    private var bufferReader: BufferReader!
    
    public var field: Field!
        {
        didSet
            {
            self.nameLabel.stringValue = field.name
            self.startOffsetLabel.stringValue = "\(field.startOffset)"
            self.stopOffsetLabel.stringValue = "\(field.stopOffset)"
            if buffer.isNotNil && self.field.isNotNil
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
            let (decimal,hex,binary) = self.bufferReader.values(forTitle: title,fromByteOffset: field.startOffset,sizeInBytes: field.value.sizeInBytes)
            self.decimalLabel.stringValue = decimal
            self.hexLabel.stringValue = hex
            self.binaryLabel.stringValue = binary
            }
        }
    }

public struct BufferReader
    {
    private let buffer: Buffer
    
    public init(on buffer: Buffer)
        {
        self.buffer = buffer
        }
        
    public func values(forTitle: String,fromByteOffset: Int,sizeInBytes: Int) -> (String,String,String)
        {
        switch(forTitle)
            {
            case("Integer64"):
            let value = readInteger(self.buffer.rawPointer,fromByteOffset)
//                let value = KindReader<Medusa.Integer64>(bytes: self.buffer.bytes(atByteOffset: fromByteOffset, sizeInBytes: sizeInBytes)).value()
                let hex = String(value,radix: 16,uppercase: true)
                let decimal = "\(value)"
                let binary = Medusa.bitString(value)
                return(decimal,hex,binary)
            case("Integer32"):
                let value = readInteger32(self.buffer.rawPointer,fromByteOffset)
//                let value = KindReader<Medusa.Integer32>(bytes: self.buffer.bytes(atByteOffset: fromByteOffset, sizeInBytes: sizeInBytes)).value()
                let hex = String(value,radix: 16,uppercase: true)
                let decimal = "\(value)"
                let binary = Medusa.bitString(value)
                return(decimal,hex,binary)
            case("Integer16"):
                let value = readInteger16(self.buffer.rawPointer,fromByteOffset)
//                let value = KindReader<Medusa.Integer16>(bytes: self.buffer.bytes(atByteOffset: fromByteOffset, sizeInBytes: sizeInBytes)).value()
                let hex = String(value,radix: 16,uppercase: true)
                let decimal = "\(value)"
                let binary = Medusa.bitString(value)
                return(decimal,hex,binary)
            case("Unsigned64"):
                let value = readUnsigned(self.buffer.rawPointer,fromByteOffset)
//                let value = KindReader<Medusa.Unsigned64>(bytes: self.buffer.bytes(atByteOffset: fromByteOffset, sizeInBytes: sizeInBytes)).value()
                let hex = String(value,radix: 16,uppercase: true)
                let decimal = "\(value)"
                let binary = Medusa.bitString(value)
                return(decimal,hex,binary)
            case("Unsigned32"):
                let value = readUnsigned32(self.buffer.rawPointer,fromByteOffset)
//                let value = KindReader<Medusa.Unsigned32>(bytes: self.buffer.bytes(atByteOffset: fromByteOffset, sizeInBytes: sizeInBytes)).value()
                let hex = String(value,radix: 16,uppercase: true)
                let decimal = "\(value)"
                let binary = Medusa.bitString(value)
                return(decimal,hex,binary)
            case("Unsigned16"):
                let value = readUnsigned16(self.buffer.rawPointer,fromByteOffset)
//                let value = KindReader<Medusa.Unsigned16>(bytes: self.buffer.bytes(atByteOffset: fromByteOffset, sizeInBytes: sizeInBytes)).value()
                let hex = String(value,radix: 16,uppercase: true)
                let decimal = "\(value)"
                let binary = Medusa.bitString(value)
                return(decimal,hex,binary)
            case("Byte"):
                let value = readByte(self.buffer.rawPointer,fromByteOffset)
//                let value = KindReader<Medusa.Byte>(bytes: self.buffer.bytes(atByteOffset: fromByteOffset, sizeInBytes: sizeInBytes)).value()
                let hex = String(value,radix: 16,uppercase: true)
                let decimal = "\(value)"
                let binary = Medusa.bitString(value)
                return(decimal,hex,binary)
            case("Float"):
                let value = readFloat(self.buffer.rawPointer,fromByteOffset)
//                let value = KindReader<Medusa.Float>(bytes: self.buffer.bytes(atByteOffset: fromByteOffset, sizeInBytes: sizeInBytes)).value()
                let hex = ""
                let decimal = "\(value)"
                let binary = Medusa.bitString(value)
                return(decimal,hex,binary)
            default:
                return("","","")
            }
        }
    }


public struct KindReader<Kind>
    {
    private let bytes: Array<Medusa.Byte>
    
    public init(bytes: Array<Medusa.Byte>)
        {
        self.bytes = bytes
        }
        
    public func value() -> Kind
        {
        let rawPointer = UnsafeMutableRawPointer.allocate(byteCount: MemoryLayout<Kind.Type>.size, alignment: 1)
        defer
            {
            rawPointer.deallocate()
            }
        var offset = 0
        for byte in  self.bytes
            {
            rawPointer.storeBytes(of: byte, toByteOffset: offset, as: Medusa.Byte.self)
            print("WRITING VALUE BYTE \(String(byte,radix: 16,uppercase: true))")
            offset += 1
            }
        let value = rawPointer.load(fromByteOffset: 0, as: Kind.self)
        return(value)
        }
    }
