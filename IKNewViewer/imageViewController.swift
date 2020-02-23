//
//  imageViewController.swift
//  Koray Birand Studio Archive
//
//  Created by Koray Birand on 18.09.2018.
//  Copyright © 2018 Koray Birand. All rights reserved.
//

import Cocoa

var maxHeight : Int!
var maxWidth : Int!
var cropHeight: Int!
var compressionValue : Double!
var resizeToFit : Int!
var colorProfile : Int!
var saveJPEG: Int!

extension imageViewController : ImageViewDelegate {
    func imageViewDidChangeImage(_ imageView: ImageView) {
        
    }
    
    func imageViewDidChangeSelection(_ imageView: ImageView) {
        
    }
    
}



class imageViewController: NSViewController {
    
    @IBOutlet weak var imageView: ImageView!
    @IBOutlet var myView: NSView!
    @IBOutlet weak var fileNameField: NSTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.imageFrameStyle = .none
        createObservers()

        imageView.layer?.borderColor = CGColor(gray: 1, alpha: 0)
        NotificationCenter.default.addObserver(imageView!, selector: #selector(ImageView.windowWillResize), name: NSView.frameDidChangeNotification, object: myView)
        NotificationCenter.default.addObserver(imageView!, selector: #selector(ImageView.windowDidResize), name: NSView.frameDidChangeNotification, object: myView)

        
   }
    
    override func viewWillLayout() {
    

    }
    
    func createObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(imageViewController.changeImage), name: Notification.Name(rawValue: "changeImage"), object: nil)
    }
    
    @objc func changeImage(_ notification: NSNotification) {
        let dict = notification.userInfo! as NSDictionary
        let imagePath = dict["path"] as! String
        imageView.image = NSImage(contentsOfFile:imagePath)
        
    }
    

    @IBAction func exportCropped(_ sender: Any) {
        
        if (imageView.cropBox.size.height.isNaN) ||  (imageView.cropBox.size.height == 0.0) {
             return
        }
        
        let a = (imageView.selectionSize()?.width)!
        let b = (imageView.selectionSize()?.height)!
        let xFactor = NSScreen.main?.backingScaleFactor
        var croppedSize = NSMakeSize(0, 0)

        if b > a {
            let ratio = b / a
            croppedSize = NSMakeSize(CGFloat(CGFloat(maxHeight)/ratio)/xFactor!, CGFloat(maxHeight)/xFactor! )
        } else if a > b {
            let ratio = a / b
            croppedSize = NSMakeSize(CGFloat(maxWidth)/xFactor!, CGFloat(CGFloat(maxWidth)/ratio)/xFactor!)
        } else if a == b {
            croppedSize = NSMakeSize(CGFloat(maxHeight)/xFactor!, CGFloat(maxHeight)/xFactor! )
        }
        
    
        
        let destinationFile = koray.saveToFolder()
        
        if let data = imageView.croppedImageData(croppedSize, compression: Float(compressionValue)) {
            
            try? data.write(to: URL(fileURLWithPath: destinationFile.path), options: NSData.WritingOptions.atomic)
        }
        
    }
    
    
    
    
}
