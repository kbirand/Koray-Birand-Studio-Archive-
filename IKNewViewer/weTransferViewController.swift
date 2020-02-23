//
//  weTransferViewController.swift
//  Koray Birand Studio Archive
//
//  Created by Koray Birand on 9/24/18.
//  Copyright © 2018 Koray Birand. All rights reserved.
//

import Cocoa
import WeTransfer

var weTransferApiKey : String!

class weTransferViewController: NSViewController {

    private enum ViewState {
        case ready
        case selectedMedia
        case startedTransfer
        case transferInProgress
        case failed(error: Error)
        case transferCompleted(shortURL: URL)
    }
    
    @IBOutlet weak var progressView: NSProgressIndicator!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var uploadButton: NSButton!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var dismissedButton: NSButton!
    
    private var progressObservation: NSKeyValueObservation?
    var wetransferURL = ""
    
    private var viewState: ViewState = .ready {
        didSet {
            updateInterface()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWeTransfer()
       
        
    }
    
    override func viewWillAppear() {
        if selectedImages.count == 1 {
            titleLabel.stringValue = "\((selectedImages.first)?.lastPathComponent ?? "") is ready to upload"
        } else {
            titleLabel.stringValue = "\(selectedImages.count) files are ready to upload"
        }
        
        uploadButton.isEnabled = true
        cancelButton.isEnabled = true
        uploadButton.isHidden = false
        cancelButton.isHidden = false
        dismissedButton.isHidden = true
        dismissedButton.isEnabled = false
        progressView.isHidden = true
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(self)
    }
    
    @IBAction func dismissed(_ sender: Any) {
        NSLog("wetransfer URL:", wetransferURL)
                let p = NSPasteboard.general
                p.clearContents()
                p.writeObjects([wetransferURL as NSPasteboardWriting])
        self.dismiss(self)
    }
    
    @IBAction func upload(_ sender: Any) {
        
        progressView.isHidden = false
        uploadButton.isEnabled = false
        cancelButton.isEnabled = false
        let uploadfile = selectedImages
        WeTransfer.uploadTransfer(saying: "Koray Birand Office", containing: uploadfile) { [weak self] state in
            switch state {
            case .uploading(let progress):
                self?.observeUploadProgress(progress)
            case .failed(let error):
                printwithLog(log: error)
            case .completed(let transfer):
                if let url = transfer.shortURL {
                    printwithLog(log: url)
                    self?.viewState = .transferCompleted(shortURL: url)
                    self?.wetransferURL = url.absoluteString
                    self?.cancelButton.isHidden = true
                    self?.uploadButton.isHidden = true
                    self?.dismissedButton.isHidden = false
                    self?.dismissedButton.isEnabled = true
                    
                }
                
            default:
                break
            }
        }
        
    }
    
    private func observeUploadProgress(_ progress: Progress) {
        
        progressObservation = progress.observe(\.fractionCompleted) { [weak self] (progress, _) in
            DispatchQueue.main.async {
                self?.titleLabel.stringValue = "\(Int(progress.fractionCompleted * 100))% completed"
                self?.progressView.doubleValue = Double((progress.fractionCompleted * 100))
            }
        }
    }
    
    private func updateInterface() {
        
        switch viewState {
        case .ready:
            titleLabel.stringValue = "Add media to transfer"
        case .selectedMedia:
            titleLabel.stringValue = ""
        case .startedTransfer:
            titleLabel.stringValue = "Uploading"
        case .transferInProgress:
            titleLabel.stringValue = "Uploading"
        case .failed:
            titleLabel.stringValue = "Upload failed"
        case .transferCompleted(let shortURL):
            titleLabel.stringValue = "Transfer completed - \(shortURL.absoluteString)"
        }
    }
    
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func loadFile() -> URL {
        var getURL : URL!
        if let url = NSOpenPanel().selectFileUrlOpen {
            getURL =  url
        }
        return getURL
    }
    
    private func configureWeTransfer() {
        // Configures the WeTransfer client with the required API key 70qOgpt5I667v7YcBmhH75AKxN9gPFzI7XRcpJq6
        // Get an API key at https://developers.wetransfer.com
        WeTransfer.configure(with: WeTransfer.Configuration(apiKey: weTransferApiKey))
    }
    
}
