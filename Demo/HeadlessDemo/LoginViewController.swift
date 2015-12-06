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
    @IBOutlet weak var loginButton : UIButton!
    
    let url = NSURL(string: "https://developer.apple.com/membercenter/index.action")!
    
    lazy var headless : Headless = {
        return Headless(name: "DeveloperPortal")
    }()
    
    @IBAction func loginButtonTouched(button: UIButton) {
        button.enabled = false
        activityIndicator.startAnimating()
        getProvisioningProfiles(url).start { [weak self] result in
            switch result {
            case .Success(let table): self?.handleSuccess(table)
            case .Error(let error): self?.handleError(error)
            }
        }
    }
    
    // MARK: HTML Navigation
    
    func getProvisioningProfiles(url: NSURL) -> Future<Table, Error> {
        return headless.get(url) >>> submitLoginForm >>> getAccountOverview >>> getProfilesPage >>> getProfilesTable
    }
    
    func submitLoginForm(page: Page) -> Future<Page, Error> {
        let result = page.formWithName("form2")
        switch result {
        case .Success(let form):
            form["appleId"] = nameTextField.text
            form["accountPassword"] = passwordTextField.text
            return headless.submit(2.0)(form: form)
        case .Error(let error): return Future(error: error)
        }
    }
    
    func getAccountOverview(page: Page) -> Future<Page, Error> {
        let link = Future(result: page.firstLinkWithAttribute("href", value: "/account/"))
        return link >>> headless.click
    }
    
    func getProfilesPage(page: Page) -> Future<Page, Error> {
        let link = Future(result: page.firstLinkWithAttribute("href", value: "/account/ios/profile/profileList.action"))
        return link >>> headless.click(0.5)
    }
    
    func getProfilesTable(page: Page) -> Future<Table, Error> {
        return Future(result: page.firstTableWithAttribute("id", value: "grid-table"))
    }
    
    // MARK: Handle Result
    
    func handleSuccess(table: Table) {
        let columns = table.columnsWithPattern("aria-describedby", value: "grid-table_name")
        performSegueWithIdentifier("detailSegue", sender: columns)
    }
    
    func handleError(error: Error) {
        loginButton.enabled = true
        activityIndicator.stopAnimating()
        print(error)
    }
    
    // MARK: Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailSegue" {
            let vc = segue.destinationViewController as? ViewController
            vc?.items = sender as? [TableColumn]
        }
    }
}
