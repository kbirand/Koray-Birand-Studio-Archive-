//
//  Foundation+Additions.swift
//  weborganizer
//
//  Created by Bruno Vandekerkhove on 26/04/16.
//  Copyright © 2016 Koray Birand. All rights reserved.
//

import Foundation

// MARK: NSRect Extension -

extension NSRect {
    
    func bottomLeft() -> NSPoint {
        return NSMakePoint(self.origin.x, self.origin.y)
    }
    
    func bottomRight() -> NSPoint {
        return NSMakePoint(self.origin.x + self.size.width, self.origin.y)
    }
    
    func topRight() -> NSPoint {
        return NSMakePoint(self.origin.x + self.size.width, self.origin.y + self.size.height)
    }
    
    func topLeft() -> NSPoint {
        return NSMakePoint(self.origin.x, self.origin.y + self.size.height)
    }
    
    static func handlerRectForPoint(_ point: NSPoint) -> NSRect {
        
        let size = CGFloat(8.5)
        return NSMakeRect(point.x - size/2, point.y - size/2, size, size)
        
    }
    
    mutating func constraintToSize(_ size: NSSize) {
        
        var rect = NSZeroRect
        rect.size = size
        self.constraintToRect(rect)
        
    }
    
    mutating func constraintToRect(_ rect: NSRect) {
        
        var topright = NSMakePoint(self.origin.x + self.size.width, self.origin.y + self.size.height)
        topright.constraintToRect(rect)
        self.origin.constraintToRect(rect)
        self.size = NSMakeSize(topright.x - self.origin.x, topright.y - self.origin.y)
        
    }
    
    mutating func moveBy(_ dx: CGFloat, dy: CGFloat) {
        
        self.origin.x += dx
        self.origin.y += dy
        
    }
    
    mutating func moveBy(_ dx: CGFloat, dy: CGFloat, inFrame frame: NSRect) {
        
        var newOrigin = self.origin
        newOrigin.x += dx
        newOrigin.y += dy
        newOrigin.constraintToRect(frame)
        
        if newOrigin.x + self.size.width > frame.origin.x + frame.size.width {
            newOrigin.x = frame.origin.x + frame.size.width - self.size.width
        }
        
        if newOrigin.y + self.size.height > frame.origin.y + frame.size.height {
            newOrigin.y = frame.origin.y + frame.size.height - self.size.height
        }
        
        self.origin = newOrigin
        
    }
    
    func ratioOfFrame(_ frame: NSRect) -> NSRect {
        
        var innerRect = self
        innerRect.constraintToRect(frame)
        innerRect.origin.x -= frame.origin.x
        innerRect.origin.y -= frame.origin.y
        
        return NSMakeRect(innerRect.origin.x / frame.size.width,
                          innerRect.origin.y / frame.size.height,
                          innerRect.size.width / frame.size.width,
                          innerRect.size.height / frame.size.height)
        
    }
    
}

// MARK: NSPoint Extension -

extension NSPoint {
    
    mutating func constraintToSize(_ size: NSSize) {
        
        var rect = NSZeroRect
        rect.size = size
        self.constraintToRect(rect)
        
    }
    
    mutating func constraintToRect(_ rect: NSRect) {
        
        if self.x > rect.origin.x + rect.size.width {
            self.x = rect.origin.x + rect.size.width
        }
        if self.y > rect.origin.y + rect.size.height {
            self.y = rect.origin.y + rect.size.height
        }
        if self.x < rect.origin.x {
            self.x = rect.origin.x
        }
        if self.y < rect.origin.y {
            self.y = rect.origin.y
        }
        
    }
    
    func bufferRect(_ size: Float?=nil) -> NSRect {
        
        var bufferSize = CGFloat(8.5)
        if size != nil {
            bufferSize = CGFloat(size!)
        }
        
        return NSMakeRect(self.x - bufferSize/2, self.y - bufferSize/2, bufferSize, bufferSize)
    
    }
    
}

// MARK: Float Extension -

extension Float  {
    
    mutating func roundToPlaces(_ places:Int) -> Float {
        let divisor = pow(10.0, Double(places))
        return Float((Double(self) * divisor).rounded() / divisor)
    }
    
}

// MARK: Double Extension -

extension Double {

    mutating func roundToPlaces(_ places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
}
