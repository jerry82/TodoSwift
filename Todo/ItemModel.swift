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
    
    init() {
        id = 0
        content = ""
        completed = false
    }
    
    init(id: Int?, content: String) {
        self.id = (id)!
        self.content = content
        self.completed = false
    }
    
    
}