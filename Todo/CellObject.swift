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
    
    // Mark: Variables
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var sign: UILabel!
    @IBOutlet var newItem: UITextField!
    @IBOutlet var newSubItem: UITextField!
    
    var itemId: Int = -1
    
    // MARK: Initialization
    func initWithStyle(item: ItemModel) {
        
        self.itemId = item.id
        
        switch (item.type) {
        case ItemEnum.L1:
            self.displayGroup(false, content: item.content)
            self.displayTextLabel(true, item: item)
            self.displayTextFields(true, hiddenTextF2: true)
            
        case ItemEnum.L2:
            self.displayGroup(true, content: nil)
            self.displayTextFields(true, hiddenTextF2: true)
            self.displayTextLabel(false, item: item)

        case ItemEnum.L1_Dummy:
            self.displayGroup(true, content: nil)
            self.displayTextLabel(true, item: item)
            self.displayTextFields(false, hiddenTextF2: true)

        default:
            self.displayGroup(true, content: nil)
            self.displayTextLabel(true, item: item)
            self.displayTextFields(true, hiddenTextF2: false)
            self.decorateItemLabel()
        }

        self.configMultipleLines()
        self.selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    // MARK: show/hide components
    func displayGroup(hidden: Bool, content: String!) {
        self.contentLabel.hidden = hidden
        self.sign.hidden = hidden
        self.contentLabel.text = content
        self.sign.text = (self.sign.text == "") ? CellConfig.GROUP_COLLAPSE_SIGN : self.sign.text
        
        if (!hidden) {
            self.contentLabel.font = CellConfig.TABLECELL_GROUP_FONT
            self.backgroundColor = CellConfig.TABLECELL_GROUP_BGCOLOR
        }
    }
    
    func displayTextLabel(hidden: Bool, item: ItemModel) {
        if (!hidden) {
            self.textLabel?.text = item.content
            self.textLabel?.hidden = false
            self.decorateItemLabel()
            
            if (item.completed) {
                self.strikeText()
            }
        }
        else {
            self.textLabel?.hidden = true
            self.textLabel!.text = ""
        }
        
    }
    
    func displayTextFields(hiddenTextF1: Bool, hiddenTextF2: Bool) {
        self.newItem.hidden = hiddenTextF1
        self.newSubItem.hidden = hiddenTextF2
        self.newItem.placeholder = "> New Group"
        self.newSubItem.placeholder = "> New Item"
        if (!hiddenTextF1) {
            self.backgroundColor = CellConfig.TABLECELL_GROUP_BGCOLOR
        }
    }
    
    func configMultipleLines() {
        self.textLabel?.sizeToFit()
        self.textLabel?.numberOfLines = 0;
        self.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
    }
    
    func changeSign(collapse: Bool) {
        self.sign.text = collapse ? CellConfig.GROUP_COLLAPSE_SIGN : CellConfig.GROUP_EXPAND_SIGN
    }
    
    func decorateItemLabel() {
        self.textLabel?.font = CellConfig.TABLECELL_ITEM_FONT
        self.backgroundColor = CellConfig.TABLECELL_ITEM_BGCOLOR
        self.textLabel?.textColor = CellConfig.SUBITEM_UNSTRIKE_TEXTCOLOR
        self.indentationWidth = CellConfig.TABLECELL_ITEM_INDENT_WIDTH
    }
    
    // MARK: Strike Text
    func strikeText() {
        let attString = NSMutableAttributedString.init(string: (self.textLabel?.text!)!)
        attString.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: NSMakeRange(0, attString.length))
        
        self.textLabel?.attributedText = attString
        self.textLabel?.textColor = CellConfig.SUBITEM_STRIKE_TEXTCOLOR
    }
    
    func unStrikeText() {
        self.textLabel?.attributedText = NSMutableAttributedString.init(string: (self.textLabel?.text)!)
        self.textLabel?.textColor = CellConfig.SUBITEM_UNSTRIKE_TEXTCOLOR
    }
}

