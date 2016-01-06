//
// LoginViewController.swift
//
// Copyright (c) 2015 Mathias Koehnke (http://www.mathiaskoehnke.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

class LoginViewController : UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton : UIButton!
    
    let url = NSURL(string: "https://developer.apple.com/membercenter/index.action")!
    
    lazy var browser : Headless = {
        return Headless(name: "Developer Portal")
    }()
    
    @IBAction func loginButtonTouched(button: UIButton) {
        guard let user = nameTextField.text, password = passwordTextField.text else { return }
        button.enabled = false
        activityIndicator.startAnimating()
        getProvisioningProfiles(url, user: user, password: password)
    }
    
    //========================================
    // MARK: HTML Navigation
    //========================================
    
    func getProvisioningProfiles(url: NSURL, user: String, password: String) {
               browser.open(url)
           >>> browser.get(by: .Id("accountname"))
           >>> browser.setAttribute("value", value: user)
           >>> browser.get(by: .Id("accountpassword"))
           >>> browser.setAttribute("value", value: password)
           >>> browser.get(by: .Name("form2"))
           >>> browser.submit(then: .Wait(2.0))
           >>> browser.get(by: .Attribute("href", "/account/"))
           >>> browser.click
           >>> browser.get(by: .Attribute("href", "/account/ios/profile/profileList.action"))
           >>> browser.click(then: .Wait(0.5))
           >>> browser.getAll(by: .Attribute("aria-describedby", "grid-table_name"))
           === output
    }
    
    //========================================
    // MARK: Handle Result
    //========================================
    
    func output(columns: [HTMLTableColumn]?) {
        if let columns = columns {
            performSegueWithIdentifier("detailSegue", sender: columns)
        } else {
            loginButton.enabled = true
            activityIndicator.stopAnimating()
            browser.dump()
        }
    }
    
    //========================================
    // MARK: Segue
    //========================================
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailSegue" {
            let vc = segue.destinationViewController as? ViewController
            vc?.items = sender as? [HTMLTableColumn]
        }
    }
}
