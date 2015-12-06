//
//  ViewController.swift
//  HeadlessDemo
//
//  Created by Mathias Köhnke on 23/11/15.
//  Copyright © 2015 Mathias Köhnke. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var rows : [TableColumn]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Provisioning Profiles"
        navigationItem.hidesBackButton = true
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows?.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = rows?[indexPath.row].text
        return cell
    }
}

