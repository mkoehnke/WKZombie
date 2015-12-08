//
//  ViewController.swift
//  HeadlessDemo
//
//  Created by Mathias Köhnke on 23/11/15.
//  Copyright © 2015 Mathias Köhnke. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var items : [HTMLTableColumn]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Provisioning Profiles"
        navigationItem.hidesBackButton = true
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = items?[indexPath.row].text
        return cell
    }
}

