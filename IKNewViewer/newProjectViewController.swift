//
//  newProjectViewController.swift
//  Koray Birand Studio Archive
//
//  Created by Koray Birand on 10.09.2018.
//  Copyright © 2018 Koray Birand. All rights reserved.
//

import Cocoa

extension URL {
    var isDirectory: Bool {
        return (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
    var subDirectories: [URL] {
        guard isDirectory else { return [] }
        return (try? FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]).filter{ $0.isDirectory }) ?? []
    }
}

class newProjectViewController: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet weak var projectNameTextField: NSTextField!
    @IBOutlet weak var projectPeriodtextField: NSTextField!
    
    //    var kbviewController: ViewController {
    //        get {
    //            return self.window!.contentViewController! as! ViewController
    //        }
    //    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        projectNameTextField.delegate = self
        projectPeriodtextField.delegate = self
        //view.window!.styleMask.remove(.resizable)
        
        // Do view setup here.
    }
    
    func controlTextDidChange(_ obj: Notification) {
        if obj.object as? NSTextField == self.projectPeriodtextField {
            let charSet = NSCharacterSet(charactersIn: "FWS0123456789-").inverted
            let chars = projectPeriodtextField.stringValue.components(separatedBy: charSet)
            projectPeriodtextField.stringValue = chars.joined()
        }
        if obj.object as? NSTextField == self.projectNameTextField {
            let charSet = NSCharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789-").inverted
            let chars = projectNameTextField.stringValue.components(separatedBy: charSet)
            projectNameTextField.stringValue = chars.joined()
        }
    }
    
    override func viewDidAppear() {
        // any additional code
        view.window!.styleMask.remove(.resizable)
    }
    
    @IBAction func newProjectPeriod(_ sender: Any) {
    }
    
    
    
    @IBAction func newProjectName(_ sender: Any) {
    }
    
    
    @IBAction func createProject(_ sender: Any) {
        if (projectNameTextField.stringValue != "" && projectPeriodtextField.stringValue != "") {
            
            let foldersArray : [URL] = archivePath.subDirectories
            let firstItem = (foldersArray.sorted(by: { $0.path > $1.path })).first
            var lastCounter : String!
            
            if foldersArray.count == 0 {
                lastCounter = "000000"
            } else {
                lastCounter = String(format: "%06d", (Int(((firstItem!.lastPathComponent).components(separatedBy: "_")).first!)! + 2))
            }
            
            let work = projectNameTextField.stringValue
            let period = projectPeriodtextField.stringValue
            
            let  newpath = String(lastCounter) + "_" + work + "_" + period
            
            try! db.run("INSERT INTO works (work,period,path,stylist,hair,makeup,talent) VALUES (?,?,?,?,?,?,?)", "\(projectNameTextField.stringValue)", "\(projectPeriodtextField.stringValue)",newpath,"","","","")
            
            try! FileManager.default.createDirectory(atPath: archivePath.appendingPathComponent(newpath).path, withIntermediateDirectories: true, attributes: nil)
            if searchFieldText == "" {
                let dataDict:[String: String] = ["array": "works","search":"false","function":"new"]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "initDBNotifty"), object: nil, userInfo: dataDict)
            } else {
                let dataDict:[String: String] = ["array": "works","search":"true","function":"new"]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "initDBNotifty"), object: nil, userInfo: dataDict)
            }
            self.dismiss(self)
        } else {
            printwithLog(log: "empty fields...")
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(self)
        
    }
    
    func createFolder() {
        
        
        
    }
    
}
