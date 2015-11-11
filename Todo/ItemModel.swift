//
//  ItemModel.swift
//  Todo
//
//  Created by Jerry on 6/11/15.
//  Copyright © 2015 jstudio. All rights reserved.
//

import Foundation

class ItemModel {
    
    var id: Int
    var content: String
    var completed: Bool
    var type: ItemEnum
    var parentId: Int
    
    init() {
        id = 0
        content = ""
        completed = false
        type = .L1
        parentId = -1
    }
    
    init(id: Int?, content: String, type: ItemEnum, parentId: Int) {
        self.id = (id)!
        self.content = content
        self.completed = false
        self.type = type
        self.parentId = parentId
    }
}

enum ItemEnum: String {
    case L1 = "L1"
    case L2 = "L2"
    case L1_Dummy = "L1_Dummy"
    case L2_Dummy = "L2_Dummy"
}