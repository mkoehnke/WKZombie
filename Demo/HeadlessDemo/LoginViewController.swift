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
    
    lazy var headless : Headless = {
        return Headless(name: "Developer Portal")
    }()
    
    @IBAction func loginButtonTouched(button: UIButton) {
        button.enabled = false
        activityIndicator.startAnimating()
        getProvisioningProfiles(url).start { [weak self] result in
            switch result {
            case .Success(let columns): self?.handleSuccess(columns)
            case .Error(let error): self?.handleError(error)
            }
        }
    }
    
    //========================================
    // MARK: HTML Navigation
    //========================================
    
    func getProvisioningProfiles(url: NSURL) -> Action<[HTMLTableColumn]> {
        return headless.get(url)
           >>> headless.find("name", "form2")
           >>> submitForm
           >>> headless.find("href", "/account/")
           >>> headless.click
           >>> headless.find("href", "/account/ios/profile/profileList.action")
           >>> headless.click(0.5)
           >>> headless.findAll("aria-describedby", "grid-table_name")
    }
    
    func submitForm(form: HTMLForm) -> Action<HTMLPage> {
        form["appleId"] = nameTextField.text
        form["accountPassword"] = passwordTextField.text
        return headless.submit(2.0)(form: form)
    }
    
    //========================================
    // MARK: Handle Result
    //========================================
    
    func handleSuccess(columns: [HTMLTableColumn]) {
        self.performSegueWithIdentifier("detailSegue", sender: columns)
    }
    
    func handleError(error: ActionError) {
        self.loginButton.enabled = true
        self.activityIndicator.stopAnimating()
        print(error)
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
