//
//  BufferBrowserView.swift
//  Medusa
//
//  Created by Vincent Coetzee on 16/11/2023.
//

import AppKit

public class FieldLayer: CALayer
    {
    public let leftText = CATextLayer()
    public let labelText = CATextLayer()
    public let rightText = CATextLayer()
    
    public var font: NSFont!
        {
        didSet
            {
            self.leftText.font = self.font.fontName as CFTypeRef
            self.leftText.fontSize = self.font.pointSize
            self.labelText.font = self.font.fontName as CFTypeRef
            self.labelText.fontSize = self.font.pointSize
            self.rightText.font = self.font.fontName as CFTypeRef
            self.rightText.fontSize = self.font.pointSize
            }
        }
        
    public var textColor: NSColor = .clear
        {
        didSet
            {
            self.leftText.foregroundColor = self.textColor.cgColor
            self.labelText.foregroundColor = self.textColor.cgColor
            self.rightText.foregroundColor = self.textColor.cgColor
            }
        }
        
    public var lineColor: NSColor = .clear
        {
        didSet
            {
            self.borderColor = self.lineColor.cgColor
            self.borderWidth = 1
            }
        }
        
    public var rowHeight: CGFloat!
        {
        didSet
            {
            if self.rowHeight.isNotNil
                {
                self.needsLayout()
                }
            }
        }
    
    public init(left: String,label: String,right: String)
        {
        super.init()
        self.addSublayer(self.leftText)
        self.addSublayer(self.labelText)
        self.addSublayer(self.rightText)
        self.leftText.string = left
        self.labelText.string = label
        self.rightText.string = right
        }
        
    public required init?(coder: NSCoder)
        {
        super.init(coder: coder)
        self.addSublayer(self.leftText)
        self.addSublayer(self.labelText)
        self.addSublayer(self.rightText)
        }
        
    public override func layoutSublayers()
        {
        if self.font.isNotNil
            {
            let theseBounds = self.bounds
            super.layoutSublayers()
            var string = NSAttributedString(string: self.leftText.string as! String,attributes: [.font:self.font!,.foregroundColor: self.textColor])
            var size = string.size()
            self.leftText.frame = CGRect(x: theseBounds.origin.x + 4,y: theseBounds.origin.y,width: size.width,height: size.height)
            string = NSAttributedString(string: self.labelText.string as! String,attributes: [.font:self.font!,.foregroundColor: self.textColor])
            size = string.size()
            var extraX = (theseBounds.width - size.width) / 2
            self.labelText.frame = CGRect(x: theseBounds.origin.x + extraX,y: theseBounds.origin.y,width: size.width,height: size.height)
            string = NSAttributedString(string: self.rightText.string as! String,attributes: [.font:self.font!,.foregroundColor: self.textColor])
            size = string.size()
            extraX = theseBounds.size.width - size.width
            self.rightText.frame = CGRect(x: theseBounds.origin.x + extraX,y: theseBounds.origin.y,width: size.width,height: size.height)
            }
        }
    }
    
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
    private let colorA = NSColor.argonDustyCoral.withAlpha(0.2)
    private let colorB = NSColor.argonSunkistCoral.withAlpha(0.2)
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
        self.layer?.addSublayer(self.currentLayer)
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
        
    public override func draw(_ rect: NSRect)
        {
        let width = self.frame.size.width
        var offset = CGPoint(x: self.leftTextInset + self.columnGutterWidth,y: 6 + self.rowHeight)
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
                offset.y += rowHeight
                rowCount += 1
                offset.x = self.leftTextInset + self.columnGutterWidth
                offset.y += self.rowHeight
                self.insertRowMarker(row: rowCount * self.columnCount,at: CGPoint(x: self.leftLabelInset,y: offset.y))
                }
            }
        self.drawFields()
        self.frame = CGRect(origin: .zero,size: CGSize(width: width,height: offset.y))
        }
        
    private func drawFields()
        {
        let smallFont = NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .bold)
        let twiceRowHeight = 2 * self.rowHeight
        for fieldSet in self.buffer.fieldSets.values
            {
            var flipper = 0
            for field in fieldSet
                {
                if field.name == "checksum"
                    {
                    print("halt")
                    }
                if field.isBufferBased
                    {
                    let sections = field.sections(withRowWidth: self.columnCount)
                    let color = (flipper == 0 ? self.colorA : self.colorB)
                    flipper = flipper == 0 ? 1 : 0
                    for section in sections
                        {
                        let minY = CGFloat(section.startRow) * twiceRowHeight + 6
                        let minX = CGFloat(section.startColumn) * (self.columnWidth + self.columnGutterWidth) + self.leftTextInset + self.columnGutterWidth
                        let maxY = minY + twiceRowHeight
                        let maxX = minX + CGFloat(section.stopColumn) * (self.columnWidth + self.columnGutterWidth) - self.columnGutterWidth
                        let rect = CGRect(x: minX,y: minY,width: maxX - minX,height: maxY - minY)
                        let fieldLayer = FieldLayer(left: "\(section.startOffset(rowWidth: self.columnCount))", label: field.name, right: "\(section.stopOffset(rowWidth: self.columnCount))")
                        self.layer?.insertSublayer(fieldLayer, below: self.currentLayer)
                        fieldLayer.lineColor = .white
                        fieldLayer.font = smallFont
                        fieldLayer.backgroundColor = color.cgColor
//                        color.set()
//                        NSBezierPath.fill(rect)
//                        self.lowlightColor.set()
//                        NSBezierPath.stroke(rect)
//                        let startString = NSAttributedString(string: "\(section.startOffset(rowWidth: self.columnCount))",attributes: [.font: smallFont,.foregroundColor: NSColor.white])
//                        var label = field.name
//                        var nameString = NSAttributedString(string: "\(label)",attributes: [.font: smallFont,.foregroundColor: NSColor.white])
//                        var nameStringSize = nameString.size()
//                        let width = maxX - minX
//                        var prefix = field.name.count - 2
//                        while nameStringSize.width >= width
//                            {
//                            label = String(field.name.prefix(prefix))
//                            prefix -= 2
//                            nameString = NSAttributedString(string: label,attributes: [.font: smallFont,.foregroundColor: NSColor.white])
//                            nameStringSize = nameString.size()
//                            }
//                        let edge = (width - nameStringSize.width) / 2
//                        nameString.draw(at: NSPoint(x: minX + edge,y: minY))
//                        let stopString = NSAttributedString(string: "\(section.stopOffset(rowWidth: self.columnCount))",attributes: [.font: smallFont,.foregroundColor: NSColor.white])
//                        let stopStringSize = stopString.size()
//                        startString.draw(at: NSPoint(x: minX,y: minY))
//                        let deltaX = maxX - stopStringSize.width
//                        stopString.draw(at: NSPoint(x: deltaX,y: minY))
                        }
                    }
                }
            }
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
