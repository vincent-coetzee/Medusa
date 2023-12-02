//
//  MOPEncoder.swift
//  Medusa
//
//  Created by Vincent Coetzee on 17/11/2023.
//

import Foundation

public class MOPWriter: MOPReader
    {
    private let pageAgent: PageAgent
    private var startPage: Page?
    private var pages = Pages()
    private let startOffset: Integer64
    
    public init(pageAgent: PageAgent,startPage: Page?,startOffset: Integer64)
        {
        self.pageAgent = pageAgent
        self.startPage = startPage
        self.startOffset = startOffset
        super.init()
        }
        
    public func encode(_ integer: Medusa.Integer64)
        {
        
        }
    }
