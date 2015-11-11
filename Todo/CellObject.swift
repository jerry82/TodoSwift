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

    func initWithStyle(item: ItemModel) {
        
        self.contentLabel.textColor = UIColor.blackColor()
        
        switch (item.type) {
        case ItemEnum.L1:
            self.sign.text = "+"
            self.contentLabel.text = item.content
            self.sign.hidden = false
            self.contentLabel.hidden = false
            self.newItem.hidden = true
            self.newSubItem.hidden = true
            self.decorateGroupLabel()
            
            self.selectionStyle = UITableViewCellSelectionStyle.Default
        case ItemEnum.L2:
            self.sign.text = ""
            self.contentLabel.text = item.content
            self.sign.hidden = false
            self.contentLabel.hidden = false
            self.newItem.hidden = true
            self.newSubItem.hidden = true
            self.selectionStyle = UITableViewCellSelectionStyle.None
            self.decorateItemLabel()
            
            if (item.completed) {
                self.strikeText()
            }
            
        case ItemEnum.L1_Dummy:
            self.contentLabel.hidden = true
            self.sign.hidden = true
            self.newItem.hidden = false
            self.newSubItem.hidden = true
            self.selectionStyle = UITableViewCellSelectionStyle.None

        default:
            self.newSubItem.hidden = false
            self.contentLabel.hidden = true
            self.sign.hidden = true
            self.newItem.hidden = true
            self.newSubItem.placeholder = "Add Item Here"
            self.selectionStyle = UITableViewCellSelectionStyle.None
        }
    }
    
    func changeToCollapseSign() {
        self.sign.text = "+"
    }
    
    func changeToExpandSign() {
        self.sign.text = "-"
    }
    
    func strikeText() {
        let attString = NSMutableAttributedString.init(string: self.contentLabel.text!)
        attString.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: NSMakeRange(0, attString.length))
        
        self.contentLabel.attributedText = attString
        self.contentLabel.textColor = UIColor.grayColor()
    }
    
    func unStrikeText() {
        self.contentLabel.attributedText = NSMutableAttributedString.init(string: self.contentLabel.text!)
        self.contentLabel.textColor = UIColor.blackColor()
    }
    
    func decorateGroupLabel() {
        //let currentFont = self.contentLabel.font
        //let boldFont = currentFont.fontName + "-Bold"
        //self.contentLabel.font = UIFont(name: boldFont, size: currentFont.pointSize + 2)
        self.contentLabel.textColor = UIColor.blackColor()
    }
    
    func decorateItemLabel() {
        //let currentFont = self.contentLabel.font
        //let boldFont = currentFont.fontName
        //self.contentLabel.font = UIFont(name: boldFont, size: currentFont.pointSize)
        self.contentLabel.textColor = UIColor.blackColor()
    }
}