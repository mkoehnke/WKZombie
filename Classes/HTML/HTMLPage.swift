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

/// HTMLPage class, which represents the DOM of a HTML page.
public class HTMLPage : HTMLParser, Page {
    
    //========================================
    // MARK: Initializer
    //========================================
    
    /**
    Returns a HTML page instance for the specified HTML DOM data.
    
    - parameter data: The HTML DOM data.
    - parameter url:  The URL of the page.
    
    - returns: A HTML page.
    */
    public static func pageWithData(data: NSData?, url: NSURL?) -> Page? {
        if let data = data {
            return HTMLPage(data: data, url: url)
        }
        return nil
    }
    
    //========================================
    // MARK: Forms
    //========================================
    
    /**
    Returns the first HTML form in the DOM with the specified name.
    
    - parameter name: The form name.
    
    - returns: A result containing either a form or an error.
    */
    public func formWithName(name: String) -> Result<HTMLForm> {
        return formsWithQuery(HTMLForm.keyValueQuery(["name" : name])).first()
    }
    
    /**
     Returns all HTML forms in the DOM matching the specified XPath query.
     
     - parameter XPathQuery: The XPath query.
     
     - returns: A result containing either an array of forms o an error.
     */
    public func formsWithQuery(XPathQuery: String) -> Result<[HTMLForm]> {
        return elementsWithQuery(XPathQuery)
    }
    
    
    //========================================
    // MARK: Links
    //========================================
    
    /**
    Returns the first HTML link in the DOM with the specified name.
    
    - parameter name: The link name.
    
    - returns: A result containing either a link or an error.
    */
    public func linkWithName(name: String) -> Result<HTMLLink> {
        return linksWithQuery("//a[text()='\(name)']/@href").first()
    }
    
    /**
     Returns all HTML links in the DOM matching the specified key-value pattern.
     
     - parameter key:   The attribute name.
     - parameter value: The attribute value.
     
     - returns: A result containing either an array of links or an error.
     */
    public func linksWithAttribute(key: String, value: String) -> Result<[HTMLLink]> {
        return linksWithQuery(HTMLLink.keyValueQuery([key : value]))
    }
    
    /**
     Returns all HTML links in the DOM matching the specified XPath query.
     
     - parameter XPathQuery: The XPath query.
     
     - returns: A result containing either an array of links o an error.
     */
    public func linksWithQuery(XPathQuery: String) -> Result<[HTMLLink]> {
        return elementsWithQuery(XPathQuery)
    }
    
    
    //========================================
    // MARK: Tables
    //========================================
    
    /**
     Returns all HTML tables in the DOM matching the specified key-value pattern.
     
     - parameter key:   The attribute name.
     - parameter value: The attribute value.
     
     - returns: A result containing either an array of tables or an error.
     */
    public func tablesWithAttribute(key: String, value: String) -> Result<[HTMLTable]> {
        return tablesWithQuery(HTMLTable.keyValueQuery([key : value]))
    }
    
    /**
     Returns all HTML tables in the DOM matching the specified XPath query.
     
     - parameter XPathQuery: The XPath query.
     
     - returns: A result containing either an array of tables o an error.
     */
    public func tablesWithQuery(XPathQuery: String) -> Result<[HTMLTable]> {
        return elementsWithQuery(XPathQuery)
    }
    
    
    //========================================
    // MARK: Generic Method
    //========================================
    
    public func elementsWithQuery<T: HTMLElement>(XPathQuery: String) -> Result<[T]> {
        if let parsedObjects = searchWithXPathQuery(XPathQuery) where parsedObjects.count > 0 {
            return resultFromOptional(parsedObjects.flatMap { T(element: $0, pageURL: url) }, error: .NotFound)
        }
        return Result.Error(.NotFound)
    }
}