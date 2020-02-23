//
//  updatedViewController.swift
//  Koray Birand Studio Archive
//
//  Created by Koray Birand on 9/15/18.
//  Copyright © 2018 Koray Birand. All rights reserved.
//

import Cocoa

class updatedViewController: NSViewController {
    @IBOutlet weak var projectNameField: NSTextField!
    
    @IBAction func okButton(_ sender: Any) {
    self.dismiss(self)
    
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.window!.styleMask.remove(.resizable)
       

        // Do view setup here.
    }
    
    override func viewWillAppear() {
        if searchFieldText == "" {
            projectNameField.stringValue = (worksData[selectedRow]["work"]?.uppercased())!
            
        } else {
            projectNameField.stringValue = (filteredWorksData[selectedRow]["work"]?.uppercased())!
        }
    }
    
}
