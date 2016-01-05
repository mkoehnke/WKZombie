//
// Headless.swift
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

public class Headless : NSObject {
    
    private var renderer : Renderer!
    
    /// Returns the name of this headless session.
    public private(set) var name : String!
    
    /// If false, the loading progress will finish once the 'raw' HTML data
    /// has been transmitted. Media content such as videos or images won't
    /// be loaded.
    public var loadMediaContent : Bool = true {
        didSet {
            renderer.loadMediaContent = loadMediaContent
        }
    }
    
    /**
     The designated initializer.
     
     - parameter name: The name of the headless session.
     
     - returns: A headless instance.
     */
    public init(name: String? = "Headless") {
        super.init()
        self.name = name
        self.renderer = Renderer()
    }
 
    //========================================
    // MARK: Response Handling
    //========================================
    
    private func handleResponse<T: Page>(data: NSData?, response: NSURLResponse?, error: NSError?) -> Result<T> {
        guard let response = response else {
            return decodeResult(nil)(data: nil)
        }
        let errorDomain : ActionError? = (error == nil) ? nil : .NetworkRequestFailure
        let responseResult: Result<Response> = Result(errorDomain, Response(data: data, urlResponse: response))
        return responseResult >>> parseResponse >>> decodeResult(response.URL)
    }
}


//========================================
// MARK: Get Page
//========================================

extension Headless {
    /**
     The returned Headless Action will load and return a page for the specified URL.
     
     - parameter url: An URL referencing a HTML or JSON page.
     
     - returns: The Headless Action.
     */
    public func open<T: Page>(url: NSURL) -> Action<T> {
        return open(url, postAction: .None)
    }
    
    /**
     The returned Headless Action will load and return a page for the specified URL.
     
     - parameter postAction: An wait/validation action that will be performed after the page has reloaded.
     - parameter url: An URL referencing a HTML or JSON page.
     
     - returns: The Headless Action.
     */
    public func open<T: Page>(then postAction: PostAction = .None)(url: NSURL) -> Action<T> {
        return open(url, postAction: postAction)
    }

    /// Helper Method
    private func open<T: Page>(url: NSURL, postAction: PostAction = .None) -> Action<T> {
        return Action() { [unowned self] completion in
            let request = NSURLRequest(URL: url)
            self.renderer.renderPageWithRequest(request, postAction: postAction, completionHandler: { data, response, error in
                completion(self.handleResponse(data as? NSData, response: response, error: error))
            })
        }
    }
}


//========================================
// MARK: Submit Form
//========================================

extension Headless {
    /**
     Submits the specified HTML form.
     
     - parameter form: A HTML form.
     
     - returns: The Headless Action.
     */
    public func submit<T: Page>(form: HTMLForm) -> Action<T> {
        return submit(form, postAction: .None)
    }
    
    /**
     Submits the specified HTML form.
     
     - parameter postAction: An wait/validation action that will be performed after the page has reloaded.
     - parameter url: An URL referencing a HTML or JSON page.
     
     - returns: The Headless Action.
     */
    public func submit<T: Page>(then postAction: PostAction)(form: HTMLForm) -> Action<T> {
        return submit(form, postAction: postAction)
    }
    
    /// Helper Method
    private func submit<T: Page>(form: HTMLForm, postAction: PostAction = .None) -> Action<T> {
        return Action() { [unowned self] completion in
            if let script = form.actionScript() {
                self.renderer.executeScript(script, willLoadPage: true, postAction: postAction, completionHandler: { result, response, error in
                    completion(self.handleResponse(result as? NSData, response: response, error: error))
                })
            } else {
                completion(Result.Error(.NetworkRequestFailure))
            }
        }
    }
}


//========================================
// MARK: Click Event
//========================================

extension Headless {
    /**
     Simulates the click of a HTML link.
     
     - parameter link: The HTML link.
     
     - returns: The Headless Action.
     */
    public func click<T: Page>(link : HTMLLink) -> Action<T> {
        return click(link, postAction: .None)
    }
    
    /**
     Simulates the click of a HTML link.
     
     - parameter postAction: An wait/validation action that will be performed after the page has reloaded.
     - parameter url: An URL referencing a HTML or JSON page.
     
     - returns: The Headless Action.
     */
    public func click<T: Page>(then postAction: PostAction)(link : HTMLLink) -> Action<T> {
        return click(link, postAction: postAction)
    }

    /// Helper Method
    private func click<T: Page>(link : HTMLLink, postAction: PostAction = .None) -> Action<T> {
        return Action() { [unowned self] completion in
            if let script = link.actionScript() {
                self.renderer.executeScript(script, willLoadPage: true, postAction: postAction, completionHandler: { result, response, error in
                    completion(self.handleResponse(result as? NSData, response: response, error: error))
                })
            } else {
                completion(Result.Error(.NetworkRequestFailure))
            }
        }
    }
}

//========================================
// MARK: DOM Modification Methods
//========================================

extension Headless {
    
    /**
     The returned Headless Action will update a key/value pair on the specified HTMLElement.
     
     - parameter key:   A Key.
     - parameter value: A Value.
     - parameter element: A HTML element.
     
     - returns: The Headless Action.
     */
    public func setAttribute<T: HTMLElement>(key: String, value: String?)(element: T) -> Action<HTMLPage> {
        return Action() { [unowned self] completion in
            if let query = element.XPathQuery {
                let script = "getElementByXpath(\"\(query)\").setAttribute(\"\(key)\", \"\(value ?? "")\"); \(Renderer.scrapingCommand);"
                self.renderer.executeScript(script, willLoadPage: false, postAction: .None, completionHandler: { result, response, error in
                    completion(decodeResult(nil)(data: result as? NSData))
                })
            } else {
                completion(Result.Error(.NetworkRequestFailure))
            }
        }
    }
    
}

//========================================
// MARK: Find Methods
//========================================

extension Headless {    
    /**
     The returned Headless Action will search a page and return all elements matching the generic HTML element type and
     the passed key/value attributes.
     
     - parameter withAttributes: Key/Value Pairs.
     - parameter page: A HTML page.
     
     - returns: The Headless Action.
     */
    public func getElements<T: HTMLElement>(by searchType: SearchType)(page: HTMLPage) -> Action<[T]> {
        let elements : Result<[T]> = getElements(page, searchType: searchType)
        return Action(result: elements)
    }
        
    /**
     The returned Headless Action will search a page and return the first element matching the generic HTML element type and
     the passed key/value attributes.
     
     - parameter withAttributes: Key/Value Pairs.
     - parameter page: A HTML page.
     
     - returns: The Headless Action.
     */
    public func getElement<T: HTMLElement>(by searchType: SearchType)(page: HTMLPage) -> Action<T> {
        let elements : Result<[T]> = getElements(page, searchType: searchType)
        return Action(result: elements.first())
    }

    /// Helper Method
    private func getElements<T: HTMLElement>(page: HTMLPage, searchType: SearchType) -> Result<[T]> {
        switch searchType {
        case .Id(let id): return page.elementsWithQuery("//*[@id='\(id)']")
        case .Name(let name): return page.elementsWithQuery("//*[@name='\(name)']")
        case .Attribute(let key, let value): return page.elementsWithQuery(T.keyValueQuery(key, value: value ?? ""))
        case .XPathQuery(let query): return page.elementsWithQuery(query)
        }
    }
}


//========================================
// MARK: Transform Actions
//========================================

extension Headless {
    /**
     The returned Headless Action will transform a HTMLElement into another HTMLElement using the specified function.
     
     - parameter f: The function that takes a certain HTMLElement as parameter and transforms it into another HTMLElement.
     - parameter element: A HTML element.
     
     - returns: The Headless Action.
     */
    public func map<T: HTMLElement, A: HTMLElement>(f: T -> A)(element: T) -> Action<A> {
        return Action(result: resultFromOptional(f(element), error: .NotFound))
    }
}

//========================================
// MARK: Advanced Actions
//========================================

extension Headless {
    /**
     Executes the specified action (with the result of the previous action execution as input parameter) until
     a certain condition is met. Afterwards, it will return the collected action results.
     
     - parameter f:       The Action which will be executed.
     - parameter until:   If 'true', the execution of the specified Action will stop.
     - parameter initial: The initial input parameter for the Action.
     
     - returns: The collected Sction results.
     */
    public func collect<T>(f: T -> Action<T>, until: T -> Bool)(initial: T) -> Action<[T]> {
        return Action.collect(initial, f: f, until: until)
    }
    
    /**
     Makes a bulk execution of the specified action with the provided input values. Once all actions have
     finished, the collected results will be returned.
     
     - parameter f:        The Action.
     - parameter elements: An array containing the input value for the Action.
     
     - returns: The collected Action results.
     */
    public func batch<T, U>(f: T -> Action<U>)(elements: [T]) -> Action<[U]> {
        return Action.batch(elements, f: f)
    }
}

//========================================
// MARK: Debug Methods
//========================================

extension Headless {
    /**
     Prints the current state of the Headless browser to the console.
     */
    func dump() {
        renderer.dump()
    }
}
