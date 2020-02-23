//
//  settingsViewController.swift
//  Koray Birand Studio Archive
//
//  Created by Koray Birand on 9/15/18.
//  Copyright © 2018 Koray Birand. All rights reserved.
//

import Cocoa

class settingsViewController: NSViewController,NSTextFieldDelegate {
    
    @IBOutlet weak var archiveFolderField: NSTextField!
    @IBOutlet weak var dbFileField: NSTextField!
    @IBOutlet weak var saveAsJPEG: NSButton!
    @IBOutlet weak var convertToProfile: NSButton!
    @IBOutlet weak var resizeToFitButton: NSButton!
    @IBOutlet weak var resizeWidth: NSTextField!
    @IBOutlet weak var resizeHeight: NSTextField!
    @IBOutlet weak var compression: NSSlider!
    @IBOutlet weak var weTransferApi: NSTextField!
    
    var newPath : URL!
    var newDbFile : URL!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.window!.styleMask.remove(.resizable)
        resizeWidth.delegate = self
        resizeHeight.delegate = self
        
        weTransferApi.stringValue = UserDefaults.standard.string(forKey: "weTransferApi")!
        resizeHeight.stringValue = String(UserDefaults.standard.integer(forKey: "maxHeight"))
        resizeWidth.stringValue = String(UserDefaults.standard.integer(forKey: "maxWidth"))
        compression.doubleValue = UserDefaults.standard.double(forKey: "compression") * 10.0
        resizeToFitButton.state = NSControl.StateValue(rawValue: UserDefaults.standard.integer(forKey: "resizeToFit"))
        convertToProfile.state = NSControl.StateValue(rawValue: UserDefaults.standard.integer(forKey: "colorProfile"))
        saveAsJPEG.state = NSControl.StateValue(rawValue: UserDefaults.standard.integer(forKey: "saveJPEG"))
        
        // Do view setup here.
    }
    
    override func viewWillAppear() {
        archiveFolderField.stringValue = archivePath.path
        dbFileField.stringValue = dbFile
    }
    
    
    
    @IBAction func setPaths(_ sender: Any) {
        if newDbFile == nil {
            UserDefaults.standard.set(URL(fileURLWithPath: dbFileField.stringValue), forKey: "dbFile")
        } else {
            UserDefaults.standard.set(newDbFile, forKey: "dbFile")
        }
        
        if newPath == nil {
            UserDefaults.standard.set(URL(fileURLWithPath: archiveFolderField.stringValue), forKey: "archivePath")
        } else {
            UserDefaults.standard.set(newPath, forKey: "archivePath")
        }
        
        let mW = Int(resizeWidth.stringValue)
        let mH = Int(resizeHeight.stringValue)
        let comp : Double = compression.doubleValue / 10.0
        let rTF : Int = resizeToFitButton.state.rawValue
        let cP : Int = convertToProfile.state.rawValue
        let sJ : Int = saveAsJPEG.state.rawValue
        let wApi : String = weTransferApi.stringValue
        UserDefaults.standard.set(mW, forKey: "maxWidth")
        UserDefaults.standard.set(mH, forKey: "maxHeight")
        UserDefaults.standard.set(comp, forKey: "compression")
        UserDefaults.standard.set(mH, forKey: "cropHeight")
        UserDefaults.standard.set(rTF, forKey: "resizeToFit")
        UserDefaults.standard.set(cP, forKey: "colorProfile")
        UserDefaults.standard.set(sJ, forKey: "saveJPEG")
        UserDefaults.standard.set(wApi, forKey: "weTransferApi")
        maxWidth = Int(resizeWidth.stringValue)
        maxHeight = Int(resizeHeight.stringValue)
        compressionValue = compression.doubleValue / 10.0
        cropHeight = Int(resizeHeight.stringValue)
        resizeToFit = resizeToFitButton.state.rawValue
        colorProfile = convertToProfile.state.rawValue
        saveJPEG = saveAsJPEG.state.rawValue
       
        self.dismiss(self)
        
    }
    
    
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(self)
    }
    
    @IBAction func selectArchivePath(_ sender: Any) {
        newPath = koray.folderPanel()
        archiveFolderField.stringValue = newPath.path
        
    }
    
    @IBAction func selectDbFile(_ sender: Any) {
        newDbFile = koray.loadFile()
        dbFileField.stringValue = newDbFile.path
    }
    
}
