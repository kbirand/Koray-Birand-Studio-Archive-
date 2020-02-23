//
//  String+Additions.swift
//  weborganizer
//
//  Created by Bruno Vandekerkhove on 26/04/16.
//  Copyright © 2016 Koray Birand. All rights reserved.
//

import Cocoa

// MARK: NSString Extension -

extension NSString {
    
    func isNumeric() -> Bool {
        
        return removeNumeric().length == 0
        
    }
    
    fileprivate func removeNumeric() -> NSString {
        
        let charactersToRemove = CharacterSet.decimalDigits
        return self.components(separatedBy: charactersToRemove).joined(separator: "") as NSString
        
    }
    
}
