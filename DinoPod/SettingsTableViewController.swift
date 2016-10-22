//
//  SettingsTableViewController.swift
//  DinoPod
//
//  Created by Satbir Tanda on 8/9/15.
//  Copyright (c) 2015 Satbir Tanda. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    private let options : [String: Bool] = ["REPEAT" : DinoPodHistory.getRepeat() , "SHUFFLE" : DinoPodHistory.getShuffle()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.userInteractionEnabled = false
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Setting", forIndexPath: indexPath) 

        // Configure the cell...
        
        let settingName = Array(options.keys)[indexPath.row]
        cell.textLabel?.text = settingName
        
        let selected = Array(options.values)[indexPath.row]
        if selected {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }

        return cell
    }
    
}
