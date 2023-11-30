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
                }
            else
                {
                self.stringValue = "nil"
                }
            }
        }
    }
