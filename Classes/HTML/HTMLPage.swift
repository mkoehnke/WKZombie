//
//  HTMLPage.swift
//
// Copyright (c) 2015 Mathias Koehnke (http://www.mathiaskoehnke.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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
}