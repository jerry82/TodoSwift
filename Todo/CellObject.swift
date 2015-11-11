//
//  CellObject.swift
//  Todo
//
//  Created by Jerry on 9/11/15.
//  Copyright © 2015 jstudio. All rights reserved.
//

import Foundation
import UIKit

class CellObject : UITableViewCell {
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var sign: UILabel!
    @IBOutlet var newItem: UITextField!
    @IBOutlet var newSubItem: UITextField!
    
    func changeToCollapseSign() {
        self.sign.text = "+"
    }
    
    func changeToExpandSign() {
        self.sign.text = "-"
    }
}