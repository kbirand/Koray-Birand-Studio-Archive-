//
//  ViewController.swift
//  IKNewViewer
//
//  Created by Koray Birand on 9/9/18.
//  Copyright © 2018 Koray Birand. All rights reserved.
//

import Cocoa
import Quartz
import AppKit
import SQLite

var db = try! Connection()
var worksData = [[String:String]]()
var favoritesData = [[String:String]]()
var selectedImages = [URL]()
var filteredWorksData = [[String:String]]()
var filesData = [[String:String]]()
var selectedWorkId = ""
var selectedRow : Int = -1
var searchFieldText : String = ""
var searchResultCount : Int = 0
var dbFile : String!
var archivePath : URL!

class myImageObject: NSObject {
    
    var path : String = ""
    var fileName : String = ""
    var size : String = ""
    var id : Int!
    var filesWorkId : Int!
    
    override func imageRepresentationType() -> String!
    {
        return IKImageBrowserPathRepresentationType
    }
    
    override func imageRepresentation() -> Any!
    {
        return path
    }
    
    override func imageUID() -> String! {
        return path
    }
    
    override func imageTitle() -> String! {
        return fileName
    }
    
    override func imageSubtitle() -> String! {
        return size
    }
}

extension NSPasteboard.PasteboardType {
    
    static let backwardsCompatibleFileURL: NSPasteboard.PasteboardType = {
        
        if #available(OSX 10.13, *) {
            return NSPasteboard.PasteboardType.fileURL
        } else {
            return NSPasteboard.PasteboardType(kUTTypeFileURL as String)
        }
        
    } ()
    
}

class ViewController: NSViewController {
    
    @IBOutlet weak var imageBrowser: IKImageBrowserView!
    @IBOutlet weak var filenameLabel: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var pathField: NSTextField!
    @IBOutlet weak var stylistField: NSTextField!
    @IBOutlet weak var hairField: NSTextField!
    @IBOutlet weak var makeupField: NSTextField!
    @IBOutlet weak var talentField: NSTextField!
    @IBOutlet weak var recordCount: NSTextField!
    @IBOutlet weak var workField: NSTextField!
    @IBOutlet weak var periodField: NSTextField!
    
    var images:NSMutableArray = []
    var importedImages:NSMutableArray = []
    var selectedFilePath:String = ""
    var selectedIndex:Int = -1
    
    lazy var newProjectController: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: "newProject")
            as! NSViewController
    }()
    lazy var deleteProjectController: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: "deleteProject")
            as! NSViewController
    }()
    
    lazy var updatedController: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: "updated")
            as! NSViewController
    }()
    
    lazy var settingsController: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: "settings")
            as! NSViewController
    }()
    
    lazy var wetransferController: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: "wetransfer")
            as! NSViewController
    }()
    
    @IBAction func sortBy(_ sender: NSButton) {
        getFilesSortByName(id: mainId, path: mainPath)
    }
    
    
    func openFiles()->NSArray?
    {
        var panel:NSOpenPanel
        
        panel = NSOpenPanel()
        panel.isFloatingPanel = true
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
        let i = panel.runModal()
        if (i == NSApplication.ModalResponse.OK)
        {
            return panel.urls as NSArray
        }
        return nil
    }
    
    override func viewDidAppear() {
        self.view.window?.delegate = self
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchField.delegate = self
        self.workField.delegate = self
        self.periodField.delegate = self
        self.stylistField.delegate = self
        self.hairField.delegate = self
        self.makeupField.delegate = self
        self.talentField.delegate = self
        
        
        imageBrowser.setValue(NSColor(named: NSColor.Name("ikBG"))!, forKey: "IKImageBrowserBackgroundColorKey")
        let oldAttributres = imageBrowser.value(forKey: IKImageBrowserCellsTitleAttributesKey) as! NSDictionary
        let attributres = oldAttributres.mutableCopy() as! NSMutableDictionary
        attributres.setObject(NSColor(named: NSColor.Name("ikBG2"))!, forKey: NSAttributedString.Key.foregroundColor as NSCopying)
        imageBrowser.setValue(attributres, forKey:IKImageBrowserCellsTitleAttributesKey)
        imageBrowser.setCellsStyleMask(IKCellsStyleTitled|IKCellsStyleSubtitled)
        
        checkSettings()
        
        images = []
        importedImages = []
        imageBrowser.setAllowsReordering(true)
        imageBrowser.setAnimates(false)
        imageBrowser.setDraggingDestinationDelegate(self)
        imageBrowser.setCanControlQuickLookPanel(true)
        imageBrowser.setCellsStyleMask(IKCellsStyleOutlined|IKCellsStyleTitled|IKCellsStyleSubtitled)
        imageBrowser.setAllowsDroppingOnItems(true)
        initDB()
        createObservers()
        
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func exportSelectedButton(_ sender: Any) {
        exportSelectedImages()
    }
    
    @IBAction func wetransferButton(_ sender: Any) {
        selectedImages.removeAll()
        if imageBrowser.selectionIndexes().count > 0 {
            for item in imageBrowser.selectionIndexes() {
                selectedImages.append(URL(fileURLWithPath: filesData[item]["file"]!))
            }
            self.presentAsSheet(wetransferController)
        }
    }
    
    
    func exportSelectedImages() {
        
        let destinationFolder = koray.exportFolder()
        
        for item in imageBrowser.selectionIndexes() {
            let destinationFile = destinationFolder.appendingPathComponent(URL(fileURLWithPath: filesData[item]["file"]!).lastPathComponent)
            koray.resizeImage(URL(fileURLWithPath: filesData[item]["file"]!), targetPath: destinationFile, compressionFactor: compressionValue! as NSNumber)
        }
    }
    
    
    func checkSettings() {
       
       if UserDefaults.standard.url(forKey: "dbFile") == nil || UserDefaults.standard.url(forKey: "archivePath") == nil {
            
            let bundlePath = Bundle.main.path(forResource: "archive", ofType: ".db")
            
            if FileManager.default.fileExists(atPath: bundlePath!) {
                let dbFolder = (FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]).appendingPathComponent("com.koraybirand.studioarchive").appendingPathComponent("archive.db")
                try! FileManager.default.createDirectory(at: (FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]).appendingPathComponent("com.koraybirand.studioarchive"), withIntermediateDirectories: true, attributes: nil)
                
                
                if !FileManager.default.fileExists(atPath: dbFolder.path) {
                    try! FileManager.default.copyItem(atPath: bundlePath!, toPath: dbFolder.path)
                }
                
                UserDefaults.standard.set(dbFolder, forKey: "dbFile")
                dbFile = dbFolder.path
            }
            
            let path = koray.folderPanel()
            UserDefaults.standard.set(path, forKey: "archivePath")
            archivePath = path
            
            
        } else {
            dbFile = UserDefaults.standard.url(forKey: "dbFile")?.path
            archivePath = UserDefaults.standard.url(forKey: "archivePath")
            
        }
        
    }
    
    func createObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.initDB), name: Notification.Name(rawValue: "initDB"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.initDBNotifty), name: Notification.Name(rawValue: "initDBNotifty"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.favoriteSelected), name: Notification.Name(rawValue: "favoriteSelected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.favoriteAllSelected), name: Notification.Name(rawValue: "favoriteAllSelected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.favoriteImages), name: Notification.Name(rawValue: "favoriteImages"), object: nil)
        
    }
    
    func addImageButtonClicked() {
        
    }
    
    @objc func favoriteImages(_ notification: NSNotification) {
        
        let dict = notification.userInfo! as NSDictionary
        let id = dict["id"] as! String
        let path = dict["path"] as! String
        let indexPath = dict["indexPath"] as! String
        
        getFiles(id: id, path: path)
        
        let selectedWork : [String:String] = favoritesData[Int(indexPath)!]
        
        pathField.stringValue = selectedWork["path"]!
        stylistField.stringValue = selectedWork["stylist"]!
        hairField.stringValue = selectedWork["hair"]!
        makeupField.stringValue = selectedWork["makeup"]!
        talentField.stringValue = selectedWork["talent"]!
        workField.stringValue = selectedWork["work"]!
        periodField.stringValue = selectedWork["period"]!
        
        let dataDict:[String: String] = ["path": "","filename":""]
        NotificationCenter.default.post(name: Notification.Name(rawValue: "changeImage"), object: nil, userInfo: dataDict)
        
    }
    
    @objc func favoriteSelected() {
        
        if searchField.stringValue == "" && selectedRow != -1 {
            
            let searchPredicate = NSPredicate(format: "id = %@", worksData[tableView.selectedRow]["id"]!)
            let array = (favoritesData as NSArray).filtered(using: searchPredicate)
            
            if array.count == 0 {
                favoritesData.append(worksData[tableView.selectedRow])
            }
            
            UserDefaults.standard.set(favoritesData as NSArray, forKey: "favorites")
            
        } else if searchField.stringValue.count > 0  && selectedRow != -1 {
        
            let searchPredicate = NSPredicate(format: "id = %@", filteredWorksData[tableView.selectedRow]["id"]!)
            let array = (favoritesData as NSArray).filtered(using: searchPredicate)
            
            if array.count == 0 {
                favoritesData.append(filteredWorksData[tableView.selectedRow])
            }
            
            UserDefaults.standard.set(favoritesData as NSArray, forKey: "favorites")
        }

    }
    
    @objc func favoriteAllSelected() {
        
        if searchField.stringValue == "" {
            
            for item in worksData {
                
                let searchPredicate = NSPredicate(format: "id = %@", item["id"]!)
                let array = (favoritesData as NSArray).filtered(using: searchPredicate)
                
                if array.count == 0 {
                    favoritesData.append(item)
                }
            }
            
            UserDefaults.standard.set(favoritesData as NSArray, forKey: "favorites")
            
        } else  if searchField.stringValue.count > 0 {

            for item in filteredWorksData {
                
                let searchPredicate = NSPredicate(format: "id = %@", item["id"]!)
                let array = (favoritesData as NSArray).filtered(using: searchPredicate)
                
                if array.count == 0 {
                    favoritesData.append(item)
                }
            }
            UserDefaults.standard.set(favoritesData as NSArray, forKey: "favorites")
        }
    
    }
    
    
    @IBAction func zoomSliderDidChange(_ sender: NSSlider) {
        imageBrowser.setZoomValue(sender.floatValue)
        imageBrowser.needsDisplay = true
    }
    
    @IBAction func getFiles(_ sender: Any) {
        
        let selects = imageBrowser.selectionIndexes() as IndexSet
        
        if selects.isEmpty  {
            printwithLog(log: "no files selected...")
            return
        }
        printwithLog(log: "selected files found...")
        
        for items in selects {
            let myFilePath = images.object(at: items) as! myImageObject
            printwithLog(log: myFilePath)
        }
        
    }
    
    @objc func newProject() {
        self.presentAsSheet(newProjectController)
        
        
    }
    
    @objc func initDB() {
        
        searchField.stringValue = ""
        worksData.removeAll()
        filteredWorksData.removeAll()
        
        db = try! Connection(dbFile)
        
        //try db.run("INSERT INTO works (work,period) VALUES (?,?)", "XXXXXXXXXXXXX","8989")
        //try db.run("DELETE FROM works WHERE id = \(752)")
        //            let count = try db.scalar("SELECT count(*) FROM works")
        //
        
        for row in try! db.prepare("SELECT * FROM works") {
            let id = Int(exactly: row[0]! as! int_fast64_t)!
            let work : String = row[1] as! String
            let period : String = row[2] as! String
            let path : String = row[3] as! String
            let stylist : String = row[4] as! String
            let hair : String = row[5] as! String
            let makeup : String = row[6] as! String
            let talent : String = row[7] as! String
            worksData.append(["id": id.description,"work": work,"period": period,"path": path,"stylist": stylist,"hair": hair,"makeup":makeup,"talent":talent])
        }
        
        worksData.reverse()
        tableView.reloadData()
        tableView.selectRowIndexes(.init(integer: 0), byExtendingSelection: false)
        tableView.becomeFirstResponder()
        imageBrowser.scrollIndexToVisible(0)
    }
    
    @objc func initDBNotifty(_ notification: NSNotification) {
        let dict = notification.userInfo! as NSDictionary
        let works = dict["array"] as! String
        let search = dict["search"] as! String
        let function = dict["function"] as! String
        
        
        worksData.removeAll()
        
        
        //searchField.stringValue = ""
        filteredWorksData.removeAll()
        
        db = try! Connection(dbFile)
        
        //try db.run("INSERT INTO works (work,period) VALUES (?,?)", "XXXXXXXXXXXXX","8989")
        //try db.run("DELETE FROM works WHERE id = \(752)")
        //            let count = try db.scalar("SELECT count(*) FROM works")
        
        for row in try! db.prepare("SELECT * FROM works") {
            let id = Int(exactly: row[0]! as! int_fast64_t)!
            let work : String = row[1] as! String
            let period : String = row[2] as! String
            let path : String = row[3] as! String
            let stylist : String = row[4] as! String
            let hair : String = row[5] as! String
            let makeup : String = row[6] as! String
            let talent : String = row[7] as! String
            worksData.append(["id": id.description,"work": work,"period": period,"path": path,"stylist": stylist,"hair": hair,"makeup":makeup,"talent":talent])
        }
        worksData.reverse()
        
        
        if (works == "works" && search == "false" && function == "delete") {
            tableView.reloadData()
            if selectedRow - 1 == -1 {
                tableView.selectRowIndexes(.init(integer: 0 ), byExtendingSelection: false)
            } else {
                tableView.selectRowIndexes(.init(integer: selectedRow - 1 ), byExtendingSelection: false)
            }
            
        } else if (works == "filtered" && search == "true" && function == "delete") {
            
            let searchPredicate = NSPredicate(format: "work CONTAINS[cd] %@ or hair CONTAINS[cd] %@ or makeup CONTAINS[cd] %@ or stylist CONTAINS[cd] %@ or talent CONTAINS[cd] %@", searchFieldText,searchFieldText,searchFieldText,searchFieldText,searchFieldText)
            let array = (worksData as NSArray).filtered(using: searchPredicate)
            filteredWorksData = array as! [[String:String]]
            searchResultCount = filteredWorksData.count
            tableView.reloadData()
            
            if selectedRow - 1 == -1 {
                tableView.selectRowIndexes(.init(integer: 0 ), byExtendingSelection: false)
            } else {
                tableView.selectRowIndexes(.init(integer: selectedRow - 1 ), byExtendingSelection: false)
            }
            
        } else if (works == "works" && search == "false" && function == "new") {
            tableView.reloadData()
            tableView.selectRowIndexes(.init(integer: 0 ), byExtendingSelection: false)
        } else if (works == "works" && search == "true" && function == "new") {
            let searchPredicate = NSPredicate(format: "work CONTAINS[cd] %@ or hair CONTAINS[cd] %@ or makeup CONTAINS[cd] %@ or stylist CONTAINS[cd] %@ or talent CONTAINS[cd] %@", searchFieldText,searchFieldText,searchFieldText,searchFieldText,searchFieldText)
            let array = (worksData as NSArray).filtered(using: searchPredicate)
            filteredWorksData = array as! [[String:String]]
            searchResultCount = filteredWorksData.count
            tableView.reloadData()
            if selectedRow  == -1 {
               tableView.selectRowIndexes(.init(integer: 0 ), byExtendingSelection: false)
            } else {
                tableView.selectRowIndexes(.init(integer: selectedRow+1), byExtendingSelection: false)
            }
        }
        
        tableView.becomeFirstResponder()
        imageBrowser.scrollIndexToVisible(0)
    }
    
    
    
    func updateDatasource() {
        
        images.addObjects(from: importedImages as [AnyObject])
        importedImages.removeAllObjects()
        imageBrowser.reloadData()
        
    }
    
    func addAnImageWithPath(_ path: String, id:String, name:String) {
        let myURL = URL(fileURLWithPath: path)
        let fileExtension = myURL.pathExtension
        let fileUTI:Unmanaged<CFString>! = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)
        let isImage = UTTypeConformsTo(fileUTI.takeUnretainedValue(), kUTTypeImage)
        var width : Int!
        var height : Int!
        
        if (isImage == false) {
            return
        }
        let p:myImageObject = myImageObject()
        p.path = path
        p.fileName = name
        p.size = {
            let imageReg : NSImageRep = NSImageRep(contentsOf: URL(fileURLWithPath: path))!
            let fileSize = "\(imageReg.pixelsWide) x \(imageReg.pixelsHigh)"
            width = imageReg.pixelsWide
            height = imageReg.pixelsHigh
            return fileSize
        }()
        
        let count = try! db.scalar("SELECT count(*) FROM files where workid = \(Int(id) ?? 0) ORDER BY 'ordered' ASC") as! Int64
        try! db.run("INSERT INTO files (workid,file,width,height,ordered) VALUES (?,?,?,?,?)", Int(id), myURL.lastPathComponent,width,height,count+1)
        //SELECT MAX(id) FROM tablename;
        filesData.append(["file":myURL.path])
        importedImages.add(p)
    }
    
    func addImagesWithPath(_ path: String, recursive:Bool) {
        if selectedRow < 0 {
            return
        }
        var counter = 0
        
        var dir = ObjCBool(false)
        
        FileManager.default.fileExists(atPath: path, isDirectory: &dir)
        
        if dir.boolValue {
            let content:NSArray = try! FileManager.default.contentsOfDirectory(atPath: path) as NSArray
            let n = content.count
            
            for  i in 0...n-1 {
                counter += 1
                let newPath = URL(fileURLWithPath: path).appendingPathComponent(content.object(at: i) as! String).path
                if searchFieldText == "" {
                    let myId : String = worksData[selectedRow]["id"]!
                    let pathSQL : String = worksData[selectedRow]["path"]!
                    let toPathString : String = archivePath.appendingPathComponent(pathSQL).path
                    let nName = koray.copyFile(fromPathString: newPath, toPathString: toPathString)
                    self.addAnImageWithPath(newPath, id: myId, name: nName)
                } else {
                    let myId : String = filteredWorksData[selectedRow]["id"]!
                    let pathSQL : String = filteredWorksData[selectedRow]["path"]!
                    let toPathString : String = archivePath.appendingPathComponent(pathSQL).path
                    let nName = koray.copyFile(fromPathString: newPath, toPathString: toPathString)
                    self.addAnImageWithPath(newPath, id: myId, name: nName)
                }
            }
        }
        else {
            if searchFieldText == "" {
                let myId : String = worksData[selectedRow]["id"]!
                let pathSQL : String = worksData[selectedRow]["path"]!
                let toPathString : String = archivePath.appendingPathComponent(pathSQL).path
                let nName = koray.copyFile(fromPathString: path, toPathString: toPathString)
                self.addAnImageWithPath(path, id: myId, name: nName)
            } else {
                let myId : String = filteredWorksData[selectedRow]["id"]!
                let pathSQL : String = filteredWorksData[selectedRow]["path"]!
                let toPathString : String = archivePath.appendingPathComponent(pathSQL).path
                let nName = koray.copyFile(fromPathString: path, toPathString: toPathString)
                self.addAnImageWithPath(path, id: myId, name: nName)
            }
            
        }
    }
    
    func addImagesWithPaths(_ urls: NSArray) {
        
        
        let n = urls.count
        for i in 0...n-1 {
            let url:URL = urls.object(at: i) as! URL
            self.addImagesWithPath(url.path, recursive: false)
        }
        
        
        DispatchQueue.main.async(execute: {
            self.updateDatasource()
        })
    }
    
    override func numberOfItems(inImageBrowser view: IKImageBrowserView) -> Int {
        return images.count
    }
    
    override func imageBrowser(_ aBrowser: IKImageBrowserView!, itemAt index: Int) -> Any! {
        return images.object(at: index)
    }
    
    
    override func imageBrowser(_ aBrowser: IKImageBrowserView!, removeItemsAt indexes: IndexSet!) {
        
    
        
        for index in indexes {
            let itemToDelete = filesData[index]
            let toDelete = (itemToDelete["id"]!)
            try! db.run("DELETE FROM files WHERE id = \(toDelete)")
        }
        
        images.removeObjects(at: indexes)
        
    }
    
    
    
    override func imageBrowser(_ aBrowser: IKImageBrowserView!, moveItemsAt indexes: IndexSet!, to destinationIndex: Int) -> Bool {
        let temporaryArray:NSMutableArray = []
        var destinationIdx: Int = destinationIndex
        
        var index = indexes.last
        
        while index != nil {
            if index! < destinationIdx {
                destinationIdx -= 1
            }
            
            let obj: AnyObject = images.object(at: index!) as AnyObject
            temporaryArray.add(obj)
            images.removeObject(at: index!)
            index = indexes.integerLessThan(index!)
        }
        
        let n = temporaryArray.count
        for index in 0...n-1 {
            images.insert(temporaryArray.object(at: index), at: destinationIdx)
        }
        
        
        
       print("kbbbb")
        
        var ordernum = 1
        let x = images.count
        for ii in 0...x-1 {
            let kb = images.object(at: ii) as! myImageObject
            try! db.run("UPDATE files SET workid = (?), file = (?), width = (?), height = (?), ordered = (?) WHERE id = (?)", kb.filesWorkId,kb.fileName,((kb.size).components(separatedBy: " x" ).first!),((kb.size).components(separatedBy: " x" ).last!),ordernum,kb.id)
            ordernum = ordernum + 1
        }
        return true
    }
    
    override func imageBrowserSelectionDidChange(_ aBrowser: IKImageBrowserView!) {
        let indexes = aBrowser.selectionIndexes()
        
                
        if (indexes?.count == 0) {
            self.filenameLabel.stringValue = "No selected file"
            selectedFilePath = ""
            selectedIndex = -1
        }
        else if (indexes?.count == 1) {
            let idx = indexes?.last
            let obj:myImageObject = images.object(at: idx!) as! myImageObject
            let path:String = obj.path
            let myURL = URL(fileURLWithPath: path)
            self.filenameLabel.stringValue = myURL.pathComponents.last!
            selectedFilePath = path
            selectedIndex = idx!
            let dataDict:[String: String] = ["path": "\(selectedFilePath)","filename":"\(myURL.lastPathComponent)"]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "changeImage"), object: nil, userInfo: dataDict)
        }
        else {
            let filename:String = String("\(indexes!.count) files selected")
            self.filenameLabel.stringValue = filename
            
            let idx = indexes?.last
            let obj:myImageObject = images.object(at: idx!) as! myImageObject
            let path:String = obj.path
            selectedFilePath = path
            selectedIndex = idx!
        }
    }
    
    
    
    func draggingEntered(_ sender: AnyObject) -> NSDragOperation {
        return NSDragOperation.copy
    }
    
    func draggingUpdated(_ sender: AnyObject) -> NSDragOperation {
        return NSDragOperation.copy
    }
    
    //    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
    //        var data:Data? = nil
    //        let pasteboard:NSPasteboard = sender.draggingPasteboard()
    //
    //        let types:NSArray = pasteboard.types! as NSArray
    //        if (types.contains(NSPasteboard.PasteboardType.backwardsCompatibleFileURL)) {
    //            data = pasteboard.data(forType: NSPasteboard.PasteboardType.backwardsCompatibleFileURL)
    //        }
    //
    //        if (data != nil) {
    //
    //            let filenames:NSArray = try! PropertyListSerialization.propertyList(from: data!, options: [], format: nil) as! NSArray
    //
    //            let n = filenames.count
    //            for i in 0...n {
    //                self.addAnImageWithPath(filenames.object(at: i) as! String)
    //            }
    //
    //            self.updateDatasource()
    //        }
    //
    //        return true
    //    }
    
    func getFiles(id:String, path:String) {
        filesData.removeAll()
        importedImages.removeAllObjects()
        images.removeAllObjects()
        
        for row in try! db.prepare("SELECT * FROM files where workId = \((id as NSString).integerValue) ORDER BY ordered ASC") {
            let idFiles = Int(exactly: row[0]! as! int_fast64_t)!
            let workId = Int(exactly: row[1]! as! int_fast64_t)!
            let file : String = row[2] as! String
            let createFilePath = archivePath.appendingPathComponent(path).appendingPathComponent(file)
            let width = Int(exactly: row[3]! as! int_fast64_t)!
            let height = Int(exactly: row[4]! as! int_fast64_t)!
            let order = Int(exactly: row[5]! as! int_fast64_t)!
            
            let p:myImageObject = myImageObject()
            p.path = createFilePath.path
            p.fileName = createFilePath.lastPathComponent
            p.size = {
                //                let imageReg : NSImageRep = NSImageRep(contentsOf: URL(fileURLWithPath: createFilePath))!
                //                let fileSize = "\(imageReg.pixelsWide) x \(imageReg.pixelsHigh)"
                
                let fileSize = "\(Int(width)) x \(Int(height))"
                return fileSize
            }()
            p.id = idFiles
            p.filesWorkId = workId
            
            importedImages.add(p)
            
            filesData.append(["id": idFiles.description,"workId": workId.description,"file": createFilePath.path,"order": order.description])
        }
        updateDatasource()
        
    }
    
    func getFilesSortByName(id:String, path:String) {
        filesData.removeAll()
        importedImages.removeAllObjects()
        images.removeAllObjects()
        
        for row in try! db.prepare("SELECT * FROM files where workId = \((id as NSString).integerValue) ORDER BY file ASC") {
            let idFiles = Int(exactly: row[0]! as! int_fast64_t)!
            let workId = Int(exactly: row[1]! as! int_fast64_t)!
            let file : String = row[2] as! String
            let createFilePath = archivePath.appendingPathComponent(path).appendingPathComponent(file)
            let width = Int(exactly: row[3]! as! int_fast64_t)!
            let height = Int(exactly: row[4]! as! int_fast64_t)!
            let order = Int(exactly: row[5]! as! int_fast64_t)!
            
            let p:myImageObject = myImageObject()
            p.path = createFilePath.path
            p.fileName = createFilePath.lastPathComponent
            p.size = {
                //                let imageReg : NSImageRep = NSImageRep(contentsOf: URL(fileURLWithPath: createFilePath))!
                //                let fileSize = "\(imageReg.pixelsWide) x \(imageReg.pixelsHigh)"
                
                let fileSize = "\(Int(width)) x \(Int(height))"
                return fileSize
            }()
            p.id = idFiles
            p.filesWorkId = workId
            
            importedImages.add(p)
            
            filesData.append(["id": idFiles.description,"workId": workId.description,"file": createFilePath.path,"order": order.description])
        }
        updateDatasource()
        
    }
    
    
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
}

