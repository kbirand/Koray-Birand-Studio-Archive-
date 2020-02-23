//
//  AppDelegate.swift
//  IKNewViewer
//
//  Created by Koray Birand on 9/9/18.
//  Copyright © 2018 Koray Birand. All rights reserved.
//

import Cocoa



@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
   
    
    @IBAction func preferences(_ sender: Any) {

        
        
    }
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
       
        if UserDefaults.standard.object(forKey: "weTransferApi") == nil {
            UserDefaults.standard.set("", forKey: "weTransferApi")
            weTransferApiKey = ""
        } else {
            weTransferApiKey = UserDefaults.standard.string(forKey: "weTransferApi")
        }
        
        if UserDefaults.standard.object(forKey: "saveJPEG") == nil {
            UserDefaults.standard.set(1, forKey: "saveJPEG")
            printwithLog(log: "saveJPEG Nil")
            saveJPEG = 1
        } else {
            saveJPEG = UserDefaults.standard.integer(forKey: "saveJPEG")
        }
        
        if UserDefaults.standard.object(forKey: "colorProfile") == nil {
            UserDefaults.standard.set(1, forKey: "colorProfile")
            printwithLog(log: "colorProfile Nil")
            colorProfile = 1
        } else {
            colorProfile = UserDefaults.standard.integer(forKey: "colorProfile")
        }
        
        if UserDefaults.standard.object(forKey: "resizeToFit") == nil {
            UserDefaults.standard.set(1, forKey: "resizeToFit")
            printwithLog(log: "resizeToFit Nil")
            resizeToFit = 1
        } else {
            resizeToFit = UserDefaults.standard.integer(forKey: "resizeToFit")
        }
        
        if UserDefaults.standard.object(forKey: "maxWidth") == nil {
            UserDefaults.standard.set(15000, forKey: "maxWidth")
            printwithLog(log: "mW Nil")
            maxWidth = 1500
        } else {
            maxWidth = UserDefaults.standard.integer(forKey: "maxWidth")
        }
        
        if UserDefaults.standard.object(forKey: "maxHeight") == nil {
            UserDefaults.standard.set(1500, forKey: "maxHeight")
            maxHeight = 1500
            printwithLog(log: "mH Nil")
        } else {
            maxHeight = UserDefaults.standard.integer(forKey: "maxHeight")
        }
        
        if UserDefaults.standard.object(forKey: "compression") == nil {
            UserDefaults.standard.set(0.7, forKey: "compression")
            compressionValue = 0.7
            printwithLog(log: "cP Nil")
        } else {
            compressionValue = UserDefaults.standard.double(forKey: "compression")
        }
        
        if UserDefaults.standard.object(forKey: "cropHeight") == nil {
            UserDefaults.standard.set(900, forKey: "cropHeight")
            cropHeight = 1500
            printwithLog(log: "cH Nil")
        } else {
            cropHeight = UserDefaults.standard.integer(forKey: "cropHeight")
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
}


