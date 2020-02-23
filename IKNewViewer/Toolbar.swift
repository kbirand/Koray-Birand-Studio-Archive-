//
//  Toolbar.swift
//  Koray Birand Studio Archive
//
//  Created by Koray Birand on 10.09.2018.
//  Copyright © 2018 Koray Birand. All rights reserved.
//

import Foundation
import Cocoa

extension ViewController {
    
    
    
    func addNewProject() {
        self.presentAsSheet(newProjectController)
    }
    
    func deleteProject() {
        if selectedRow == -1 {
            return
        }
        self.presentAsSheet(deleteProjectController)
        
    }
    
    
    func saveData() {
       
        if selectedRow == -1 {
            return
        }
       
        
        var myID : Int!
        let work = workField.stringValue
        let period = periodField.stringValue
        let stylist = stylistField.stringValue
        let hair = hairField.stringValue
        let makeup = makeupField.stringValue
        let talent = talentField.stringValue
        
        
        if searchFieldText == "" {
            myID = Int(worksData[selectedRow]["id"]!)
            worksData[selectedRow]["work"] = work
            worksData[selectedRow]["period"] = period
            worksData[selectedRow]["stylist"] = stylist
            worksData[selectedRow]["hair"] = hair
            worksData[selectedRow]["makeup"] = makeup
            worksData[selectedRow]["talent"] = talent
        } else {
            myID = Int(filteredWorksData[selectedRow]["id"]!)
            filteredWorksData[selectedRow]["work"] = work
            filteredWorksData[selectedRow]["period"] = period
            filteredWorksData[selectedRow]["stylist"] = stylist
            filteredWorksData[selectedRow]["hair"] = hair
            filteredWorksData[selectedRow]["makeup"] = makeup
            filteredWorksData[selectedRow]["talent"] = talent
        }
        
       
        
       
        try! db.run("UPDATE works SET work = (?), period = (?), stylist = (?), hair = (?), makeup = (?), talent = (?) WHERE id = (?)", work,period,stylist,hair,makeup,talent,myID)
        self.presentAsSheet(updatedController)
        
    }
    
    func addPhoto() {
        if selectedRow == -1 {
            return
        }
        let urls:NSArray? = openFiles()
        
        if urls == nil {
            return
        }
        
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            self.addImagesWithPaths(urls!)
            DispatchQueue.main.async(execute: { () -> Void in
            })
        })
    }
    
    func exportPhoto() {
        print("export photo")
    }
    
}
