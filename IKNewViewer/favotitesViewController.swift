//
//  favotitesViewController.swift
//  Koray Birand Studio Archive
//
//  Created by Koray Birand on 9/21/18.
//  Copyright © 2018 Koray Birand. All rights reserved.
//

extension Array {
    
    mutating func remove(at indexes : IndexSet) {
        guard var i = indexes.first, i < count else { return }
        var j = index(after: i)
        var k = indexes.integerGreaterThan(i) ?? endIndex
        while j != endIndex {
            if k != j { swapAt(i, j); formIndex(after: &i) }
            else { k = indexes.integerGreaterThan(k) ?? endIndex }
            formIndex(after: &j)
        }
        removeSubrange(i...)
    }
}

import Cocoa


class favotitesViewController: NSViewController, NSTableViewDelegate,NSTableViewDataSource {
    
    @IBOutlet weak var myTableView: NSTableView!
    
    override func viewDidLoad() {
        if UserDefaults.standard.array(forKey: "favorites") != nil {
            favoritesData = UserDefaults.standard.array(forKey: "favorites") as! [[String : String]]
        }
        myTableView.delegate = self
        myTableView.dataSource = self
        super.viewDidLoad()
        UserDefaults.standard.dictionary(forKey: "favorites")
        // Do view setup here.
    }
    
    @IBAction func addSelected(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "favoriteSelected"), object: nil)
        myTableView.reloadData()
        
    }
    
    @IBAction func addAllSelected(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "favoriteAllSelected"), object: nil)
        myTableView.reloadData()
        
    }
    
    @IBAction func removeSelected(_ sender: Any) {
        
        favoritesData.remove(at: myTableView.selectedRowIndexes)
        UserDefaults.standard.set(favoritesData as NSArray, forKey: "favorites")
        myTableView.reloadData()
    }
    
    @IBAction func export(_ sender: Any) {
        if favoritesData.count > 0 {
            let exportToFolder : URL = koray.exportFolder()
            for items in favoritesData {
                let fromFolder = archivePath.appendingPathComponent(items["path"]!, isDirectory: true)
                let newFolder = exportToFolder.appendingPathComponent(items["path"]!, isDirectory: true)
                if !FileManager.default.fileExists(atPath: newFolder.path) {
                    try! FileManager.default.createDirectory(atPath: newFolder.path, withIntermediateDirectories: true, attributes: nil)
                }
                
                    let myFolders : [URL] = try! FileManager.default.contentsOfDirectory(at: fromFolder, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                    
                    for file in myFolders {
                        let fileExtension = file.pathExtension
                        let fileUTI:Unmanaged<CFString>! = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)
                        let isImage = UTTypeConformsTo(fileUTI.takeUnretainedValue(), kUTTypeImage)
                        
                        if (isImage == true) {
                            if !FileManager.default.fileExists(atPath: newFolder.appendingPathComponent("\(file.lastPathComponent)").path) {
                            try! FileManager.default.copyItem(at: file, to: newFolder.appendingPathComponent("\(file.lastPathComponent)"))
                            }
                        }
                    }
                    
                    var textToBackup : String = items.keys.joined(separator: ";")
                    textToBackup = textToBackup + "\n" + items.values.joined(separator: ";")
                    try! textToBackup.write(toFile: newFolder.appendingPathComponent("data.txt").path, atomically: false, encoding: .utf8)
    
            }
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if myTableView.selectedRow != -1 {
        let id : String = favoritesData[myTableView.selectedRow]["id"]!
        let path : String = favoritesData[myTableView.selectedRow]["path"]!
            let dataDict:[String: String] = ["id": "\(id)","search":"false","path":"\(path)","indexPath":"\(myTableView.selectedRow)"]
        NotificationCenter.default.post(name: Notification.Name(rawValue: "favoriteImages"), object: nil, userInfo: dataDict)
        }
        
    }
    
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?{
        
        let result  = tableView.makeView(withIdentifier: (tableColumn?.identifier)!, owner: self) as! NSTableCellView
        
        
        
        if (tableColumn?.identifier.rawValue)! == "work" {
            result.textField?.stringValue = favoritesData[row][(tableColumn?.identifier.rawValue)!]! + " " + favoritesData[row]["period"]!
        }
        
        
        
        return result
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        return favoritesData.count
        
    }
    
    
}
