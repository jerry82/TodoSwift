//
//  Utility.swift
//  Todo
//
//  Created by Jerry on 6/11/15.
//  Copyright © 2015 jstudio. All rights reserved.
//

import Foundation
import UIKit

class Utility {
    
    // MARK: Singleton
    static let sharedInstance = Utility()

    // MARK: Database Path Handlers
    func getDBPath() -> (String) {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let fileURL = documentsURL.URLByAppendingPathComponent(AppConfig.DATA_FILE)
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
            let defaultPath = NSBundle.mainBundle().resourceURL?.URLByAppendingPathComponent(AppConfig.DATA_FILE).path
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

// MARK: Settings
struct CellConfig {
    static let TABLECELL_ROW_HEIGHT: CGFloat = 44
    static let SUBITEM_STRIKE_TEXTCOLOR: UIColor = UIColor.grayColor()
    static let SUBITEM_UNSTRIKE_TEXTCOLOR: UIColor = UIColor.blackColor()
    static let TABLECELL_GROUP_FONT = UIFont(name: "HelveticaNeue-Bold", size: 19)
    static let TABLECELL_ITEM_FONT = UIFont(name: "HelveticaNeue", size: 16)
    static let TABLECELL_ITEM_BGCOLOR = UIColor(netHex: 0xdbfffb)
    static let TABLECELL_GROUP_BGCOLOR = UIColor.whiteColor()
    static let GROUP_COLLAPSE_SIGN = "+"
    static let GROUP_EXPAND_SIGN = "-"
    static let TABLECELL_ITEM_INDENT_WIDTH: CGFloat = 15
}

struct AppConfig {
    static let DATA_FILE = "tasklist.sqlite"
    static let ITEM_CONTENT_LENGTH = 140 //allow 140 characters
}
    