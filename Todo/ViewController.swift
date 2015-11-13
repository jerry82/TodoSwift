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
    var objectTree = [(ItemModel, [ItemModel])]()
    
    var newGroupField: UITextField!
    var newItemField: UITextField!
    
    var activeTextField: UITextField!
    
    var currentSelectedGroupId: Int = -1
    var frameChanged = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        self.tableView.rowHeight = Utility.TABLECELL_ROW_HEIGHT
        /*
        let add = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addButtonTap:")
        self.navigationItem.rightBarButtonItem = add
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.tableView.addGestureRecognizer(tap)
        */
        
        initObjects()
    }
    
    //handle keyboard
    func dismissKeyboard() {
        self.newGroupField.resignFirstResponder()
        print("outside tap")
    }
    
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
            frame.size.height -= keyboardHeight
            self.tableView.frame = frame
            self.frameChanged = true
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
    
    //textfield delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if let newGroupF = self.newGroupField  {
            if (textField == newGroupF) {
                
                if (textField.text != "") {
                    let newGroup = ItemModel()
                    newGroup.content = newGroupF.text!
                    newGroup.type = ItemEnum.L1
                    newGroup.id = dbManager.insertGroup(newGroup)
                    print(newGroup.id)
                    
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
                    dbManager.insertItem(newItem)
                    self.insertItem(newItem)
                    newItemF.text = ""
                }
                newItemF.resignFirstResponder()
                self.scrollToLastItem()
            }
        }
        
        return true
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let flatArray = getFlatArray()
        return flatArray.count
    }
    
    //define how the cell looks
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: CellObject = tableView.dequeueReusableCellWithIdentifier("Cell") as! CellObject
        let flatArray = getFlatArray()
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
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Delete", handler: {
            (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            
            let tupleId = self.getSelectedGroupId(indexPath.row)
            
            if (tupleId.0 != -1) { //group is selected
                
                self.dbManager.deleteGroup(tupleId.0)
                print("delete groupid: \(tupleId.0)")
                self.initObjects()
                self.tableView.reloadData()
            }
            else if (tupleId.1 != -1) { //item is selected
                print("delete itemid: \(tupleId.1)")
                
                self.dbManager.deleteItem(tupleId.1)
                self.removeFromObjectTree(tupleId.1)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            
        })
        
        return [delete]
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
        
        let selectedId = getSelectedGroupId(indexPath.row)
        
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

            let isExp: Bool = isExpanded(selectedId.0)
            let idx = getGroupTupleIdx(selectedId.0)
            let cell: CellObject = self.tableView.cellForRowAtIndexPath(indexPath) as! CellObject
            
            //collapse
            if (isExp) {
                
                cell.changeToCollapseSign()
                
                objectTree[idx!].1.removeAll()
                self.tableView.deleteRowsAtIndexPaths(indexArray, withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            else {
                cell.changeToExpandSign()
                
                objectTree[idx!].1 = items
                
                currentSelectedGroupId = selectedId.0 //used to insert item
                
                self.tableView.insertRowsAtIndexPaths(indexArray, withRowAnimation: UITableViewRowAnimation.Automatic)

                collapseOtherCell(selectedId.0)
                
                self.scrollToLastItem()
                
            }
            
        }
        //select item: complete the item
        else if (selectedId.1 != -1){
            let cell: CellObject = self.tableView.cellForRowAtIndexPath(indexPath) as! CellObject
            let item = self.getFlatArray()[indexPath.row]
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
    
    func scrollToLastItem() {
        let indexPath = NSIndexPath(forRow: self.getFlatArray().count - 1, inSection: 0);
        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
    }
    
    func collapseOtherCell(currentSelectedGroupId: Int) {
        
        var idx = -1
        var cnt = 0
        for i in 0..<objectTree.count {
            if (objectTree[i].0.id != currentSelectedGroupId) {
                if (objectTree[i].1.count > 0) {
                    cnt = objectTree[i].1.count
                    idx = getIdxInFlatArray(objectTree[i].0.id) + 1
                    objectTree[i].1.removeAll()
                }
            }
        }
        
        if (idx != -1) {
            var indexArray = [NSIndexPath]()
            for _ in 0..<cnt {
                let path = NSIndexPath(forRow: idx++, inSection: 0)
                indexArray.append(path)
            }
            self.tableView.deleteRowsAtIndexPaths(indexArray, withRowAnimation: UITableViewRowAnimation.None)
        }
        
        //change sign to other groups
        var flatArray = self.getFlatArray()
        for i in 0..<flatArray.count {
            if (flatArray[i].id != currentSelectedGroupId && flatArray[i].type == ItemEnum.L1) {
                let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as? CellObject
                cell?.changeToCollapseSign()
            }
        }
    }
    

    
    //helpers
    func initObjects() {
        
        objectTree.removeAll()
        
        let dummyGroup = ItemModel()
        dummyGroup.type = ItemEnum.L1_Dummy
        objectTree.append(dummyGroup, [ItemModel]())
        
        
        let groups = dbManager.selectAllGroups()
        for group in groups {
            objectTree.append(group, [ItemModel]())
        }
    }
    
    func insertGroup(item: ItemModel) {
        objectTree.append(item, [ItemModel]())
        let flatArray = self.getFlatArray()
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: flatArray.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func insertItem(item: ItemModel) {
        
        //find the L2_dummy cell
        var addIdx = -1
        var flatArray = self.getFlatArray()
        for i in 0..<flatArray.count {
            if (flatArray[i].type == ItemEnum.L2_Dummy) {
                addIdx = i
                break;
            }
        }
        
        for i in 0..<objectTree.count {
            if (objectTree[i].0.id == self.currentSelectedGroupId) {
                let cnt = objectTree[i].1.count
                objectTree[i].1.insert(item, atIndex: cnt - 1)
            }
        }
        
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: addIdx, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    
    func removeFromObjectTree(itemId: Int) {
        for i in 0..<objectTree.count {
            for idx in 0..<objectTree[i].1.count {
                if (objectTree[i].1[idx].id == itemId) {
                    objectTree[i].1.removeAtIndex(idx)
                    break
                }
            }
        }
    }
    
    
    func getGroupTupleIdx(groupId: Int) -> Int? {
        for i in 0..<objectTree.count {
            if (objectTree[i].0.id == groupId) {
                return i
            }
        }
        return nil
    }
    
    func isExpanded(groupId: Int) -> Bool {
        
        for val in objectTree {
            if (groupId == val.0.id) {
                return val.1.count > 0
            }
        }
        return false
    }
    
    //return (groupId, itemId)
    func getSelectedGroupId(indexPathRow: Int) -> (Int, Int) {
        
        let flatArray = getFlatArray()
        let item = flatArray[indexPathRow]
        if (item.type == ItemEnum.L1) {
            return (item.id, -1)
        }
        else if (item.type == ItemEnum.L2) {
            return (-1, item.id)
        }
        
        return (-1, -1)
    }
    
    func getIdxInFlatArray(selectedId: Int) -> Int {
        var flatArray = self.getFlatArray()
        
        for i in 0..<flatArray.count {
            if (flatArray[i].id == selectedId) {
                return i
            }
        }
        return -1
    }
    
    func getFlatArray() -> [ItemModel] { //parse the objects to flat array
        var flatArray = [ItemModel]()
        for val in objectTree {
            flatArray.append(val.0)
            
            for item in val.1 {
                flatArray.append(item)
            }
        }
        return flatArray
    }
    
    func getIdxDummySubItemField() -> Int {
        let flatArray = self.getFlatArray()
        
        for i in 0..<flatArray.count {
            if (flatArray[i].type == ItemEnum.L2_Dummy) {
                return i
            }
        }
        return -1
    }
}

