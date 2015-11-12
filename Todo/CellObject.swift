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
    
    let groupFont = UIFont(name: "HelveticaNeue-Bold", size: 19)!
    let itemFont = UIFont(name: "HelveticaNeue", size: 17)
    let itemBgColor = UIColor(netHex: 0xdbfffb)
    let groupBgColor = UIColor.whiteColor()

    func initWithStyle(item: ItemModel) {
        
        switch (item.type) {
        case ItemEnum.L1:
            self.sign.text = "+"
            self.contentLabel.text = item.content
            self.sign.hidden = false
            self.contentLabel.hidden = false
            self.newItem.hidden = true
            self.newSubItem.hidden = true
            self.selectionStyle = UITableViewCellSelectionStyle.None
            
            self.decorateGroupLabel()
            
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
            self.backgroundColor = self.groupBgColor
            self.newItem.placeholder = "> New Group"
            self.selectionStyle = UITableViewCellSelectionStyle.None

        default:
            self.newSubItem.hidden = false
            self.contentLabel.hidden = true
            self.sign.hidden = true
            self.newItem.hidden = true
            self.newSubItem.placeholder = "> New Item"
            self.selectionStyle = UITableViewCellSelectionStyle.None
            self.decorateItemLabel()
        }
        
        self.contentLabel.sizeToFit()
        self.contentLabel.numberOfLines = 0;
        self.contentLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
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
        self.contentLabel.font = self.groupFont
        self.backgroundColor = self.groupBgColor
    }
    
    func decorateItemLabel() {
        self.contentLabel.font = self.itemFont
        self.backgroundColor = self.itemBgColor
        self.contentLabel.textColor = UIColor.blackColor()
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}