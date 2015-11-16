//
//  ViewController.swift
//  Todo
//
//  Created by Jerry on 4/10/15.
//  Copyright © 2015 jstudio. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet var tableView: UITableView!
    
    let dbManager = DBManager()
    
    var newGroupField: UITextField!
    var newItemField: UITextField!
    var activeTextField: UITextField!
    
    var currentSelectedGroupId: Int = -1
    var frameChanged = false
    
    //only allow the application to run portrait mode
    var tableWithKeyboardFrameHeight: CGFloat = 0
    
    // MARK: View Delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        self.tableView.rowHeight = CellConfig.TABLECELL_ROW_HEIGHT
        
        JDataTree.initObjects()
    }
    
    // MARK: Keyboard Handlers
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            
            self.shortenTableViewHeight(keyboardSize.height)
            if (self.activeTextField != nil) {
                let rect = self.tableView.convertRect(self.activeTextField.bounds, fromView: self.activeTextField)
                self.tableView.scrollRectToVisible(rect, animated: true)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.resetTableViewHeight(keyboardSize.height)
        }
        
    }
    
    func shortenTableViewHeight(keyboardHeight: CGFloat) {
        if (!self.frameChanged) {
            var frame = self.tableView.frame
            
            //prevent the frame not shrink futher
            if (frame.size.height > self.tableWithKeyboardFrameHeight) {
                frame.size.height -= keyboardHeight
            }
            
            self.tableView.frame = frame
            self.frameChanged = true
            
            if (self.tableWithKeyboardFrameHeight == 0) {
                self.tableWithKeyboardFrameHeight = frame.size.height
            }
        }
    }
    
    func resetTableViewHeight(keyboardHeight: CGFloat) {
        if (self.frameChanged) {
            var frame = self.tableView.frame
            frame.size.height += keyboardHeight
            self.tableView.frame = frame
            self.frameChanged = false
        }
    }
    
    // MARK: Textfields' Handlers
    func textFieldDidBeginEditing(textField: UITextField) {
        self.activeTextField = textField
        
        if (self.activeTextField == self.newGroupField) {
            if (self.newItemField != nil) {
                self.newItemField.resignFirstResponder()
                self.newItemField.text = ""
            }
        }
        else if (self.activeTextField == self.newItemField) {
            if (self.newGroupField != nil) {
                self.newGroupField.resignFirstResponder()
                self.newGroupField.text = ""
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if let newGroupF = self.newGroupField  {
            if (textField == newGroupF) {
                
                if (textField.text != "") {
                    let newGroup = ItemModel()
                    newGroup.content = newGroupF.text!
                    newGroup.type = ItemEnum.L1
                    newGroup.parentId = -1
                    newGroup.id = dbManager.insertItem(newGroup)
                    
                    if (newGroup.id != -1) {
                        self.insertGroup(newGroup)
                        newGroupF.text = ""
                    }
                    //TODO: handle error
                    else {
                        print("Error: insert group")
                    }
                }

                newGroupF.resignFirstResponder()
                self.scrollToLastItem()
                return true
            }
        }
        
        if let newItemF = self.newItemField {
            if (textField == newItemF) {
                if (newItemF.text != "") {
                    let newItem = ItemModel()
                    newItem.content = newItemF.text!
                    newItem.completed = false
                    newItem.parentId = self.currentSelectedGroupId
                    newItem.type = ItemEnum.L2
                    newItem.id = dbManager.insertItem(newItem)
                    self.insertItem(newItem)
                    newItemF.text = ""
                }
                newItemF.resignFirstResponder()
                self.scrollToLastItem()
            }
        }
        
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool { //set max character length of UITextField
        
        let maxLength = AppConfig.ITEM_CONTENT_LENGTH
        let currentString: NSString = textField.text!;
        let newString: NSString = currentString.stringByReplacingCharactersInRange(range, withString: string)
        
        return newString.length <= maxLength
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return JDataTree.getFlatArray().count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: CellObject = tableView.dequeueReusableCellWithIdentifier("Cell") as! CellObject
        let flatArray = JDataTree.getFlatArray()
        let item = flatArray[indexPath.row]
        
        cell.initWithStyle(item)
        
        if (item.type == ItemEnum.L1_Dummy) {
            cell.newItem.delegate = self
            self.newGroupField = cell.newItem
        }

        if (item.type == ItemEnum.L2_Dummy) {
            cell.newSubItem.delegate = self
            self.newItemField = cell.newSubItem
        }
        
        return cell
    }
    
    //only edit cell without no textfield
    //throw un-necessary error
    /*
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let flatArray = self.getFlatArray()
        
        if (indexPath.row < flatArray.count) {
            let type = flatArray[indexPath.row].type
            return (type != ItemEnum.L2_Dummy && type != ItemEnum.L1_Dummy)
        }
        return false
    }*/
    
    //delete cells
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        var actions = [UITableViewRowAction]()
        let tupleId = JDataTree.getSelectedGroupId(indexPath.row)
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Delete", handler: {
            (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            
            if (tupleId.0 != -1) { //group is selected
                self.dbManager.deleteGroup(tupleId.0)
                JDataTree.initObjects()
                self.tableView.reloadData()
            }
            else if (tupleId.1 != -1) { //item is selected
                self.dbManager.deleteItem(tupleId.1)
                JDataTree.removeFromObjectTree(tupleId.1)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        })
        
        actions.append(deleteAction)
        
        if (tupleId.0 != -1) { //if row is Group:
            let cleanAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Clean", handler: {
                (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
                
                self.dbManager.deleteCompletedItem(tupleId.0)
                let idxArray = JDataTree.cleanCompletedItems(tupleId.0)
                
                var indexPaths = [NSIndexPath]()
                for i in idxArray {
                    indexPaths.append(NSIndexPath(forRow: i, inSection: 0))
                }
                self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
                
                self.tableView.setEditing(false, animated: true)
            })
            actions.append(cleanAction)
        }
        
        return actions
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (self.activeTextField != nil) {
            self.activeTextField.text = ""
            self.activeTextField.resignFirstResponder()
        }
        
        let selectedId = JDataTree.getSelectedGroupId(indexPath.row)
        
        if (selectedId.0 != -1) {
            
            var items = dbManager.getItems(selectedId.0)
            //add dummy item here
            
            let dummyItem = ItemModel()
            dummyItem.type = ItemEnum.L2_Dummy
            items.append(dummyItem)
            
            var indexArray = [NSIndexPath]()
            var curId = indexPath.row + 1
            for _ in items {
                let path = NSIndexPath(forRow: curId++, inSection: 0)
                indexArray.append(path)
            }

            let isExp: Bool = JDataTree.isExpanded(selectedId.0)
            let idx = JDataTree.getGroupTupleIdx(selectedId.0)
            let cell: CellObject = self.tableView.cellForRowAtIndexPath(indexPath) as! CellObject
            
            //collapse
            if (isExp) {
                
                cell.changeSign(true)
                
                JDataTree.assignSubItems(idx!, items: nil)
                
                self.tableView.deleteRowsAtIndexPaths(indexArray, withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            else {
                cell.changeSign(false)
                
                JDataTree.assignSubItems(idx!, items: items)
                
                currentSelectedGroupId = selectedId.0 //used to insert item
                
                self.tableView.insertRowsAtIndexPaths(indexArray, withRowAnimation: UITableViewRowAnimation.Automatic)

                collapseOtherCell(selectedId.0)
                
                self.scrollToLastItem()
                
            }
            
        }
        //select item: complete the item
        else if (selectedId.1 != -1){
            let cell: CellObject = self.tableView.cellForRowAtIndexPath(indexPath) as! CellObject
            let item = JDataTree.getFlatArray()[indexPath.row]
            item.completed = !item.completed
            dbManager.updateItemStatus(item)
            if (item.completed) {
                cell.strikeText()
            }
            else {
                cell.unStrikeText()
            }
        }
    }
    
    func collapseOtherCell(currentSelectedGroupId: Int) {
        
        let tuple = JDataTree.removeSubItems(currentSelectedGroupId)
        var idx = tuple.0
        let cnt = tuple.1
        
        if (idx != -1) {
            var indexArray = [NSIndexPath]()
            for _ in 0..<cnt {
                let path = NSIndexPath(forRow: idx++, inSection: 0)
                indexArray.append(path)
            }
            self.tableView.deleteRowsAtIndexPaths(indexArray, withRowAnimation: UITableViewRowAnimation.None)
        }
        
        //change sign to other groups
        var flatArray = JDataTree.getFlatArray()
        for i in 0..<flatArray.count {
            if (flatArray[i].id != currentSelectedGroupId && flatArray[i].type == ItemEnum.L1) {
                let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as? CellObject
                cell?.changeSign(true)
            }
        }
    }
    
    // MARK: Helpers
    func scrollToLastItem() {
        let indexPath = NSIndexPath(forRow: JDataTree.getFlatArray().count - 1, inSection: 0);
        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
    }
    
    func insertGroup(item: ItemModel) {
        let groupPos = JDataTree.insertGroup(item)
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: groupPos, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func insertItem(item: ItemModel) {
        let addIdx = JDataTree.insertItem(item, currentSelectedGroupId: self.currentSelectedGroupId)
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: addIdx, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
}

