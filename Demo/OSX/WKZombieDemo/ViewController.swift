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
        >>> browser.get(by: .XPathQuery("(//a[contains(@class, 'thumbnail may-blank')])[2]"))
        >>> browser.fetch(NSImage)
        === output
    }
    
    func output(result: HTMLLink?) {
        let image = result?.fetchedContent as? NSImage
        imageView.image = image
    }
}

