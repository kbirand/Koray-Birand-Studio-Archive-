//  Extensions.swift
//  ModifyDate
//
//  Created by Koray Birand on 19.08.2018.
//  Copyright © 2018 Koray Birand. All rights reserved.
//

var mainId = ""
var mainPath = ""

import Cocoa

extension ViewController:NSTableViewDataSource, NSTableViewDelegate,NSTextFieldDelegate,NSSearchFieldDelegate,NSWindowDelegate{
    
    //    NSDraggingDestination
    //    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
    //
    //        return NSDragOperation.link
    //    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if searchField.stringValue.count > 0 {
            recordCount.stringValue = "Number of \(filteredWorksData.count) Record(s) Found"
            return filteredWorksData.count
        } else {
            recordCount.stringValue = "Number of \(worksData.count) Record(s) Found"
            return worksData.count
        }
        
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        NSApplication.shared.terminate(self)
        return true
        
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        selectedRow = tableView.selectedRow
        let koko = tableView.selectedRow
        if searchField.stringValue.count > 0 {
            if koko > -1 {
                pathField.stringValue = filteredWorksData[koko]["path"]!
                stylistField.stringValue = filteredWorksData[koko]["stylist"]!
                hairField.stringValue = filteredWorksData[koko]["hair"]!
                makeupField.stringValue = filteredWorksData[koko]["makeup"]!
                talentField.stringValue = filteredWorksData[koko]["talent"]!
                workField.stringValue = filteredWorksData[koko]["work"]!
                periodField.stringValue = filteredWorksData[koko]["period"]!
                getFiles(id: filteredWorksData[koko]["id"]!, path: filteredWorksData[koko]["path"]!)
                mainId = filteredWorksData[koko]["id"]!
                mainPath = filteredWorksData[koko]["path"]!
                
                print(mainPath)
                print(mainId)
                
                let dataDict:[String: String] = ["path": "","filename":""]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "changeImage"), object: nil, userInfo: dataDict)
                
                //updateDatasource()
                
            } else {
                pathField.stringValue = ""
                stylistField.stringValue = ""
                hairField.stringValue = ""
                makeupField.stringValue = ""
                talentField.stringValue = ""
                pathField.stringValue = ""
                workField.stringValue = ""
                periodField.stringValue = ""
                
                let dataDict:[String: String] = ["path": "","filename":""]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "changeImage"), object: nil, userInfo: dataDict)
            }
            
        } else {
            if koko > -1 {
                pathField.stringValue = worksData[koko]["path"]!
                stylistField.stringValue = worksData[koko]["stylist"]!
                hairField.stringValue = worksData[koko]["hair"]!
                makeupField.stringValue = worksData[koko]["makeup"]!
                talentField.stringValue = worksData[koko]["talent"]!
                workField.stringValue = worksData[koko]["work"]!
                periodField.stringValue = worksData[koko]["period"]!
                
                let dataDict:[String: String] = ["path": "","filename":""]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "changeImage"), object: nil, userInfo: dataDict)
                mainId = worksData[koko]["id"]!
                mainPath = worksData[koko]["path"]!
                print(mainPath)
                print(mainId)
                getFiles(id: worksData[koko]["id"]!, path: worksData[koko]["path"]!)
                //updateDatasource()
            } else {
                pathField.stringValue = ""
                stylistField.stringValue = ""
                hairField.stringValue = ""
                makeupField.stringValue = ""
                talentField.stringValue = ""
                pathField.stringValue = ""
                workField.stringValue = ""
                periodField.stringValue = ""
                
                let dataDict:[String: String] = ["path": "","filename":""]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "changeImage"), object: nil, userInfo: dataDict)
                
                updateDatasource()
                images.removeAllObjects()
                imageBrowser.reloadData()
            }
            
        }
        
    }
    
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        pathField.stringValue = ""
        stylistField.stringValue = ""
        hairField.stringValue = ""
        makeupField.stringValue = ""
        talentField.stringValue = ""
        pathField.stringValue = ""
        workField.stringValue = ""
        
        let dataDict:[String: String] = ["path": "","filename":""]
        NotificationCenter.default.post(name: Notification.Name(rawValue: "changeImage"), object: nil, userInfo: dataDict)
        
        images.removeAllObjects()
        updateDatasource()
        tableView.reloadData()
        tableView.selectRowIndexes(.init(integer: 0 ), byExtendingSelection: false)
        
        imageBrowser.scrollIndexToVisible(0)
        tableView.becomeFirstResponder()
    }
    
    func controlTextDidChange(_ obj: Notification) {
        //let characterSet: NSCharacterSet = NSCharacterSet(charactersInString: " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789-'").invertedSet
        if obj.object as? NSSearchField == self.searchField {
            
            let searchString = self.searchField.stringValue
            searchFieldText = searchString
            if searchString != "" {
                selectedRow = -1
                filteredWorksData.removeAll()
                let searchPredicate = NSPredicate(format: "work CONTAINS[cd] %@ or hair CONTAINS[cd] %@ or makeup CONTAINS[cd] %@ or stylist CONTAINS[cd] %@ or talent CONTAINS[cd] %@", searchString,searchString,searchString,searchString,searchString)
                let array = (worksData as NSArray).filtered(using: searchPredicate)
                filteredWorksData = array as! [[String:String]]
                searchResultCount = filteredWorksData.count
                images.removeAllObjects()
                updateDatasource()
                tableView.reloadData()
            }
        }
        
        if obj.object as? NSTextField == self.workField {
            let charSet = NSCharacterSet(charactersIn: " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789-'").inverted
            let chars = workField.stringValue.components(separatedBy: charSet)
            workField.stringValue = chars.joined()
        }
        
        if obj.object as? NSTextField == self.periodField {
            let charSet = NSCharacterSet(charactersIn: "FWS0123456789-").inverted
            let chars = periodField.stringValue.components(separatedBy: charSet)
            periodField.stringValue = chars.joined()
        }
        
        if obj.object as? NSTextField == self.stylistField {
            let charSet = NSCharacterSet(charactersIn: " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ-'").inverted
            let chars = stylistField.stringValue.components(separatedBy: charSet)
            stylistField.stringValue = chars.joined()
        }
        
        if obj.object as? NSTextField == self.hairField {
            let charSet = NSCharacterSet(charactersIn: " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ-'").inverted
            let chars = hairField.stringValue.components(separatedBy: charSet)
            hairField.stringValue = chars.joined()
        }
        
        if obj.object as? NSTextField == self.makeupField {
            let charSet = NSCharacterSet(charactersIn: " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ-'").inverted
            let chars = makeupField.stringValue.components(separatedBy: charSet)
            makeupField.stringValue = chars.joined()
        }
        
        if obj.object as? NSTextField == self.talentField {
            let charSet = NSCharacterSet(charactersIn: " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ-'").inverted
            let chars = talentField.stringValue.components(separatedBy: charSet)
            talentField.stringValue = chars.joined()
        }
    }
    
    
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?{
        
        let result  = tableView.makeView(withIdentifier: (tableColumn?.identifier)!, owner: self) as! NSTableCellView
        
        if searchField.stringValue.count > 0 {
            
            if (tableColumn?.identifier.rawValue)! == "work" {
                result.textField?.stringValue = filteredWorksData[row][(tableColumn?.identifier.rawValue)!]! + " " + filteredWorksData[row]["period"]!
            } else {
                result.textField?.stringValue = (filteredWorksData[row][(tableColumn?.identifier.rawValue)!]!)
            }
            return result
            
        } else {
            
            if (tableColumn?.identifier.rawValue)! == "work" {
                result.textField?.stringValue = worksData[row][(tableColumn?.identifier.rawValue)!]! + " " + worksData[row]["period"]!
            } else {
                result.textField?.stringValue = (worksData[row][(tableColumn?.identifier.rawValue)!]!)
            }
            return result
            
        }
        
    }
    
}

