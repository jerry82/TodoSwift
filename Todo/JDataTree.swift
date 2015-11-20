//
//  JDataTree.swift
//  Todo
//
//  Created by Jerry on 13/11/15.
//  Copyright © 2015 jstudio. All rights reserved.
//

import Foundation

class JDataTree {
    
    // MARK: Variables
    static var objectTree = [(ItemModel, [ItemModel])]()
    static let dbManager = DBManager()
    
    static func initObjects() {
        objectTree.removeAll()
        addDummyGroup()
        
        let groups = dbManager.selectAllGroups()
        for group in groups {
            objectTree.append(group, [ItemModel]())
        }
    }
    
    static func addDummyGroup() {
        let dummyGroup = ItemModel()
        dummyGroup.type = ItemEnum.L1_Dummy
        objectTree.append(dummyGroup, [ItemModel]())
    }
    
    //assign list of items to the idx
    static func assignSubItems(idx: Int, items: [ItemModel]?) {
        if (items == nil) {
            objectTree[idx].1.removeAll()
        }
        else {
            objectTree[idx].1 = items!
        }
    }
    
    static func removeSubItems(groupId: Int) -> (Int, Int) {
        var idx = -1
        var cnt = 0
        for i in 0..<objectTree.count {
            if (objectTree[i].0.id != groupId) {
                if (objectTree[i].1.count > 0) {
                    cnt = objectTree[i].1.count
                    idx = getIdxInFlatArray(objectTree[i].0.id) + 1
                    objectTree[i].1.removeAll()
                }
            }
        }
        
        return (idx, cnt)
    }
    
    static func insertGroup(item: ItemModel) -> Int {
        objectTree.append(item, [ItemModel]())
        let flatArray = self.getFlatArray()
        return flatArray.count - 1
    }
    
    static func updateGroupContent(itemId: Int, content: String) -> Void {
        for i in 0..<objectTree.count {
            if (objectTree[i].0.id == itemId) {
                objectTree[i].0.content = content
                break;
            }
        }
    }
    
    static func insertItem(item: ItemModel, currentSelectedGroupId: Int) -> Int {
        
        //find the L2_dummy cell
        var addIdx = -1
        var flatArray = getFlatArray()
        for i in 0..<flatArray.count {
            if (flatArray[i].type == ItemEnum.L2_Dummy) {
                addIdx = i
                break;
            }
        }
        
        for i in 0..<objectTree.count {
            if (objectTree[i].0.id == currentSelectedGroupId) {
                let cnt = objectTree[i].1.count
                objectTree[i].1.insert(item, atIndex: cnt - 1)
            }
        }
        
        return addIdx
    }
    
    //clean completed item within group
    static func cleanCompletedItems(groupId: Int) -> [Int]{
        var indexArray = [Int]()
        
        let flatArray = self.getFlatArray()
        for i in 0..<flatArray.count {
            if (flatArray[i].type == ItemEnum.L2 &&
                flatArray[i].parentId == groupId && flatArray[i].completed) {
                indexArray.append(i)
            }
        }
        
        var unCompletedItems = [ItemModel]()
        
        for tuple in objectTree {
            if (tuple.0.id == groupId) {
                for item in tuple.1 {
                    if (!item.completed) {
                        unCompletedItems.append(item)
                    }
                }
                break;
            }
        }
        
        for i in 0..<objectTree.count {
            if (objectTree[i].0.id == groupId) {
                objectTree[i].1.removeAll()
                objectTree[i].1 = unCompletedItems
                break
            }
        }
        
        return indexArray
    }
    
    
    //remove the item
    static func removeFromObjectTree(itemId: Int) {
        for i in 0..<objectTree.count {
            for idx in 0..<objectTree[i].1.count {
                if (objectTree[i].1[idx].id == itemId) {
                    objectTree[i].1.removeAtIndex(idx)
                    break
                }
            }
        }
    }
    
    //get idx of group by groupId
    static func getGroupTupleIdx(groupId: Int) -> Int? {
        for i in 0..<objectTree.count {
            if (objectTree[i].0.id == groupId) {
                return i
            }
        }
        return nil
    }
    
    //check whether the group is expanded ?
    static func isExpanded(groupId: Int) -> Bool {
        for val in objectTree {
            if (groupId == val.0.id) {
                return val.1.count > 0
            }
        }
        return false
    }
    
    //return (groupId, itemId)
    static func getSelectedGroupId(indexPathRow: Int) -> (Int, Int) {
        
        let item = getFlatArray()[indexPathRow]

        switch (item.type) {
        case ItemEnum.L1:
            return (item.id, -1)
        case ItemEnum.L2:
            return (-1, item.id)
        default:
            return (-1, -1)
        }
    }
    
    static func getIdxInFlatArray(selectedId: Int) -> Int {
        var flatArray = getFlatArray()
        for i in 0..<flatArray.count {
            if (flatArray[i].id == selectedId) {
                return i
            }
        }
        return -1
    }
    
    static func getFlatArray() -> [ItemModel] { //parse the objects to flat array
        var flatArray = [ItemModel]()
        for val in objectTree {
            flatArray.append(val.0)
            
            for item in val.1 {
                flatArray.append(item)
            }
        }
        return flatArray
    }
    
    static func getIdxDummySubItemField() -> Int {
        let flatArray = getFlatArray()
        
        for i in 0..<flatArray.count {
            if (flatArray[i].type == ItemEnum.L2_Dummy) {
                return i
            }
        }
        return -1
    }
}