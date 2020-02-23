//
//  myNSSplitViewController.swift
//  slide
//
//  Created by Koray Birand on 16.09.2018.
//  Copyright © 2018 Koray Birand. All rights reserved.
//

import Cocoa




class myNSSplitViewController: NSSplitViewController, ImageViewDelegate {
    func imageViewDidChangeImage(_ imageView: ImageView) {
        
    }
    
    func imageViewDidChangeSelection(_ imageView: ImageView) {
        
    }
    
    
    @IBOutlet weak var mySplitView: NSSplitView!
    @IBOutlet weak var itemOne: NSSplitViewItem!
    @IBOutlet weak var itemThree: NSSplitViewItem!

    
    override func viewWillAppear() {
        itemOne.isCollapsed = true
        itemThree.isCollapsed = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mySplitView.setPosition(250, ofDividerAt: 0)
        createObservers()
    }

    
    func createObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(myNSSplitViewController.collapseFavs), name: Notification.Name(rawValue: "collapseFavs"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(myNSSplitViewController.collapseEdit), name: Notification.Name(rawValue: "collapseEdit"), object: nil)
    }
    
    @objc func collapseFavs()  {
        if itemOne.isCollapsed {
            itemOne.animator().isCollapsed = false
        } else {
            itemOne.animator().isCollapsed = true
        }
    }
    
    @objc func collapseEdit()  {
        if itemThree.isCollapsed {
            itemThree.animator().isCollapsed = false
        } else {
            itemThree.animator().isCollapsed = true
        }
    }
    

    
    
    override func splitView(_ splitView: NSSplitView, effectiveRect proposedEffectiveRect: NSRect, forDrawnRect drawnRect: NSRect, ofDividerAt dividerIndex: Int) -> NSRect {
        if dividerIndex == 0 {
            return NSZeroRect
        } else {
            return NSRect(x: proposedEffectiveRect.origin.x, y: proposedEffectiveRect.origin.y, width: proposedEffectiveRect.size.width, height: proposedEffectiveRect.size.height)
        }
    }
    
}
