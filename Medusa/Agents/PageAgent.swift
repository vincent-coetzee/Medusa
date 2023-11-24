//
//  PageAgent.swift
//  Xenon
//
//  Created by Vincent Coetzee on 15/11/2023.
//

import Foundation

public class PageAgent: BaseAgent
    {
    public override func boot()
        {
        self.name = "Pager"
        super.boot()
        self.loadColdStartPages()
        }
        
    private func loadColdStartPages()
        {
        }
    }
