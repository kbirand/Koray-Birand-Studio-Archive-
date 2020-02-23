//
//  NSImageView+Additions.swift
//  weborganizer
//
//  Created by Bruno Vandekerkhove on 26/04/16.
//  Copyright © 2016 Koray Birand. All rights reserved.
//

import Cocoa

// MARK: NSImageView Extension -
// From http://stackoverflow.com/questions/7929761/get-the-actual-display-image-size-on-nsimageview

extension NSImageView {
    
    func calculateImageSize() -> NSSize {
        
        if self.image != nil {
            
            let imageSize = self.image!.size
            let frameSize = self.frame.size
            
            switch self.imageScaling {
            case .scaleProportionallyUpOrDown:
                
                if imageSize.width > frameSize.width || imageSize.height > frameSize.height { // Width or height too big for frame (has priority)
                    let dx = frameSize.width / imageSize.width
                    let dy = frameSize.height / imageSize.height
                    let minDelta = min(dx, dy)
                    return NSMakeSize(imageSize.width * minDelta, imageSize.height * minDelta)
                    
                }
                else { // Width and height too small
                    
                    let dx = frameSize.width / imageSize.width
                    let dy = frameSize.height / imageSize.height
                    let minDelta = min(dx, dy)
                    
                    return NSMakeSize(imageSize.width * minDelta, imageSize.height * minDelta)
                    
                }
                
            case .scaleAxesIndependently:
                return frameSize // To be implemented
            case .scaleProportionallyDown:
                return frameSize  // To be implemented
            case .scaleNone:
                return frameSize
            @unknown default: break
                
            }
            
        }
        
        return NSZeroSize
        
    }
    
    func calculateImageFrame() -> NSRect {
        
        if self.image != nil {
            
            let imageSize = self.calculateImageSize()
            var innerRect = NSZeroRect
            innerRect.size = imageSize
                        
            return NSRectCenteredInsideRect(innerRect, outerRect:self.frame)
            
        }
        
        return NSZeroRect
        
    }
    
    fileprivate func NSRectCenteredInsideRect(_ inner: NSRect, outerRect: NSRect) -> NSRect  {
        
        return NSMakeRect((outerRect.size.width - inner.size.width) / 2.0,
                          (outerRect.size.height - inner.size.height) / 2.0,
                          inner.size.width,
                          inner.size.height);
        
    }
    
}
