//
//  HTMLClickable.swift
//  WKZombieDemo
//
//  Created by Mathias Köhnke on 06/04/16.
//  Copyright © 2016 Mathias Köhnke. All rights reserved.
//

import Foundation

/// Base class for clickable HTML elements (e.g. HTMLLink, HTMLButton).
public class HTMLClickable : HTMLElement {

    //========================================
    // MARK: Initializer
    //========================================
    
    public required init?(element: AnyObject, XPathQuery: String? = nil) {
        super.init(element: element, XPathQuery: XPathQuery)
    }
    
    //========================================
    // MARK: Link Click Script
    //========================================
    
    internal func actionScript() -> String? {
        if let onClick = objectForKey("onClick") {
            return onClick
        }
        return nil
    }
}