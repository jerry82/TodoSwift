//
//  Utility.swift
//  Todo
//
//  Created by Jerry on 6/11/15.
//  Copyright © 2015 jstudio. All rights reserved.
//

import Foundation

class Utility {
    
    static let sharedInstance = Utility()

    private let DATA_FILE = "tasklist.sqlite"

    func getDBPath() -> (String) {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let fileURL = documentsURL.URLByAppendingPathComponent(DATA_FILE)
        return  fileURL.path!
    }
    
    func initDB() {
        let fileManager: NSFileManager = NSFileManager.defaultManager()
        let docsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        print(docsPath)
        if (!fileManager.fileExistsAtPath(docsPath)) {
            print("target folder not found. Creating folder...")
            var attr = [String: AnyObject]()
            attr[NSFileProtectionKey] = NSFileProtectionComplete
            do {
                try fileManager.createDirectoryAtPath(docsPath, withIntermediateDirectories: true, attributes: attr)
            } catch let error as NSError {
                print("Error: failed to create document folder: \(error)")
                return
            }
        }
        
        let writePath = getDBPath()
        print("Write path: \(writePath)")
        if (!fileManager.fileExistsAtPath(writePath)) {
            let defaultPath = NSBundle.mainBundle().resourceURL?.URLByAppendingPathComponent(Utility.sharedInstance.DATA_FILE).path
            do {
                try fileManager.copyItemAtPath(defaultPath!, toPath: writePath)
                print("Success: copying database file")
            }
            catch let error as NSError{
                print("Error: failed to copy data file \(error)")
            }
        }
    }
}