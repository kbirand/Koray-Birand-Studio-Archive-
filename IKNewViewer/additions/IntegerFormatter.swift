//
//  IntegerFormatter.swift
//  weborganizer
//
//  Created by Bruno Vandekerkhove on 26/04/16.
//  Copyright © 2016 Koray Birand. All rights reserved.
//

import Cocoa
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


// MARK: Integer Formatter -

class IntegerFormatter: NumberFormatter {
    
    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
        if partialString.count > 0 {
            
            if  !(partialString.isNumeric())
                || (partialString as NSString).longLongValue > (self.maximum?.int64Value)!
                || (partialString as NSString).longLongValue < (self.minimum?.int64Value)! {
                return false
            }
            
        }
        
        return true
        
    }

}
