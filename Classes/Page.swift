//
//  Page.swift
//  HeadlessDemo
//
//  Created by Mathias Köhnke on 23/11/15.
//  Copyright © 2015 Mathias Köhnke. All rights reserved.
//

import Foundation

public class Page : NSObject {
    
    public private(set) var url : NSURL?
    private var doc : TFHpple!
    
    init(data: NSData, url: NSURL? = nil) {
        super.init()
        self.doc = TFHpple(HTMLData: data)
        self.url = url
    }
    
    func formWith(name: String) -> Form? {
        if let parsedObject = doc.searchWithXPathQuery("//form[@name='\(name)']").first as? TFHppleElement {
            return Form(parsedObject: parsedObject)
        }
        return nil
    }
    
    func linkWith(name: String) ->  Link? {
        if let parsedObject = doc.searchWithXPathQuery("//a[text()='\(name)']/@href").first as? TFHppleElement {
            return Link(parsedObject: parsedObject, baseURL: url?.baseURL ?? url)
        }
        return nil
    }
    
    func elementsWith(criteria: String) -> [Element]? {
        if let parsedObjects = doc.searchWithXPathQuery(criteria) as? [TFHppleElement] {
            return parsedObjects.map { Element(parsedObject: $0)! }
        }
        return nil
    }
    
    // formWith(criteria)
    // formsWith(name)
    // frameWith
    // frames
    // images
    // imageWith(criteria)
    // linkWith(criteria)
    // links
    // title
    
}