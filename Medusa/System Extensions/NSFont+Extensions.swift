//
//  NSFont+Extensions.swift
//  Medusa
//
//  Created by Vincent Coetzee on 23/11/2023.
//

import AppKit

extension NSFont
    {
    public func with(size: CGFloat) -> NSFont?
        {
        NSFont(name: self.fontName, size: self.pointSize)
        }
    }
