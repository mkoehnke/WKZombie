//
//  ViewController.swift
//  WKZombieDemo
//
//  Created by Mathias Köhnke on 25/01/16.
//  Copyright © 2016 Mathias Köhnke. All rights reserved.
//

import Cocoa
import WKZombie

class ViewController: NSViewController {

    @IBOutlet weak var imageView : NSImageView!
    @IBOutlet weak var textLabel : NSTextField!
    
    let url = NSURL(string: "https://www.reddit.com")!
    
    lazy var browser : WKZombie = {
        return WKZombie(name: "Reddit")
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getTopTrendingEntry(url)
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


    func getTopTrendingEntry(url: NSURL) {
            browser.open(url)
        >>> browser.get(by: .Text("pics"))
        >>> browser.click
        >>> browser.getAll(by: .XPathQuery("//a[contains(@class, 'title may-blank')]"))
        === output
    }
    
    func output(links: [HTMLLink]?) {
        if let link = links?[1] {
            print(link.objectForKey("href"))
            textLabel.attributedStringValue = NSAttributedString(string: link.text ?? "")
        }

        
    }
}

