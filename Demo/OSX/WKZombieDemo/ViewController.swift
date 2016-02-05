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
    @IBOutlet weak var activityIndicator : NSProgressIndicator!
    
    let url = NSURL(string: "https://www.reddit.com")!
    
    lazy var browser : WKZombie = {
        return WKZombie(name: "Reddit")
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimation(nil)
        getTopTrendingEntry(url)
    }

    func getTopTrendingEntry(url: NSURL) {
            browser.open(url)
        >>> browser.get(by: .Text("pics"))
        >>> browser.click
        >>> browser.get(by: .XPathQuery("//a[contains(@class, 'thumbnail may-blank') and contains(@href,'.jpg')]"))
        >>> browser.fetch
        === output
    }
    
    func output(result: HTMLLink?) {
        imageView.image = result?.fetchedContent()
        activityIndicator.stopAnimation(nil)
    }
}

