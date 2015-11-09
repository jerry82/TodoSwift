//
//  ViewController.swift
//  Todo
//
//  Created by Jerry on 4/10/15.
//  Copyright © 2015 jstudio. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    
    let dbManager = DBManager()
    var objects = [AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        objects = dbManager.selectAllGroups()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count total: \(objects.count)")
        return objects.count
    }
    
    //define how the cell looks
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        let anyObject = objects[indexPath.row]
        
        if let group = anyObject as? GroupModel {
            cell.textLabel?.text = group.content
        }
        else {
            let item = anyObject as? ItemModel
            cell.textLabel?.text = item!.content
        }
        
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //row selected
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedItem : AnyObject = objects[indexPath.row]
        
        var indexArray = [NSIndexPath]()
        
        if let selectedGroup = selectedItem as? GroupModel {
            let items = dbManager.getItems(selectedGroup.id)
            
            var curId = indexPath.row
            for item in items {
                objects.insert(item, atIndex: curId++)
                let path = NSIndexPath(forRow: curId, inSection: 0)
                indexArray.append(path)
            }
            print("selected")
        }
        else {
            
        }
        
        self.tableView.insertRowsAtIndexPaths(indexArray, withRowAnimation: UITableViewRowAnimation.Automatic)
    }
}

