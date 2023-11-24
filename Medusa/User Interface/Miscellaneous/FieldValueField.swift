//
//  FieldTextField.swift
//  Medusa
//
//  Created by Vincent Coetzee on 22/11/2023.
//

import AppKit

public class FieldValueField: NSTextField
    {
    public var field: Field?
        {
        didSet
            {
            if self.field.isNotNil
                {
                self.update()
                }
            else
                {
                self.stringValue = "nil"
                }
            }
        }
        
    private func update()
        {
        switch(self.field!.value)
            {
        case .integer(let integer):
            self.stringValue = "\(integer)"
        case .float(let float):
            self.stringValue = String(format: "%.04lf",float)
        case .string(let string):
            self.stringValue = string
        case .magicNumber(let number):
            self.stringValue = String(format: "%08X",number)
        case .checksum(let sum):
            self.stringValue = String(format: "%08X",sum)
        case .offset(let offset):
            self.stringValue = "\(offset)"
        case .pagePointer(let pointer):
            let pagePointer = Medusa.PagePointer(pointer)
            self.stringValue = "\(pagePointer.pageValue):\(pagePointer.offsetValue)"
        case .fixedLengthString(let count, let string):
            self.stringValue = "\(count) \(string)"
        case .keyValueEntry(let offset,let pointer,let keyBytes,let valueBytes):
            self.stringValue = "\(offset):\(pointer) \(keyBytes.sizeInBytes) \(valueBytes.sizeInBytes)"
        case .freeCell(let offset,let next, let size):
            self.stringValue = "\(offset) \(next) \(size)"
        case .pageAddress(let address):
            self.stringValue = "\(address)"
            }
        }
    }
