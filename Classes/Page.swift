//
//  Page.swift
//  HeadlessDemo
//
//  Created by Mathias Köhnke on 23/11/15.
//  Copyright © 2015 Mathias Köhnke. All rights reserved.
//

import Foundation

public class Page : Parser {
        
    func formWith(name: String) -> Form? {
        return formsWith("//form[@name='\(name)']")?.first
    }
    
    func formsWith(xPathQuery: String) -> [Form]? {
        return elementsWith(xPathQuery)
    }
    
    func linkWith(name: String) ->  Link? {
        return linksWith("//a[text()='\(name)']/@href")?.first
    }
    
    func linksWith(xPathQuery: String) -> [Link]? {
        return elementsWith(xPathQuery)
    }
    
    func elementsWith<T: Element>(xPathQuery: String) -> [T]? {
        if let parsedObjects = searchWithXPathQuery(xPathQuery) where parsedObjects.count > 0 {
            return parsedObjects.flatMap { T(element: $0, pageURL: url) }
        }
        return nil
    }
    
    func tableWith(name: String) -> Table? {
        return tablesWith("//table[@name='\(name)']")?.first
    }
    
    func tablesWith(xPathQuery: String) -> [Table]? {
        return elementsWith(xPathQuery)
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