//
//  Page.swift
//  HeadlessDemo
//
//  Created by Mathias Köhnke on 23/11/15.
//  Copyright © 2015 Mathias Köhnke. All rights reserved.
//

import Foundation
import hpple

public class Page : Parser {
        
    func formWith(name: String) -> Form? {
        return formsWith("//form[@name='\(name)']")?.first
    }
    
    func formsWith(xPathQuery: String) -> [Form]? {
        if let parsedObjects = searchWithXPathQuery(xPathQuery) {
            return parsedObjects.flatMap { Form(element: $0, baseURL: url) }
        }
        return nil
    }
    
    func linkWith(name: String) ->  Link? {
        if let parsedObject = searchWithXPathQuery("//a[text()='\(name)']/@href")?.first {
            return Link(element: parsedObject, baseURL: url?.baseURL ?? url)
        }
        return nil
    }
    
    func elementsWith(xPathQuery: String) -> [Element]? {
        if let parsedObjects = searchWithXPathQuery(xPathQuery) {
            return parsedObjects.flatMap { Element(element: $0) }
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