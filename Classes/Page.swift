//
//  Page.swift
//  HeadlessDemo
//
//  Created by Mathias Köhnke on 23/11/15.
//  Copyright © 2015 Mathias Köhnke. All rights reserved.
//

import Foundation

public class Page : Parser {
        
    func formWithName(name: String) -> Result<Form, Error> {
        return firstElementFromResult(formsWithQuery("//form[@name='\(name)']"))
    }
    
    func formsWithQuery(xPathQuery: String) -> Result<[Form], Error> {
        return elementsWithQuery(xPathQuery)
    }
    
    func linkWithName(name: String) -> Result<Link, Error> {
        return firstElementFromResult(linksWithQuery("//a[text()='\(name)']/@href"))
    }
    
    func firstLinkWithAttribute(key: String, value: String) -> Result<Link, Error> {
        return firstElementFromResult(linksWithAttribute(key, value: value))
    }
    
    func linksWithAttribute(key: String, value: String) -> Result<[Link], Error> {
        return linksWithQuery("//a[@\(key)='\(value)']/@href")
    }
    
    func linksWithQuery(xPathQuery: String) -> Result<[Link], Error> {
        return elementsWithQuery(xPathQuery)
    }
    
    func elementsWithQuery<T: Element>(xPathQuery: String) -> Result<[T], Error> {
        if let parsedObjects = searchWithXPathQuery(xPathQuery) where parsedObjects.count > 0 {
            return resultFromOptional(parsedObjects.flatMap { T(element: $0, pageURL: url) }, error: .NotFound)
        }
        return Result.Error(.NotFound)
    }
    
    func firstTableWithAttribute(key: String, value: String) -> Result<Table, Error> {
        return firstElementFromResult(tablesWithAttribute(key, value: value))
    }
    
    func tablesWithAttribute(key: String, value: String) -> Result<[Table], Error> {
        return tablesWithQuery("//table[@\(key)='\(value)']")
    }
    
    func tablesWithQuery(xPathQuery: String) -> Result<[Table], Error> {
        return elementsWithQuery(xPathQuery)
    }
    
    
    private func firstElementFromResult<T: Element>(result: Result<[T], Error>) -> Result<T, Error> {
        switch result {
        case .Success(let result): return resultFromOptional(result.first, error: .NotFound)
        case .Error(let error): return Result.Error(error)
        }
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