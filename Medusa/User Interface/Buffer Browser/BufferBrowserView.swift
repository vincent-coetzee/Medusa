//
//  BufferBrowserView.swift
//  Medusa
//
//  Created by Vincent Coetzee on 16/11/2023.
//

import AppKit

public class FieldLayer: CALayer
    {
    private let label: String
    public let leftText = CATextLayer()
    public let labelText = CATextLayer()
    public let rightText = CATextLayer()
    public var field: Field!
    
    public var font: NSFont!
        {
        didSet
            {
            self.leftText.font = self.font as CFTypeRef
            self.leftText.fontSize = self.font.pointSize
            self.labelText.font = self.font as CFTypeRef
            self.labelText.fontSize = self.font.pointSize
            self.rightText.font = self.font as CFTypeRef
            self.rightText.fontSize = self.font.pointSize
            self.needsLayout()
            }
        }
        
    public var textColor: NSColor = .clear
        {
        didSet
            {
            self.leftText.foregroundColor = self.textColor.cgColor
            self.labelText.foregroundColor = self.textColor.cgColor
            self.rightText.foregroundColor = self.textColor.cgColor
            self.needsDisplay()
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
        self.label = label
        super.init()
        self.addSublayer(self.leftText)
        self.addSublayer(self.labelText)
        self.addSublayer(self.rightText)
        self.leftText.string = left
        self.labelText.string = label
        self.rightText.string = right
        self.labelText.isWrapped = true
        self.labelText.alignmentMode = .center
        self.labelText.truncationMode = .end
        }
        
    public required init?(coder: NSCoder)
        {
        self.label = ""
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
            let leftSize = string.size()
            self.leftText.frame = CGRect(x: theseBounds.origin.x + 4,y: theseBounds.origin.y,width: leftSize.width,height: leftSize.height)
            string = NSAttributedString(string: self.rightText.string as! String,attributes: [.font:self.font!,.foregroundColor: self.textColor])
            let rightSize = string.size()
            let extraX = theseBounds.width - rightSize.width - 4
            self.rightText.frame = CGRect(x: theseBounds.origin.x + extraX,y: theseBounds.origin.y,width: rightSize.width,height: rightSize.height)
            self.layoutLabel(leftSize: leftSize,rightSize: rightSize)
            }
        }
        
    private func layoutLabel(leftSize: CGSize,rightSize: CGSize)
        {
        let theseBounds = self.bounds
        let string = NSAttributedString(string: self.labelText.string as! String,attributes: [.font:self.font!,.foregroundColor: self.textColor])
        let size = string.size()
        let height = size.height * 2 + 2
        if size.width > theseBounds.width - leftSize.width - rightSize.width - 4
            {
            let center = self.label.count / 2
            var newString = self.label
            let offset = self.label.index(self.label.startIndex,offsetBy: center)
            if label.unicodeScalars[offset] != " "
                {
                newString.insert(" ",at: offset)
                self.labelText.string = newString
                }
            }
        else
            {
            let extraX = (theseBounds.width - size.width) / 2
            self.labelText.frame = CGRect(x: theseBounds.origin.x + extraX,y: theseBounds.origin.y,width: size.width,height: height)
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
            self.needsDisplay = true
            }
        }
        
    private var font: NSFont!
    private var boldFont: NSFont!
    private var smallBoldFont: NSFont!
    private var smallFont: NSFont!
    private var textColor: NSColor!
    private var columnCount: Int = 0
    private var textLayers = Array<CATextLayer>()
    private var columnWidth: CGFloat = 0
    private var rowLabelWidth: CGFloat = 0
    private var rowHeight: CGFloat = 0
    private var leftLabelInset: CGFloat = 0
    private var leftTextInset: CGFloat = 0
    private var columnGutterWidth: CGFloat = 10
    private var lineColor = NSColor.argonWhite40
    private var highlightColor = NSColor.argonLivingCoral
    private var regularColor = NSColor.argonWhite80
    private var lowlightColor = NSColor.argonTribalSeaGreen
    private let colorA = NSColor.argonGreenBlueCrayola.withAlpha(0.2)
    private let colorB = NSColor.argonFreshSalmon.withAlpha(0.2)
    private var currentLayer: CALayer = CALayer()
    private var leftOver: CGFloat = 0
    private var sections = Array<Field.Section>()
    private var savedViewSize: CGSize = .zero
    private var defaultViewWidth: CGFloat = (20 + 10) * 16 + 100
    
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
        self.font = NSFont.systemFont(ofSize: 11)
        self.boldFont = NSFont.boldSystemFont(ofSize: 11)
        self.smallBoldFont = self.boldFont.with(size: self.boldFont.pointSize - 1)
        self.smallFont = NSFont.monospacedDigitSystemFont(ofSize: 9, weight: .bold)
        self.measure(usingWidth: self.frame.width)
        }
        
    @objc public func scrollViewFrameChanged(_ notification: NSNotification)
        {
        self.invalidateIntrinsicContentSize()
        }
        
    private func measure(usingWidth width: CGFloat)
        {
        let label = NSAttributedString(string: "000000",attributes: [.font: self.font!,.foregroundColor: NSColor.white])
        self.rowLabelWidth = label.size().width
        self.leftLabelInset = 4
        self.leftTextInset = self.rowLabelWidth + self.leftLabelInset
        let size = self.measureColumnWidth()
        self.columnWidth = size.width
        self.rowHeight = size.height
        let availableWidth = width - self.leftTextInset
        self.columnCount = Int(trunc(availableWidth / (self.columnWidth + self.columnGutterWidth)))
        }
        
    public override func layout()
        {
        super.layout()
        self.measure(usingWidth: self.frame.width)
        }
        
    public override func mouseDown(with event: NSEvent)
        {
        let point = self.convert(event.locationInWindow, from: nil)
        for section in self.sections
            {
            if section.frame.contains(point)
                {
                let viewController = NSStoryboard.main!.instantiateController(withIdentifier: "bufferBrowserPopoverViewController") as! BufferBrowserPopoverViewController
                let popover = NSPopover()
                popover.behavior = .transient
                popover.contentViewController = viewController
                popover.show(relativeTo: section.frame, of: self,preferredEdge: .maxX)
                viewController.buffer = self.buffer
                viewController.field = section.field
                return
                }
            }
        }
        
//    public override func draw(_ rectangle: NSRect)
//        {
//        if buffer.isNil
//            {
//            return
//            }
//        var rectCount = 0
//        var rects: UnsafePointer<NSRect>?
//        var theRects = Array<NSRect>()
//        self.getRectsBeingDrawn(&rects, count: &rectCount)
//        if let rects = rects
//            {
//            var pointer = rects
//            for _ in 0..<rectCount
//                {
//                theRects.append(rects.pointee)
//                pointer += 1
//                }
//            }
//        var offset = CGPoint(x: self.leftTextInset + self.columnGutterWidth,y: 6 + self.rowHeight)
//        var rowCount = 0
//        self.insertRowMarker(row: rowCount,at: CGPoint(x: self.leftLabelInset,y: offset.y))
//        
//        for index in 1...buffer.sizeInBytes
//            {
//            if rectangle.contains(offset)
//                {
//                let value = self.buffer[index - 1]
//                let text = self.valueType.format(Int(value))
//                let someFont = value == 0 ? self.font! : self.boldFont!
//                let color = value == 0 ? self.lowlightColor : self.highlightColor
//                let string = NSAttributedString(string: text,attributes: [.font: someFont,.foregroundColor: color])
//                string.draw(at: offset)
//                offset.x += self.columnGutterWidth + self.columnWidth
//                if (index % self.columnCount == 0) && index > 0
//                    {
//                    offset.y += rowHeight
//                    rowCount += 1
//                    offset.x = self.leftTextInset + self.columnGutterWidth
//                    offset.y += self.rowHeight
//                    self.insertRowMarker(row: rowCount * self.columnCount,at: CGPoint(x: self.leftLabelInset,y: offset.y))
//                    }
//                    
//                }
//            }
//        self.drawFields()
//        }
        
    public override func draw(_ rectangle: NSRect)
        {
        if buffer.isNil
            {
            return
            }
        var rectCount = 0
        var rects: UnsafePointer<NSRect>?
        var theRects = Array<NSRect>()
        self.getRectsBeingDrawn(&rects, count: &rectCount)
        if let rects = rects
            {
            var pointer = rects
            for _ in 0..<rectCount
                {
                theRects.append(rects.pointee)
                pointer += 1
                }
            }
        var offset = CGPoint(x: self.leftTextInset + self.columnGutterWidth,y: 6 + self.rowHeight)
        var rowCount = 0
        self.insertRowMarker(row: rowCount,at: CGPoint(x: self.leftLabelInset,y: offset.y))
        for index in 1...buffer.sizeInBytes
            {
            let value = self.buffer[index - 1]
            let text = self.valueType.format(Int(value))
            let someFont = value == 0 ? self.font! : self.boldFont!
            let color = value == 0 ? self.lowlightColor : self.highlightColor
            let string = NSAttributedString(string: text,attributes: [.font: someFont,.foregroundColor: color])
            let rectToDraw = CGRect(origin: offset,size: string.size())
            if self.needsToDraw(rectToDraw)
                {
                string.draw(at: offset)
                }
            offset.x += self.columnGutterWidth + self.columnWidth
            if (index % self.columnCount == 0) && index > 0
                {
                offset.y += rowHeight
                rowCount += 1
                offset.x = self.leftTextInset + self.columnGutterWidth
                offset.y += self.rowHeight
                self.insertRowMarker(row: rowCount * self.columnCount,at: CGPoint(x: self.leftLabelInset,y: offset.y))
                }
            }
        self.drawFields()
        }
        
    public override var intrinsicContentSize: CGSize
        {
        if self.buffer.isNil
            {
            return(CGSize(width: self.defaultViewWidth,height: self.defaultViewWidth))
            }
        var width = self.enclosingScrollView!.frame.width
        width = width < self.defaultViewWidth ? self.defaultViewWidth : width
        self.measure(usingWidth: width)
        let height = CGFloat((self.buffer.sizeInBytes / self.columnCount) + 1) * self.rowHeight
        return(CGSize(width: width,height: height))
        }
        
    private func drawFields()
        {
        let totalWidth = self.columnWidth + self.columnGutterWidth
        let twiceRowHeight = 2 * self.rowHeight
        var flipper = 0
        let attributes: [NSAttributedString.Key:Any] = [.font: self.smallFont!,.foregroundColor: NSColor.white]
        self.sections = Array()
        for field in self.buffer.fields.flattenedFields.filter({$0.isBufferBased}).sorted(by: {$0.startOffset < $1.startOffset})
            {
            let sections = field.sections(withRowWidth: self.columnCount)
            let color = (flipper == 0 ? self.colorA : self.colorB)
            flipper = flipper == 0 ? 1 : 0
            for section in sections
                {
                let minY = CGFloat(section.startRow) * twiceRowHeight + 6
                let minX = CGFloat(section.startColumn) * totalWidth + self.leftTextInset + 4
                let maxY = minY + twiceRowHeight + 1
                let maxX = minX + CGFloat(section.stopColumn - section.startColumn) * totalWidth - 4
                let rect = CGRect(x: minX,y: minY,width: maxX - minX,height: maxY - minY)
                section.frame = rect
                self.sections.append(section)
                let left =  NSAttributedString(string:"\(section.startOffset(rowWidth: self.columnCount))",attributes: attributes)
                left.draw(at: NSPoint(x: minX,y: minY))
                let nameString = NSAttributedString(string: field.name,attributes: attributes)
                let nameSize = nameString.size()
                let xPoint = minX + (rect.width - nameSize.width) / 2
                let leftMax = minX + left.size().width
                if xPoint > leftMax
                    {
                    nameString.draw(at: NSPoint(x: xPoint,y:minY))
                    }
                let right = NSAttributedString(string:"\(section.stopOffset(rowWidth: self.columnCount) - 1)",attributes: attributes)
                let rightSize = right.size()
                let rightX = maxX - rightSize.width
                if rightX > leftMax
                    {
                    right.draw(at: NSPoint(x: rightX,y: minY))
                    }
                let path = NSBezierPath(rect: rect)
                color.set()
                path.fill()
                path.lineWidth = 1
                self.lineColor.set()
                path.stroke()
                }
            }
        }
        
    private func insertRowMarker(row: Int,at offset: CGPoint)
        {
        let text = String(row,radix: 10,uppercase: true)
        var frame = CGRect(origin: offset,size: CGSize(width: self.rowLabelWidth,height: self.rowHeight))
        let string = NSAttributedString(string: text,attributes: [.font: self.smallBoldFont!,.foregroundColor: self.regularColor])
        let size = string.size()
        frame.origin.x += frame.size.width - size.width
        if self.needsToDraw(frame)
            {
            string.draw(in: frame)
            }
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
