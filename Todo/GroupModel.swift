//
//  GroupModel.swift
//  Todo
//
//  Created by Jerry on 6/11/15.
//  Copyright © 2015 jstudio. All rights reserved.
//

import Foundation

class GroupModel {
    var id: Int
    var content: String
    
    init() {
        id = 0
        content = ""
    }
        
    init (id: Int?, content: String) {
        self.id = id!
        self.content = content
    }
}
