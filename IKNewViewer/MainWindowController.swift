//
//  MainWindowController.swift
//  collectionViewZoomOutAndInProfessional
//
//  Created by sycf_ios on 2017/12/25.
//  Copyright © 2017年 sycf_ios. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {

    
    var kbviewController: ViewController {
        get {
            //return self.window!.contentViewController! as! ViewController
            
            return self.window?.contentViewController?.children[1] as! ViewController
        }
    }
    
    
    @IBAction func newProject(_ sender: Any) {
        kbviewController.addNewProject()
    }
    
    @IBAction func deleteProject(_ sender: Any) {
        kbviewController.deleteProject()
    }
    
    @IBAction func addFavorite(_ sender: Any) {
         NotificationCenter.default.post(name: Notification.Name(rawValue: "collapseFavs"), object: nil )
        //kbviewController.addTofavorite()
    }
    
    @IBAction func addPhoto(_ sender: Any) {
        kbviewController.addPhoto()
    }
    
    @IBAction func saveData(_ sender: Any) {
        kbviewController.saveData()
    }
    
    
    @IBAction func exportImage(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "collapseEdit"), object: nil )
//        kbviewController.exportPhoto()
    }
    
//    @IBAction func settings(_ sender: Any) {
//        kbviewController.settings()
//    }
    
    
    
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.windowFrameAutosaveName = "position"
        //self.window!.titleVisibility = NSWindow.TitleVisibility.hidden
//        window?.center()
//        window?.isRestorable = false
//        window?.isMovableByWindowBackground = true
//        window?.delegate = self
//        updateTitleBarOfWindow(window: window!, fullScreen: false)
    }
    
    
    func updateTitleBarOfWindow(window: NSWindow, fullScreen: Bool) {
        let kTitlebarHeight: CGFloat = 54.0
        let kFullScreenButtonYOrigin: CGFloat = 3.0
        let windowFrame = window.frame
        let titlebarContainerView = window.standardWindowButton(.closeButton)?.superview?.superview;
        var titlebarContainerFrame = titlebarContainerView?.frame
        titlebarContainerFrame?.origin.y = windowFrame.size.height - kTitlebarHeight
        titlebarContainerFrame?.size.height = CGFloat(kTitlebarHeight)
        titlebarContainerView?.frame = titlebarContainerFrame!
        
        var buttonX:CGFloat = 12.0
        let closeButton = window.standardWindowButton(.closeButton)
        let minimizeButton = window.standardWindowButton(.miniaturizeButton)
        let zoomButton = window.standardWindowButton(.zoomButton)
        
        for buttonView in [closeButton,minimizeButton,zoomButton] {
            var btnFrame = buttonView?.frame
            let tempHeight = round(kTitlebarHeight - (btnFrame?.size.height)!)
            btnFrame?.origin.y = fullScreen ? kFullScreenButtonYOrigin :  tempHeight / 2.0
            btnFrame?.origin.x = CGFloat(buttonX)
            buttonX = (btnFrame?.size.width)! + 6 + buttonX
            
            buttonView?.setFrameOrigin((btnFrame?.origin)!)
        }
        
        
    }
}
extension MainWindowController: NSWindowDelegate {
//    func windowDidEnterFullScreen(_ notification: Notification) {
//        updateTitleBarOfWindow(window: window!, fullScreen: true)
//    }
//    func windowDidExitFullScreen(_ notification: Notification) {
//        updateTitleBarOfWindow(window: window!, fullScreen: false)
//    }
//    func windowDidResize(_ notification: Notification) {
//        updateTitleBarOfWindow(window: window!, fullScreen: false)
//    }
}
