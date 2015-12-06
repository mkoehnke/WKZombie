//
//  LoginViewController.swift
//  HeadlessDemo
//
//  Created by Mathias Köhnke on 28/11/15.
//  Copyright © 2015 Mathias Köhnke. All rights reserved.
//

import UIKit

class LoginViewController : UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let url = NSURL(string: "https://developer.apple.com/membercenter/index.action")!
    
    lazy var headless : Headless = {
        return Headless(name: "DeveloperPortal")
    }()
    
    @IBAction func loginButtonTouched(button: UIButton) {
        button.enabled = false
        activityIndicator.startAnimating()
        
        getProvisioningProfiles(url).start { [weak self] result in
            switch result {
            case .Success(let table):
                let columns = table.columnsWithPattern("aria-describedby", value: "grid-table_name")
                self?.performSegueWithIdentifier("detailSegue", sender: columns)
            case .Error(let error):
                button.enabled = true
                self?.activityIndicator.stopAnimating()
                print(error)
            }
        }
    }
    
    func getProvisioningProfiles(url: NSURL) -> Future<Table, Error> {
        return headless.get(url) >>> submitLoginForm >>> getAccountOverview >>> getProfilesPage >>> getProfilesTable
    }
    
    func submitLoginForm(page: Page) -> Future<Page, Error> {
        if let form = page.formWith("form2") {
            form["appleId"] = nameTextField.text
            form["accountPassword"] = passwordTextField.text
            return headless.submit(form, wait: 1.5)
        }
        return Future(error: Error.NetworkRequestFailure)
    }
    
    func getAccountOverview(page: Page) -> Future<Page, Error> {
        if let link = page.linksWith("//a[contains(@href,'/account/')]/@href")?.first {
            return headless.click(link)
        }
        return Future(result: Result.Error(.NotFound))
    }
    
    func getProfilesPage(page: Page) -> Future<Page, Error> {
        if let link = page.linksWith("//a[contains(@href,'ios') and contains(@href, 'profileList')]/@href")?.first {
            return headless.click(link, wait: 0.5)
        }
        return Future(result: Result.Error(.NotFound))
    }
    
    func getProfilesTable(page: Page) -> Future<Table, Error> {
        if let table = page.tablesWith("//table[@id='grid-table']")?.first {
            return Future(result: Result.Success(table))
        }
        return Future(result: Result.Error(.NotFound))
    }
    
    
    // MARK: Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailSegue" {
            let vc = segue.destinationViewController as? ViewController
            vc?.rows = sender as? [TableColumn]
        }
    }
}
