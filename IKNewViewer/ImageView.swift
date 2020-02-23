//
//  ImageView.swift
//  ImageClipper
//
//  Created by Bruno Vandekerkhove on 26/04/16.
//  Copyright © 2016 com.brunovandekerkhove. All rights reserved.
//

import Cocoa
import QuartzCore

// MARK: Image View Delegate -

protocol ImageViewDelegate {
    
    func imageViewDidChangeImage(_ imageView: ImageView)
    func imageViewDidChangeSelection(_ imageView: ImageView)
    
}

// MARK: Image View -

class ImageView: NSImageView {
        
    var delegate: ImageViewDelegate?
    
    override var image: NSImage? {
        didSet {
            imageFrame = self.calculateImageFrame()
            clearCropBox()
            delegate?.imageViewDidChangeImage(self)
        }
    }

    
    @objc func croppedImageData(_ size: NSSize, compression: Float) -> Data? {
        
        if let source = self.image {
            
            
            let target = NSImage(size: size)
            let targetRect = NSMakeRect(0, 0, size.width, size.height)
            
            let sourceSize = source.size
            cropBoxFrameRatio = cropBox.ratioOfFrame(imageFrame)
            let sourceRect = NSMakeRect(cropBoxFrameRatio.origin.x * sourceSize.width,
                                        cropBoxFrameRatio.origin.y * sourceSize.height,
                                        cropBoxFrameRatio.size.width * sourceSize.width,
                                        cropBoxFrameRatio.size.height * sourceSize.height)
            
            target.lockFocus()
            source.draw(in: targetRect, from: sourceRect, operation: .copy, fraction: 1.0)
            target.unlockFocus()
            
            
            if let TIFFrepresentation = target.tiffRepresentation {
                
                let imageRepresentation = NSBitmapImageRep(data: TIFFrepresentation)
                let properties = [NSBitmapImageRep.PropertyKey.compressionFactor:NSNumber(value: compression)]
                var imageRep2 = imageRepresentation
                
                if colorProfile == 1 {
                    imageRep2 = imageRepresentation?.converting(to: NSColorSpace.sRGB, renderingIntent: NSColorRenderingIntent.perceptual)
                }
                
                if saveJPEG == 1 {
                    return imageRep2!.representation(using: .jpeg, properties: properties)
                } else {
                    return imageRep2!.representation(using: .tiff, properties: properties)
                }
                
             }
            
        }
        
        return nil
        
    }
    
    func aspectRatio() -> Float? {
        
        if self.image != nil {
            return Float(self.image!.size.width / self.image!.size.height)
        }
        
        return nil
        
    }
    
    func selectionSize() -> NSSize? {
        
        if self.image != nil && selectionIsActive {
            
            cropBoxFrameRatio = cropBox.ratioOfFrame(imageFrame)
            return NSMakeSize(self.image!.size.width * cropBoxFrameRatio.width, self.image!.size.height * cropBoxFrameRatio.height)
            
        }
        
        return nil
        
    }
    
    // MARK: Initializers
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
    }
    
    // MARK: Interface
    
    @objc var imageFrame = NSZeroRect
    
    @objc var selectionPossible = false
    @objc var selectionIsActive = false
    @objc var selectionResizingIsActive = -1
    @objc var selectionMovingIsActive = false
    
    @objc var selectionBox = SelectionBox()
    @objc var selectionHandlers = [SelectionHandler(), SelectionHandler(), SelectionHandler(), SelectionHandler()]
    var overlayBox = OverlayBox()
    
    @objc var cropBox = NSZeroRect
    @objc var startingPoint = NSZeroPoint
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    
        
        self.layer?.shouldRasterize = true
        
        let trackingOptions = NSTrackingArea.Options.activeAlways.union(NSTrackingArea.Options.inVisibleRect).union(NSTrackingArea.Options.mouseMoved)
        let trackingArea = NSTrackingArea(rect: self.bounds, options: trackingOptions, owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)
        
        if self.image != nil {
            imageFrame = self.calculateImageFrame()
        }
        
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(ImageView.windowWillResize),
                                                         name: NSWindow.willStartLiveResizeNotification,
                                                         object: NSApplication.shared.windows.first!)
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(ImageView.windowDidResize),
                                                         name: NSWindow.didResizeNotification,
                                                         object: NSApplication.shared.windows.first!)
    }
    
    // MARK: Window Resizing
    
    @objc var cropBoxFrameRatio = NSZeroRect
    
    @objc func windowWillResize() {
        
        
        cropBoxFrameRatio = cropBox.ratioOfFrame(imageFrame)
    
    }
    
    @objc func windowDidResize() {
        
        
        imageFrame = self.calculateImageFrame()
        
        let newX = cropBoxFrameRatio.origin.x * imageFrame.size.width + imageFrame.origin.x
        let newY = cropBoxFrameRatio.origin.y * imageFrame.size.height + imageFrame.origin.y
        let newWidth = cropBoxFrameRatio.size.width * imageFrame.size.width
        let newHeight = cropBoxFrameRatio.size.height * imageFrame.size.height
        
        cropBox = NSMakeRect(newX, newY, newWidth, newHeight)
        updateCropBox()
        delegate?.imageViewDidChangeSelection(self)
        
    }
    
    // MARK: Actions
    
    override func selectAll(_ sender: Any?) {
        
        cropBox = imageFrame
        updateCropBox()
        
        if !selectionIsActive {
            
            selectionIsActive = true
            
            self.layer?.addSublayer(overlayBox)
            
            self.layer?.addSublayer(selectionBox)
            selectionBox.initializeAnimation()
            
            self.layer?.addSublayer(selectionHandlers[0])
            self.layer?.addSublayer(selectionHandlers[1])
            self.layer?.addSublayer(selectionHandlers[2])
            self.layer?.addSublayer(selectionHandlers[3])
            
        }
        
        delegate?.imageViewDidChangeSelection(self)
        
    }
    
    override func cancelOperation(_ sender: Any?) {
        
        clearCropBox()
        selectionIsActive = false
        updateCropBox()
        delegate?.imageViewDidChangeSelection(self)
        
    }
    
    // MARK: Mouse Events
    
    @objc let cursors =   [NSCursor(image: NSImage(named: "DiagonalResizeCursor")!, hotSpot: NSMakePoint(9, 9)),
                     NSCursor(image: NSImage(named: "BackDiagonalResizeCursor")!, hotSpot: NSMakePoint(9, 9))]
    
    override func mouseMoved(with theEvent: NSEvent) {
        
        var coordinate = self.convert(theEvent.locationInWindow, from: nil)
        coordinate.constraintToRect(imageFrame)
        
        if selectionIsActive {
            
            let activeHandler = mouseOnHandler(coordinate)
            if activeHandler > -1 {
                cursors[activeHandler % 2].set()
            }
            else if mouseOnCropBox(coordinate) {
                NSCursor.openHand.set()
            }
            else {
                NSCursor.arrow.set()
            }
            
        }
        else {
            NSCursor.arrow.set()
        }
        
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        var coordinate = self.convert(theEvent.locationInWindow, from: nil)
        coordinate.constraintToRect(imageFrame)
        
        if selectionIsActive {
            
            let activeHandler = mouseOnHandler(coordinate)
            if  activeHandler > -1 {
                
                selectionResizingIsActive = activeHandler
                
            }
            else if mouseOnCropBox(coordinate) {
                
                selectionMovingIsActive = true
                NSCursor.closedHand.set()
                
            }
            else {
                clearCropBox()
            }
            
        }
        
        startingPoint = coordinate
        selectionPossible = true
        
    }
    
    override func mouseDragged(with theEvent: NSEvent) {
        
        var coordinate = self.convert(theEvent.locationInWindow, from: nil)
        coordinate.constraintToRect(imageFrame)
        
        if selectionMovingIsActive {
            
            cropBox.moveBy(coordinate.x - startingPoint.x, dy: coordinate.y - startingPoint.y, inFrame: imageFrame)
            startingPoint = coordinate
            updateCropBox()
            return
            
        }
        else if selectionResizingIsActive > -1 {
            
            let delta = NSMakeSize(coordinate.x - startingPoint.x,
                                   coordinate.y - startingPoint.y)
            
            if selectionResizingIsActive == 0 { // Bottom left
                startingPoint.x += delta.width
                startingPoint.y += delta.height
                cropBox.size.width -= delta.width
                cropBox.size.height -= delta.height
            }
            else if selectionResizingIsActive == 1 { // Bottom right
                startingPoint.x = cropBox.origin.x
                startingPoint.y += delta.height
                cropBox.size.width += delta.width
                cropBox.size.height -= delta.height
            }
            else if selectionResizingIsActive == 2 { // Top right
                startingPoint.x = cropBox.origin.x
                startingPoint.y = cropBox.origin.y
                cropBox.size.width += delta.width
                cropBox.size.height += delta.height
            }
            else if selectionResizingIsActive == 3 { // Top left
                startingPoint.x += delta.width
                startingPoint.y = cropBox.origin.y
                cropBox.size.width -= delta.width
                cropBox.size.height += delta.height
            }
            
            cropBox.origin = startingPoint
            startingPoint = coordinate
            
        }
        else {
            
            selectionIsActive = true
            
            spanCropBox(startingPoint, endPoint: coordinate)
            self.layer?.addSublayer(overlayBox)
           
            
            self.layer?.addSublayer(selectionBox)
            selectionBox.initializeAnimation()
            if selectionIsActive && cropBox.size.width > 2 || cropBox.size.height > 2 {
            self.layer?.addSublayer(selectionHandlers[0])
            self.layer?.addSublayer(selectionHandlers[1])
            self.layer?.addSublayer(selectionHandlers[2])
            self.layer?.addSublayer(selectionHandlers[3])
            }
            
        }
        
        updateCropBox()
        delegate?.imageViewDidChangeSelection(self)
        
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        
        selectionResizingIsActive = -1
        selectionMovingIsActive = false
        
        if selectionIsActive && cropBox.size.width < 2 || cropBox.size.height < 2 {
            clearCropBox()
        }
        
    }
    
    fileprivate func spanCropBox(_ startingPoint: NSPoint, endPoint: NSPoint) {
        
        let delta = NSMakeSize(abs(endPoint.x - startingPoint.x),
                               abs(endPoint.y - startingPoint.y))
        
        cropBox = NSMakeRect(   min(startingPoint.x, endPoint.x),
                                min(startingPoint.y, endPoint.y),
                                delta.width,
                                delta.height)
        
    }
    
    fileprivate func clearCropBox() {
        
        overlayBox.removeFromSuperlayer()
        selectionBox.removeFromSuperlayer()
        selectionHandlers[0].removeFromSuperlayer()
        selectionHandlers[1].removeFromSuperlayer()
        selectionHandlers[2].removeFromSuperlayer()
        selectionHandlers[3].removeFromSuperlayer()
        
        cropBox = NSZeroRect
        
        selectionIsActive = false
        
        delegate?.imageViewDidChangeSelection(self)
    
    }
    
    fileprivate func constraintCropBox() {
        
        cropBox.constraintToRect(imageFrame)
        
    }
    
    fileprivate func updateCropBox() {
        
        // constraintCropBox()
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: cropBox.origin.x, y: cropBox.origin.y))
        path.addLine(to: CGPoint(x: cropBox.origin.x, y: cropBox.origin.y + cropBox.size.height))
        path.addLine(to: CGPoint(x: cropBox.origin.x + cropBox.size.width, y: cropBox.origin.y + cropBox.size.height))
        path.addLine(to: CGPoint(x: cropBox.origin.x + cropBox.size.width, y: cropBox.origin.y))
        path.closeSubpath()
        selectionBox.path = path
        
        if selectionIsActive && cropBox.size.width > 2 || cropBox.size.height > 2 {
        let overlay = NSBezierPath(rect: imageFrame)
        let inner = NSBezierPath(rect: cropBox)
        overlay.append(inner)
        overlay.windingRule = .evenOdd
        overlayBox.path = overlay.CGPath
        }
        
        selectionHandlers[0].location = cropBox.bottomLeft()
        selectionHandlers[1].location = cropBox.bottomRight()
        selectionHandlers[2].location = cropBox.topRight()
        selectionHandlers[3].location = cropBox.topLeft()
        
    }
    
    fileprivate func mouseOnHandler(_ coordinate: NSPoint) -> Int {
        
        var i = 0
        for _ in selectionHandlers {
            if NSPointInRect(coordinate, selectionHandlers[i].location.bufferRect()) {
                return i
            }
            i = i+1
        }
        
        return -1
        
    }
    
    fileprivate func mouseOnCropBox(_ coordinate: NSPoint) -> Bool {
        
        if NSPointInRect(coordinate, cropBox) {
            return true
        }
        
        return false
        
    }
    
}

// MARK: Selection Box -

class SelectionBox: CAShapeLayer {
    
    @objc let dashAnimation = CABasicAnimation(keyPath: "lineDashPhase")
    
    override init() {
        
        super.init()
        
        self.lineWidth = 0.5
        self.lineJoin = CAShapeLayerLineJoin.round
        self.strokeColor = NSColor.black.cgColor
        self.fillColor = NSColor.clear.cgColor
        self.lineDashPattern = [5, 5]
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
    }
    
    @objc func initializeAnimation() {
        
        dashAnimation.fromValue = 10.0
        dashAnimation.toValue = 0.0
        dashAnimation.duration = 0.75
        dashAnimation.repeatCount = 100
        self.add(dashAnimation, forKey: "linePhase")
        
    }
    
}


// MARK: Overlay Box -

class OverlayBox: CAShapeLayer {
    
    override init() {
        
        super.init()
        
        self.fillColor = NSColor(calibratedWhite: 0.5, alpha: 0.8).cgColor
        self.fillRule = CAShapeLayerFillRule.evenOdd
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
    }
    
}

// MARK: Selection Handler -

class SelectionHandler: CAShapeLayer {
    
    @objc var location = NSZeroPoint {
        didSet {
            self.path = NSBezierPath(ovalIn: NSRect.handlerRectForPoint(location)).CGPath
        }
    }
    
    override init() {
        
        super.init()
        
        self.lineWidth = 2.0
        self.strokeColor = NSColor.white.cgColor
        self.fillColor = NSColor(calibratedRed: 0.1054, green: 0.4531, blue: 0.7929, alpha: 1.0).cgColor
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
    }

}
