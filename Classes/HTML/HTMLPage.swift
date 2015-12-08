//
//  HTMLPage.swift
//  HeadlessDemo
//
//  Created by Mathias Köhnke on 08/12/15.
//  Copyright © 2015 Mathias Köhnke. All rights reserved.
//

import Foundation

public class HTMLPage : HTMLParser, Page {
    
    public static func pageWithData(data: NSData?, url: NSURL?) -> Page? {
        if let data = data {
            return HTMLPage(data: data, url: url)
        }
        return nil
    }
    
    public func formWithName(name: String) -> Result<HTMLForm, Error> {
        return firstElementFromResult(formsWithQuery("//form[@name='\(name)']"))
    }
    
    public func formsWithQuery(xPathQuery: String) -> Result<[HTMLForm], Error> {
        return elementsWithQuery(xPathQuery)
    }
    
    public func linkWithName(name: String) -> Result<HTMLLink, Error> {
        return firstElementFromResult(linksWithQuery("//a[text()='\(name)']/@href"))
    }
    
    public func firstLinkWithAttribute(key: String, value: String) -> Result<HTMLLink, Error> {
        return firstElementFromResult(linksWithAttribute(key, value: value))
    }
    
    public func linksWithAttribute(key: String, value: String) -> Result<[HTMLLink], Error> {
        return linksWithQuery("//a[@\(key)='\(value)']/@href")
    }
    
    public func linksWithQuery(xPathQuery: String) -> Result<[HTMLLink], Error> {
        return elementsWithQuery(xPathQuery)
    }
    
    public func firstTableWithAttribute(key: String, value: String) -> Result<HTMLTable, Error> {
        return firstElementFromResult(tablesWithAttribute(key, value: value))
    }
    
    public func tablesWithAttribute(key: String, value: String) -> Result<[HTMLTable], Error> {
        return tablesWithQuery("//table[@\(key)='\(value)']")
    }
    
    public func tablesWithQuery(xPathQuery: String) -> Result<[HTMLTable], Error> {
        return elementsWithQuery(xPathQuery)
    }
    
    public func elementsWithQuery<T: HTMLElement>(xPathQuery: String) -> Result<[T], Error> {
        if let parsedObjects = searchWithXPathQuery(xPathQuery) where parsedObjects.count > 0 {
            return resultFromOptional(parsedObjects.flatMap { T(element: $0, pageURL: url) }, error: .NotFound)
        }
        return Result.Error(.NotFound)
    }
    
    // MARK: Helper Methods
    
    private func firstElementFromResult<T: HTMLElement>(result: Result<[T], Error>) -> Result<T, Error> {
        switch result {
        case .Success(let result): return resultFromOptional(result.first, error: .NotFound)
        case .Error(let error): return Result.Error(error)
        }
    }
    
    // images
    // imageWith(criteria)
    // linkWith(criteria)
    // links
    // title
    
}