//
//  BufferBrowserPopoverViewController.swift
//  Medusa
//
//  Created by Vincent Coetzee on 27/11/2023.
//

import Cocoa

public class BufferBrowserPopoverViewController: NSViewController
    {
    @IBOutlet var kindPopUpButton: NSPopUpButton!
    @IBOutlet var nameLabel: NSTextField!
    @IBOutlet var startOffsetLabel: NSTextField!
    @IBOutlet var stopOffsetLabel: NSTextField!
    @IBOutlet var kindValueLabel: NSTextField!
    
    public var buffer: Buffer!
        {
        didSet
            {
            self.bufferReader = BufferReader(on: self.buffer)
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
            }
        }
        
    public override func viewDidLoad()
        {
        super.viewDidLoad()
        let titles = ["Integer64","Integer32","Integer16","Unsigned64","Unsigned32","Unsigned16","Byte","Float"]
        self.kindPopUpButton.addItems(withTitles: titles)
        self.kindPopUpButton.target = self
        self.kindPopUpButton.action = #selector(self.onKindSelected)
        }
    
    @objc func onKindSelected(_ sender: Any?)
        {
        let title = self.kindPopUpButton.titleOfSelectedItem
        if let title
            {
            let value = self.bufferReader.string(forTitle: title,fromByteOffset: field.startOffset,sizeInBytes: field.value.sizeInBytes)
            self.kindValueLabel.stringValue = value
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
        
    public func string(forTitle: String,fromByteOffset: Int,sizeInBytes: Int) -> String
        {
        switch(forTitle)
            {
            case("Integer64"):
                let value = KindReader<Medusa.Integer64>(bytes: self.buffer.bytes(atByteOffset: fromByteOffset, sizeInBytes: sizeInBytes)).value()
                let hex = String(value,radix: 16,uppercase: true)
                let decimal = "\(value)"
                let binary = Medusa.bitString(value)
                return("\(decimal) \(hex) \(binary)")
            case("Integer32"):
                let value = KindReader<Medusa.Integer32>(bytes: self.buffer.bytes(atByteOffset: fromByteOffset, sizeInBytes: sizeInBytes)).value()
                let hex = String(value,radix: 16,uppercase: true)
                let decimal = "\(value)"
                let binary = Medusa.bitString(value)
                return("\(decimal) \(hex) \(binary)")
            case("Integer16"):
                let value = KindReader<Medusa.Integer16>(bytes: self.buffer.bytes(atByteOffset: fromByteOffset, sizeInBytes: sizeInBytes)).value()
                let hex = String(value,radix: 16,uppercase: true)
                let decimal = "\(value)"
                let binary = Medusa.bitString(value)
                return("\(decimal) \(hex) \(binary)")
            case("Unsigned64"):
                let value = KindReader<Medusa.Unsigned64>(bytes: self.buffer.bytes(atByteOffset: fromByteOffset, sizeInBytes: sizeInBytes)).value()
                let hex = String(value,radix: 16,uppercase: true)
                let decimal = "\(value)"
                let binary = Medusa.bitString(value)
                return("\(decimal) \(hex) \(binary)")
            case("Unsigned32"):
                let value = KindReader<Medusa.Unsigned32>(bytes: self.buffer.bytes(atByteOffset: fromByteOffset, sizeInBytes: sizeInBytes)).value()
                let hex = String(value,radix: 16,uppercase: true)
                let decimal = "\(value)"
                let binary = Medusa.bitString(value)
                return("\(decimal) \(hex) \(binary)")
            case("Unsigned16"):
                let value = KindReader<Medusa.Unsigned16>(bytes: self.buffer.bytes(atByteOffset: fromByteOffset, sizeInBytes: sizeInBytes)).value()
                let hex = String(value,radix: 16,uppercase: true)
                let decimal = "\(value)"
                let binary = Medusa.bitString(value)
                return("\(decimal) \(hex) \(binary)")
            case("Byte"):
                let value = KindReader<Medusa.Byte>(bytes: self.buffer.bytes(atByteOffset: fromByteOffset, sizeInBytes: sizeInBytes)).value()
                let hex = String(value,radix: 16,uppercase: true)
                let decimal = "\(value)"
                let binary = Medusa.bitString(value)
                return("\(decimal) \(hex) \(binary)")
            case("Float"):
                let value = KindReader<Medusa.Float>(bytes: self.buffer.bytes(atByteOffset: fromByteOffset, sizeInBytes: sizeInBytes)).value()
                let decimal = "\(value)"
                let binary = Medusa.bitString(value)
                return("\(decimal) \(binary)")
            default:
                return("")
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
        var pointer = UnsafeMutablePointer<Medusa.Byte>.allocate(capacity: self.bytes.count)
        let original = pointer
        defer
            {
            original.deallocate()
            }
        var offset = 0
        for byte in  self.bytes
            {
            pointer.pointee = byte
            pointer += 1
            }
        let value = original.withMemoryRebound(to: Kind.self, capacity: 1)
            {
            valuePointer in
            return(valuePointer.pointee)
            }
        return(value)
        }
    }
