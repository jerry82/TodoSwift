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
    func selectAllGroups() -> [GroupModel] {
        var groups = [GroupModel]()
     
        if (!database.open()) {
            print("Error: failed to open DB")
            return groups
        }
        
        let sql = "SELECT id, content FROM group_table"
        let args = [AnyObject!]()
        let rs = database.executeQuery(sql, withArgumentsInArray: args)
        
        while(rs.next()) {
            let group = GroupModel()
            group.id = (Int)(rs.intForColumn("id"))
            group.content = rs.stringForColumn("content")
            groups.append(group)
        }
        
        let _ : Bool = database.close()
        
        return groups
    }
    
    func insertGroup(group: GroupModel) {
        
    }
    
    func updateGroup(group: GroupModel) -> Bool {
        return true
    }
    
    func deleteGroup(groupId: Int) {
        
    }
    
    //item CRUD
    func getItems(groupId: Int) -> [ItemModel] {
        var items = [ItemModel]()
        
        if (!database.open()) {
            print("Error: failed to open DB")
            return items
        }
        
        let sql = "SELECT id, content, completed FROM item_table WHERE groupId = ?"
        let args : [AnyObject] = [groupId]
        
        let rs = database.executeQuery(sql, withArgumentsInArray: args)
        
        while (rs.next()) {
            let item = ItemModel()
            item.id = (Int)(rs.intForColumn("id"))
            item.content = rs.stringForColumn("content")
            item.completed = rs.boolForColumn("completed")
            
            items.append(item)
        }
        
        let _ : Bool = database.close()
        
        return items
    }
    
    func insertItem(item: ItemModel) {
        
    }
    
    func updateItem(item: ItemModel) -> Bool {
        return true
    }
    
    func deleteItem(itemId: Int) {
        
    }
}