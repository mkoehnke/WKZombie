//
//  Link.swift
//  HeadlessDemo
//
//  Created by Mathias Köhnke on 23/11/15.
//  Copyright © 2015 Mathias Köhnke. All rights reserved.
//

import Foundation

public class Link : Element {
    
    public private(set) var baseURL : NSURL?

    public var href : String? {
        return parsedObject?.text()
    }
    
    public var hrefURL : NSURL? {
        if let href = href, url = NSURL(string: href) {
            if let baseURL = baseURL where url.scheme.characters.count == 0 {
                return NSURL(string: url.relativePath!, relativeToURL: baseURL)
            }
            return url
        }
        return nil
    }
    
    public init?(parsedObject: AnyObject, baseURL: NSURL? = nil) {
        super.init(parsedObject: parsedObject)
        self.baseURL = baseURL
    }
    
    override public var description : String {
        return href ?? ""
    }
}

// attributes
// href
// text

// click()


    