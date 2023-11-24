//
//  BufferBrowserView.swift
//  Medusa
//
//  Created by Vincent Coetzee on 16/11/2023.
//

import Cocoa

class BufferBrowserView: NSView
    {
    public enum ValueType: Int
        {
        case binary = 2
        case decimal = 10
        case hexadecimal = 16
        
        public func format(_ value: Int) -> String
            {
            switch(self)
                {
                case .binary:
                    return(self.pad(String(value,radix: 2),with: "0",upto: 8))
                case .decimal:
                    return(self.pad(String(format:"%03d",value),with: "0",upto: 3))
                case .hexadecimal:
                    return(self.pad(String(format:"%02X",value),with: "0",upto: 2))
                }
//            var string = String(value,radix: self.rawValue,uppercase: true)
//            while string.count < self.rawValue
//                {
//                string = "0" + string
//                }
//            return(string)
            }
            
        private func pad(_ string: String,with padding: String,upto: Int) -> String
            {
            var newString = string
            while newString.count < upto
                {
                newString = padding + newString
                }
            return(newString)
            }
        }
        
    public var buffer: Buffer!
        {
        didSet
            {
            self.needsLayout = true
            }
        }
        
    public var valueType: ValueType = .hexadecimal
        {
        didSet
            {
            self.needsLayout = true
            }
        }
        
    private var font: NSFont!
    private var boldFont: NSFont!
    private var textColor: NSColor!
    private var columnCount: Int = 0
    private var textLayers = Array<CATextLayer>()
    private var columnWidth: CGFloat = 0
    private var rowLabelWidth: CGFloat = 0
    private var rowHeight: CGFloat = 0
    private var leftLabelInset: CGFloat = 0
    private var leftTextInset: CGFloat = 0
    private var columnGutterWidth: CGFloat = 10
    private var highlightColor = NSColor.argonLivingCoral
    private var regularColor = NSColor.argonWhite80
    private var lowlightColor = NSColor.argonTribalSeaGreen
    private var currentLayer: CALayer = CALayer()
    private var leftOver: CGFloat = 0
    
    public override var isFlipped: Bool
        {
        true
        }
        
    public override init(frame: NSRect)
        {
        super.init(frame: frame)
        self.commonInit()
        self.needsLayout = true
        }
        
    public required init?(coder: NSCoder)
        {
        super.init(coder: coder)
        self.commonInit()
        self.needsLayout = true
        }
        
    private func commonInit()
        {
        self.textColor = .white
        self.wantsLayer = true
        self.layer?.addSublayer(currentLayer)
        self.font = NSFont.systemFont(ofSize: 13)
        self.boldFont = NSFont.boldSystemFont(ofSize: 13)
        self.measure()
        }
        
    private func measure()
        {
        let label = NSAttributedString(string: "000000",attributes: [.font: self.font!,.foregroundColor: NSColor.white])
        self.rowLabelWidth = label.size().width
        self.leftLabelInset = 4
        self.leftTextInset = self.rowLabelWidth + self.leftLabelInset
        let size = self.measureColumnWidth()
        self.columnWidth = size.width
        self.rowHeight = size.height
        let availableWidth = self.bounds.size.width - self.leftTextInset
        self.columnCount = Int(trunc(availableWidth / (self.columnWidth + self.columnGutterWidth)))
        self.leftOver = self.bounds.width - (CGFloat(self.columnCount) * (self.columnWidth + self.columnGutterWidth)) - self.leftTextInset
        }
        
    public override func layout()
        {
        super.layout()
        self.needsDisplay = true
        self.measure()
        }
        
    public override func mouseDown(with event: NSEvent)
        {
        }
        
//    private func subFrames(ofFrame frame: CGRect) -> Array<CGRect>
//        {
//        let totalWidth = self.leftTextInset + CGFloat(self.columnCount) * self.columnWidth + CGFloat(self.columnCount - 1) * self.columnGutterWidth
//        if frame.maxX <= totalWidth
//            {
//            return([frame])
//            }
//        var localFrame = frame
//        var width = totalWidth - frame.minX
//        localFrame.origin.x = frame.minX
//        localFrame.size.width = width
//        var trueX = frame.minX
//        var frames = Array<CGRect>()
//        while trueX < frame.maxX
//            {
//            frames.append(localFrame)
//            let deltaX = frame.maxX - trueX
//            width = min(self.bounds.width,deltaX)
//            localFrame.origin.x += width
//            localFrame.size.width = width
//            trueX += width
//            }
//        return(frames)
//        }
        
//    private func pixelOffset(forOffset: Int) -> CGPoint
//        {
//        var pixelOffset = CGPoint(x: self.leftTextInset,y: 0)
//        for _ in 0..<forOffset
//            {
//            pixelOffset.x += self.columnWidth + self.columnGutterWidth
//            if pixelOffset.x >= self.bounds.width
//                {
//                pixelOffset.x = self.leftTextInset
//                pixelOffset.y += self.rowHeight
//                }
//            }
//        return(pixelOffset)
//        }
        
    public override func draw(_ rect: NSRect)
        {
        let width = self.frame.size.width
        var offset = CGPoint(x: self.leftTextInset + self.columnGutterWidth,y: 6)
        var rowCount = 0
        self.insertRowMarker(row: rowCount,at: CGPoint(x: self.leftLabelInset,y: offset.y))
        for index in 1...buffer.sizeInBytes
            {
            let value = self.buffer[Int(index - 1)]
            let text = self.valueType.format(Int(value))
            let someFont = value == 0 ? self.font! : self.boldFont!
            let color = value == 0 ? self.lowlightColor : self.highlightColor
            let string = NSAttributedString(string: text,attributes: [.font: someFont,.foregroundColor: color])
            string.draw(at: offset)
            offset.x += self.columnGutterWidth + self.columnWidth
            if (Int(index) % self.columnCount == 0) && index > 0
                {
                rowCount += 1
                offset.x = self.leftTextInset + self.columnGutterWidth
                offset.y += self.rowHeight
                self.insertRowMarker(row: rowCount * self.columnCount,at: CGPoint(x: self.leftLabelInset,y: offset.y))
                }
            }
        self.frame = CGRect(origin: .zero,size: CGSize(width: width,height: offset.y))
        }
        
    private func insertRowMarker(row: Int,at offset: CGPoint)
        {
        let text = String(row,radix: 10,uppercase: true)
        let font = self.boldFont.with(size: self.boldFont.pointSize - 1)
        let foregroundColor = self.regularColor
        var frame = CGRect(origin: offset,size: CGSize(width: self.rowLabelWidth,height: self.rowHeight))
        let string = NSAttributedString(string: text,attributes: [.font: font!,.foregroundColor: foregroundColor])
        let size = string.size()
        frame.origin.x += frame.size.width - size.width
        string.draw(in: frame)
        }

    private func measureColumnWidth() -> NSSize
        {
        let attributes:Dictionary<NSAttributedString.Key,Any> = [.font: self.font!,.foregroundColor: self.textColor!]
        var someText = ""
        switch(self.valueType)
            {
            case .binary:
                someText = " 00000000"
            case .decimal:
                someText = " 255"
            case .hexadecimal:
                someText = " FF"
            }
        let string = NSAttributedString(string: someText,attributes: attributes)
        return(string.size())
        }
    }


extension CGPoint
    {
    public static func +(lhs: CGPoint,rhs: CGPoint) -> CGPoint
        {
        CGPoint(x: lhs.x + rhs.x,y: lhs.y + rhs.y)
        }
        
    public static func <(lhs: CGPoint,rhs: CGPoint) -> Bool
        {
        lhs.x < rhs.x && lhs.y < rhs.y
        }
    }

extension CGRect
    {
    public var furthestPoint: CGPoint
        {
        CGPoint(x: self.maxX,y: self.maxY)
        }
        
    public static func -(lhs: CGRect,rhs: CGSize) -> CGRect
        {
        CGRect(x: lhs.origin.x + rhs.width,y: lhs.origin.y,width: rhs.width - lhs.origin.x,height: lhs.size.height)
        }
    }
