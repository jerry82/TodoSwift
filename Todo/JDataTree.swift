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
    
    static func initObjects() {
        objectTree.removeAll()
        addDummyGroup()
    }
    
    static func addDummyGroup() {
        let dummyGroup = ItemModel()
        dummyGroup.type = ItemEnum.L1_Dummy
        objectTree.append(dummyGroup, [ItemModel]())
    }
    
    static func getGroupTupleIdx(groupId: Int) -> Int? {
        for i in 0..<objectTree.count {
            if (objectTree[i].0.id == groupId) {
                return i
            }
        }
        return nil
    }
    
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