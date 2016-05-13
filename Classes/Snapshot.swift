//
//  Snapshot.swift
//  WKZombie
//
//  Created by Mathias Köhnke on 10/05/16.
//  Copyright © 2016 Mathias Köhnke. All rights reserved.
//

#if os(iOS)
import UIKit
public typealias SnapshotImage = UIImage
#elseif os(OSX)
import Cocoa
public typealias SnapshotImage = NSImage
#endif
    
public typealias SnapshotHandler = Snapshot -> Void

public class Snapshot {
    public let page : NSURL?
    public let file : NSURL
    public lazy var image : SnapshotImage? = {
        if let path = self.file.path {
            #if os(iOS)
                return UIImage(contentsOfFile: path)
            #elseif os(OSX)
                return NSImage(contentsOfFile: path)
            #endif
        }
        return nil
    }()
    
    internal init?(data: NSData, page: NSURL? = nil) {
        do {
            self.file = try Snapshot.store(data)
            self.page = page
        } catch let error as NSError {
            Logger.log("Could not take snapshot: \(error.localizedDescription)")
            return nil
        }
    }
    
    private static func store(data: NSData) throws -> NSURL {
        let identifier = NSProcessInfo.processInfo().globallyUniqueString
        
        let fileName = String(format: "wkzombie-snapshot-%@", identifier)
        let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(fileName)
        
        try data.writeToURL(fileURL, options: .AtomicWrite)
        
        return fileURL
    }
    
    public func moveTo(directory: NSURL) throws -> NSURL? {
        let fileManager = NSFileManager.defaultManager()
        if let fileName = file.lastPathComponent {
            let destination = directory.URLByAppendingPathComponent(fileName)
            try fileManager.moveItemAtURL(file, toURL: destination)
            return destination
        }
        return nil
    }
}
