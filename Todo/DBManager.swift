//
//  DBManager.swift
//  Todo
//
//  Created by Jerry on 6/11/15.
//  Copyright © 2015 jstudio. All rights reserved.
//

import Foundation


class DBManager {
    
    //singleton
    static let sharedIstance = DBManager()
    
    private var database: AnyObject! = FMDatabase()
    
    init() {
        database = FMDatabase.databaseWithPath(Utility.sharedInstance.getDBPath())
    }
    
    //group CRUD
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
    
    func insertGroup(group: ItemModel) {
     
        if (!database.open()) {
            print("Error: failed to open DB")
            return
        }
        
        let sql = "INSERT INTO item_table(content, parentId, completed) VALUES (?, -1, 'false')"
        let args : [AnyObject] = [group.content]
        database.executeUpdate(sql, withArgumentsInArray: args)
        
        let _ : Bool = database.close()
    }
    
    func updateGroup(group: ItemModel) -> Bool {
        return true
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
            item.completed = rs.boolForColumn("completed")
            item.type = ItemEnum.L2
            item.parentId = parentId
            items.append(item)
        }
        
        let _ : Bool = database.close()
        
        return items
    }
    
    func insertItem(item: ItemModel) {
        if (!database.open()) {
            print("Error: failed to open DB")
            return
        }
        
        let sql = "INSERT INTO item_table(content, completed, parentId) VALUES (?, ?, ?)"
        let args : [AnyObject] = [item.content, item.completed, item.parentId]
        database.executeUpdate(sql, withArgumentsInArray: args)
        
        let _ : Bool = database.close()
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