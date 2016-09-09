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
import WKZombie

class LoginViewController : UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton : UIButton!
    
    fileprivate let url = URL(string: "https://developer.apple.com/membercenter/index.action")!
    fileprivate var snapshots = [Snapshot]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WKZombie.sharedInstance.snapshotHandler = { [weak self] snapshot in
            self?.snapshots.append(snapshot)
        }
    }
    
    @IBAction func loginButtonTouched(_ button: UIButton) {
        guard let user = nameTextField.text, let password = passwordTextField.text else { return }
        button.isEnabled = false
        snapshots.removeAll()
        activityIndicator.startAnimating()
        getProvisioningProfiles(url, user: user, password: password)
    }
    
    //========================================
    // MARK: HTML Navigation
    //========================================
    
    func getProvisioningProfiles(_ url: URL, user: String, password: String) {
               open(url)
           >>* get(by: .id("accountname"))
           >>> setAttribute("value", value: user)
           >>* get(by: .id("accountpassword"))
           >>> setAttribute("value", value: password)
           >>* get(by: .name("form2"))
           >>> submit(then: .wait(2.0))
           >>* get(by: .contains("href", "/account/"))
           >>> click(then: .wait(2.5))
           >>* getAll(by: .contains("class", "row-"))
           === handleResult
    }
    
    //========================================
    // MARK: Handle Result
    //========================================
    
    func handleResult(_ result: Result<[HTMLTableRow]>) {
        switch result {
        case .success(let value): self.outputResult(value)
        case .error(let error): self.handleError(error)
        }
    }
    
    func outputResult(_ rows: [HTMLTableRow]) {
        let columns = rows.flatMap { $0.columns?.first }
        performSegue(withIdentifier: "detailSegue", sender: columns)
    }
    
    func handleError(_ error: ActionError) {
        print("Error loading page: \(error)")
        loginButton.isEnabled = true
        activityIndicator.stopAnimating()
        
        dump()
        clearCache()
    }
    
    //========================================
    // MARK: Segue
    //========================================
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            if let vc = segue.destination as? ProfileViewController, let items = sender as? [HTMLTableColumn] {
                vc.items = items
                vc.snapshots = snapshots
            }
        }
    }
}
