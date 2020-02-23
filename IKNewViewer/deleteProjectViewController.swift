//
//  deleteProjectViewController.swift
//  Koray Birand Studio Archive
//
//  Created by Koray Birand on 10.09.2018.
//  Copyright © 2018 Koray Birand. All rights reserved.
//

import Cocoa



class deleteProjectViewController: NSViewController {
    
    @IBOutlet weak var projectName: NSTextField!
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(self)
    }
    
    @IBAction func deleteProject(_ sender: Any) {
        if searchFieldText == "" {
            if selectedRow == -1 {
            } else {
                let myPath = archivePath.appendingPathComponent(worksData[selectedRow]["path"]!)
                let deletePath = archivePath.appendingPathComponent(worksData[selectedRow]["path"]!+"_removed")
                var textToBackup : String = worksData[selectedRow].keys.joined(separator: ";")
                textToBackup = textToBackup + "\n" + worksData[selectedRow].values.joined(separator: ";")
                try! db.run("DELETE FROM works WHERE id = \(worksData[selectedRow]["id"]!)")
                try! db.run("DELETE FROM files WHERE workid = \(worksData[selectedRow]["id"]!)")
                let dataDict:[String: String] = ["array": "works","search":"false","function":"delete"]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "initDBNotifty"), object: nil, userInfo: dataDict)
                try! FileManager.default.moveItem(atPath: myPath.path, toPath: deletePath.path)
                try! textToBackup.write(toFile: deletePath.appendingPathComponent("data.txt").path, atomically: false, encoding: .utf8)
                self.dismiss(self)
            }
        } else {
            if selectedRow == -1 {
            } else {
                if searchResultCount > 0 {
                    let myPath = archivePath.appendingPathComponent(filteredWorksData[selectedRow]["path"]!)
                    let deletePath = archivePath.appendingPathComponent(filteredWorksData[selectedRow]["path"]!+"_removed")
                    var textToBackup : String = filteredWorksData[selectedRow].keys.joined(separator: ";")
                    textToBackup = textToBackup + "\n" + filteredWorksData[selectedRow].values.joined(separator: ";")
                    try! db.run("DELETE FROM works WHERE id = \(filteredWorksData[selectedRow]["id"]!)")
                    try! db.run("DELETE FROM files WHERE workid = \(filteredWorksData[selectedRow]["id"]!)")
                    let dataDict:[String: String] = ["array": "filtered","search":"true","function":"delete"]
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "initDBNotifty"), object: nil, userInfo: dataDict)
                    try! FileManager.default.moveItem(atPath: myPath.path, toPath: deletePath.path)
                    try! textToBackup.write(toFile: deletePath.appendingPathComponent("data.txt").path, atomically: false, encoding: .utf8)
                    self.dismiss(self)
                } else {
                    printwithLog(log: "no result and no selection")
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.window!.styleMask.remove(.resizable)
        
    }
    
    override func viewWillAppear() {
        if searchFieldText == "" {
            projectName.stringValue = (worksData[selectedRow]["work"]!).uppercased()
        } else {
            projectName.stringValue = (filteredWorksData[selectedRow]["work"]!).uppercased()
        }
        // Do view setup here.
    }
    
    
    
}
