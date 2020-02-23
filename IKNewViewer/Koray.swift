//
//  Koray.swift
//  Koray Birand Archive
//
//  Created by Koray Birand on 11/02/16.
//  Copyright © 2016 rock. All rights reserved.
//

import Foundation
import Cocoa
import CoreImage

let isUnderDevelopment : Bool = true

func printwithLog(log:Any) {
    if !isUnderDevelopment {
        return
    }
    print(log)
}

extension NSOpenPanel {
    var selectUrlOpen: URL? {
        title = "Select Folder"
        allowsMultipleSelection = false
        canChooseDirectories = true
        canChooseFiles = false
        canCreateDirectories = true
        //allowedFileTypes = ["mov","mp4"]  // to allow only images, just comment out this line to allow any file type to be selected
        return runModal() == .OK ? urls.first : nil
    }
    
    var selectFileUrlOpen: URL? {
        title = "Select Database"
        allowsMultipleSelection = false
        canChooseDirectories = false
        canChooseFiles = true
        canCreateDirectories = false
        allowedFileTypes = ["db","sql"]  // to allow only images, just comment out this line to allow any file type to be selected
        return runModal() == .OK ? urls.first : nil
    }
    
    var exportFolder: URL? {
        title = "Select Folder to Export"
        allowsMultipleSelection = false
        canChooseDirectories = true
        canChooseFiles = false
        canCreateDirectories = true
        return runModal() == .OK ? urls.first : nil
    }
}

extension NSSavePanel {
    var selectUrlSave: URL? {
        title = "Select Folder and Name"
        nameFieldStringValue = "newname.jpg"
        canCreateDirectories = true
        return runModal() == .OK ? url : nil
    }
}

extension NSImage {
    
    public func write(to url: URL, fileType type: NSBitmapImageRep.FileType = .jpeg, compressionFactor: NSNumber = 1.0) {
        // https://stackoverflow.com/a/45042611/3882644
        guard let data = tiffRepresentation else { return }
        guard let imageRep = NSBitmapImageRep(data: data) else { return }
        
        guard let imageData = imageRep.representation(using: type, properties: [.compressionFactor: compressionFactor]) else { return }
        try? imageData.write(to: url)
    }
}

class koray {
    
    class func resizeImage(_ imagePath:URL, targetPath:URL, compressionFactor: NSNumber) {
        let xFactor = Double((NSScreen.main?.backingScaleFactor)!)
        let data = NSData(contentsOf: imagePath)
        let imageView = NSImage(data: data! as Data)
        let rep = NSBitmapImageRep(data: data! as Data)
     
        
        
        let w = Double((rep?.pixelsWide)!)
        let h = Double((rep?.pixelsHigh)!)
        let wMax = Double(maxWidth)
        let hMax = Double(maxHeight)
        
        var newSize : NSSize!
        let ratio =  w / h
    
        if wMax - w > hMax - h {
            newSize = NSSize(width: hMax * ratio / xFactor, height: hMax / xFactor)
        } else {
            newSize = NSSize(width: wMax / xFactor , height: wMax / ratio / xFactor)
        }
        
    
        
        let target = NSImage(size: newSize)
        let targetRect = NSMakeRect(0, 0, newSize.width, newSize.height)
        
        let sourceSize = imageView!.size
        let sourceRect = NSMakeRect(0,0,sourceSize.width,sourceSize.height)
        
        target.lockFocus()
        imageView!.draw(in: targetRect, from: sourceRect, operation: .copy, fraction: 1.0)
        target.unlockFocus()
        
        if let TIFFrepresentation = target.tiffRepresentation {
            
            let imageRepresentation = NSBitmapImageRep(data: TIFFrepresentation)
            let properties = [NSBitmapImageRep.PropertyKey.compressionFactor:compressionFactor]
           
            var imageRep2 = imageRepresentation
            
            if colorProfile == 1 {
                imageRep2 = imageRepresentation?.converting(to: NSColorSpace.sRGB, renderingIntent: NSColorRenderingIntent.perceptual)
            }
            
            if saveJPEG == 1 {
                let data = imageRep2!.representation(using: .jpeg, properties: properties)
                try? data!.write(to: URL(fileURLWithPath: targetPath.path), options:  NSData.WritingOptions.atomic)
            } else {
                let data = imageRep2!.representation(using: .tiff, properties: properties)
                try? data!.write(to: URL(fileURLWithPath: targetPath.path), options:  NSData.WritingOptions.atomic)
            }
            
            
            
        }
        
    }
    
    class func downsample(imageAt imageURL:URL, to pointSize:CGSize, scale:CGFloat) -> NSImage {
        
        let imageSourceOptions = [kCGImageSourceShouldCache:true] as CFDictionary
        let imageSouce = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions)!
        
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downSampleOptions = [kCGImageSourceCreateThumbnailFromImageAlways :true ,
                                 kCGImageSourceShouldCacheImmediately:true,
                                 kCGImageSourceCreateThumbnailWithTransform:true,
                                 kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
        
        let downsampledImage =  CGImageSourceCreateThumbnailAtIndex(imageSouce, 0, downSampleOptions)!
        
        return NSImage(cgImage: downsampledImage, size: NSZeroSize)
        
    }
    
    
    
    class func folderPanel() -> URL {
        var getURL : URL!
        if let url = NSOpenPanel().selectUrlOpen {
            getURL =  url
        }
        return getURL
    }
    
    class func loadFile() -> URL {
        var getURL : URL!
        if let url = NSOpenPanel().selectFileUrlOpen {
            getURL =  url
        }
        return getURL
    }
    
    class func exportFolder() -> URL {
        var getURL : URL!
        if let url = NSOpenPanel().exportFolder {
            getURL =  url
        }
        return getURL
    }
    
    class func saveToFolder () -> URL {
        
        var getURL : URL!
        if let url = NSSavePanel().selectUrlSave {
            getURL =  url
        }
        return getURL
        
    }
    
    class func leftString(_ theString: String, charToGet: Int) ->String{
        
        var indexCount = 0
        let strLen = theString.count
        
        if charToGet > strLen { indexCount = strLen } else { indexCount = charToGet }
        if charToGet < 0 { indexCount = 0 }
        
        let index: String.Index = theString.index(theString.startIndex, offsetBy: indexCount)
        let mySubstring:String = String(theString[..<index])
        
        return mySubstring
        
    }
    
    class func rightString(_ theString: String, charToGet: Int) ->String{
        
        var indexCount = 0
        let strLen = theString.count
        let charToSkip = strLen - charToGet
        
        if charToSkip > strLen { indexCount = strLen } else { indexCount = charToSkip }
        if charToSkip < 0 { indexCount = 0 }
        let index: String.Index = theString.index(theString.startIndex, offsetBy: indexCount)
        let mySubstring:String = String(theString[index...])
        
        
        return mySubstring
    }
    
    class func midString(_ theString: String, startPos: Int, charToGet: Int) ->String{
        
        let strLen = theString.count
        let rightCharCount = strLen - startPos
        var mySubstring = koray.rightString(theString, charToGet: rightCharCount)
        mySubstring = koray.leftString(mySubstring, charToGet: charToGet)
        
        return mySubstring
        
    }
    
    class func splitToArray ( theString: String) -> [[String]] {
        var newArray = [[String]]()
        let a = theString.components(separatedBy: "\n")
        for elements in a  {
            let c = elements.components(separatedBy: ",")
            newArray.append(c)
        }
        
        return newArray
        
    }
    
    class func copyFile(fromPathString:String, toPathString:String) -> String {
        
        let myManager = FileManager.default
        let fromPath : URL = URL(fileURLWithPath: fromPathString)
        
        var toPath = URL(fileURLWithPath: toPathString).appendingPathComponent(fromPath.lastPathComponent).path
                
        let filename = (URL(fileURLWithPath: toPath)).lastPathComponent
        let fileExt  = (URL(fileURLWithPath: toPath)).pathExtension
        var fileNameWithoSuffix : String!
        var newFileName : String!
        var counter = 0
        
        
        if filename.hasSuffix(fileExt) {
            fileNameWithoSuffix = String(filename.prefix(filename.count - (fileExt.count+1)))
        }
        
        while myManager.fileExists(atPath: toPath) {
            counter += 1
            newFileName =  "\(fileNameWithoSuffix!)_\(counter).\(fileExt)"
            let newURL = URL(fileURLWithPath:toPathString).appendingPathComponent(newFileName).path
            toPath = newURL
        }
        
        let myURL = URL(fileURLWithPath: fromPathString)
        let fileExtension = myURL.pathExtension
        let fileUTI:Unmanaged<CFString>! = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)
        let isImage = UTTypeConformsTo(fileUTI.takeUnretainedValue(), kUTTypeImage)
        
        if (isImage == true) {
            try! myManager.copyItem(atPath: fromPathString, toPath: toPath)
        }
        
        return URL(fileURLWithPath: toPath).lastPathComponent
        
    }
    
    class func listFolderFiltered (urlPath: URL, filterExt: String) -> [String] {
        var newArray = [String]()
        
        let fm = FileManager.default
        do {
            let items = try fm.contentsOfDirectory(at: urlPath, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            
            for item in items {
                
                if item.pathExtension.lowercased() == filterExt  {
                    newArray.append(item.path)
                }
            }
        } catch {
            // failed to read directory – bad permissions, perhaps?
        }
        
        let ascending = newArray.sorted { (a, b) -> Bool in
            return b > a
        }
        
        
        return ascending
    }
    
    class func listFolderFilteredWithDate(urlPath: URL, filterExt: String) -> [[String]] {
        var newArray = [[String]]()
        var attribs = [FileAttributeKey : Any]()
        
        
        let fm = FileManager.default
        do {
            let items = try fm.contentsOfDirectory(at: urlPath, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            
            for item in items {
                
                if item.pathExtension.lowercased() == filterExt  {
                    
                    do {
                        attribs = try FileManager.default.attributesOfItem(atPath: item.path)
                    }
                    catch
                    {
                        printwithLog(log: error)
                    }
                    newArray.append([item.lastPathComponent,item.path,(attribs[FileAttributeKey.creationDate] as! NSDate).description])
                }
            }
        } catch {
            
        }
        
        let ascending = newArray.sorted { $0[0] < $1[0] }
        
        
        return ascending
    }
    
    
    
    class func getCsvContent(myPath: String) -> [[String]] {
        
        var array : [[String]]!
        
        do {
            let koko = try String(contentsOfFile: myPath)
            array = koray.splitToArray(theString: koko)
            
        }
        catch {}
        
        return array
        
    }
    
    class func changeDate(newDate: String, filePath: String) {
        
        let convertedDate = koray.convertDate(stringDate: newDate)
        
        let attributes = [FileAttributeKey.creationDate: convertedDate]
        let attributes2 = [FileAttributeKey.modificationDate: convertedDate]
        do {
            try FileManager.default.setAttributes(attributes as Any as! [FileAttributeKey : Any], ofItemAtPath: filePath)
        }
        catch
        {
            printwithLog(log: error)
        }
        
        do {
            try FileManager.default.setAttributes(attributes2 as Any as! [FileAttributeKey : Any], ofItemAtPath: filePath)
        }
        catch
        {
            printwithLog(log: error)
        }
        
        
    }
    
    class func convertDate (stringDate: String) -> Date {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss xx"
        guard let datem = dateFormatter.date(from: stringDate) else {
            fatalError("ERROR: Date conversion failed due to mismatched format.")
        }
        
        return datem
    }
    
    
    
    
    
}

