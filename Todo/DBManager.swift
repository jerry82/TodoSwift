//
//  DBManager.swift
//  Todo
//
//  Created by Jerry on 6/11/15.
//  Copyright © 2015 jstudio. All rights reserved.
//

import Foundation


class DBManager {
    
    // MARK: Singleton
    static let sharedIstance = DBManager()
    
    // MARK: Variables
    private var database: AnyObject! = FMDatabase()
    
    // MARK: Initialization
    init() {
        database = FMDatabase.databaseWithPath(Utility.sharedInstance.getDBPath())
    }
    
    // MARK: CRUD Operations
    func selectAllGroups() -> [ItemModel] {
        var groups = [ItemModel]()
     
        if (!database.open()) {
            print("Error: failed to open DB")
            return groups
        }
        
        let sql = "SELECT id, content FROM item_table WHERE parentId = -1"
        let args = [AnyObject!]()
        let rs = database.executeQuery(sql, withArgumentsInArray: args)
        
        while(rs.next()) {
            let group = ItemModel()
            group.id = (Int)(rs.intForColumn("id"))
            group.content = rs.stringForColumn("content")
            group.type = ItemEnum.L1
            groups.append(group)
        }
        
        let _ : Bool = database.close()
        
        return groups
    }
    
    func getLastItemIdx() -> Int {
        if (!database.open()) {
            print("Error: failed to open DB")
            return -1
        }
        
        let sql = "SELECT LAST_INSERT_ROWID()"
        let args = [AnyObject]()
        let rs = database.executeQuery(sql, withArgumentsInArray: args)
        while (rs.next()) {
            return Int(rs.intForColumnIndex(0))
        }
        
        let _ : Bool = database.close()
        return -1
    }
    
    func deleteGroup(groupId: Int) {
        
        if (!database.open()) {
            print("Error: failed to open DB")
            return
        }
        
        let sql = "DELETE FROM item_table WHERE parentId = ? or id = ?"
        let args: [AnyObject] = [groupId, groupId]
        database.executeUpdate(sql, withArgumentsInArray: args)
        
        let _ : Bool = database.close()
    }
    
    //item CRUD
    func getItems(parentId: Int) -> [ItemModel] {
        var items = [ItemModel]()
        
        if (!database.open()) {
            print("Error: failed to open DB")
            return items
        }
        
        let sql = "SELECT id, content, completed, parentId FROM item_table WHERE parentId = ?"
        let args : [AnyObject] = [parentId]
        
        let rs = database.executeQuery(sql, withArgumentsInArray: args)
        
        while (rs.next()) {
            let item = ItemModel()
            item.id = (Int)(rs.intForColumn("id"))
            item.content = rs.stringForColumn("content")
            item.completed = rs.intForColumn("completed") == 1 ? true : false
            item.type = ItemEnum.L2
            item.parentId = parentId
            items.append(item)
        }
        
        let _ : Bool = database.close()
        
        return items
    }
    
    func updateItemStatus(item: ItemModel) {
        if (!database.open()) {
            print("Error: failed to open DB")
            return
        }
        
        let sql = "UPDATE item_table SET completed = ? WHERE id = ?"
        let completed = item.completed ? 1 : 0
        let args : [AnyObject] = [completed, item.id]
        database.executeUpdate(sql, withArgumentsInArray: args)
        
        let _ : Bool = database.close()
    }
    
    func insertItem(item: ItemModel) -> Int {
        if (!database.open()) {
            print("Error: failed to open DB")
            return -1
        }
        
        let sql = "INSERT INTO item_table(content, completed, parentId) VALUES (?, 'false', ?)"
        let args : [AnyObject] = [item.content, item.parentId]
        database.executeUpdate(sql, withArgumentsInArray: args)
        let id = Int(database.lastInsertRowId())
        let _ : Bool = database.close()
        
        return id
    }

    func deleteItem(itemId: Int) {
        if (!database.open()) {
            print("Error: failed to open DB")
            return
        }
        
        let sql = "DELETE FROM item_table WHERE id = ?"
        let args: [AnyObject] = [itemId]
        database.executeUpdate(sql, withArgumentsInArray: args)
        
        let _ : Bool = database.close()
    }
}