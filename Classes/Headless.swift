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
    
    
    //========================================
    // MARK: Scripts
    //========================================

    private func formSubmitScript(name: String, values: [String: String]?) -> String {
        var script = String()
        let fields = values?.map { (key, value) in "document.\(name)['\(key)'].value='\(value)';" }
        if let fields = fields { script += fields.joinWithSeparator("") }
        script += "document.\(name).submit();"
        return script
    }
    
    private func clickLinkScript(href: String) -> String {
        return "window.location.href='\(href)';"
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
    public func get<T: Page>(url: NSURL) -> Action<T> {
        return get(url, postAction: nil)
    }
    
    /**
     The returned Headless Action will load and return a page for the specified URL.
     
     - parameter condition: The action will complete if the specified JavaScript expression/script returns 'true'
     or a timeout occurs.
     - parameter url: An URL referencing a HTML or JSON page.
     
     - returns: The Headless Action.
     */
    public func get<T: Page>(condition: String)(url: NSURL) -> Action<T> {
        return get(url, postAction: PostAction(type: .Validate, script: condition))
    }
    
    /**
     The returned Headless Action will load and return a page for the specified URL.
     
     - parameter wait: The time in seconds that the action will wait (after the page has been loaded) before returning.
     This is useful in cases where the page loading has been completed, but some JavaScript/Image loading
     is still in progress.
     - parameter url: An URL referencing a HTML or JSON page.
     
     - returns: The Headless Action.
     */
    public func get<T: Page>(wait: NSTimeInterval)(url: NSURL) -> Action<T> {
        return get(url, postAction: PostAction(type: .Wait, wait: wait))
    }
    
    /// Helper Method
    private func get<T: Page>(url: NSURL, postAction: PostAction? = nil) -> Action<T> {
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
        return submit(form, postAction: nil)
    }
    
    /**
     Submits the specified HTML form.
     
     - parameter condition: After submitting the form, the action will complete if the specified JavaScript
     expression/script returns 'true' or a timeout occurs.
     - parameter form: A HTML form.
     
     - returns: The Headless Action.
     */
    public func submit<T: Page>(condition: String)(form: HTMLForm) -> Action<T> {
        return submit(form, postAction: PostAction(type: .Validate, script: condition))
    }
    
    /**
     Submits the specified HTML form.
     
     - parameter wait: After submitting the form, this is the time in seconds that the action will wait
     (after the page has been loaded) before returning. This is useful in cases where the
     page loading has been completed, but some JavaScript/Image loading is still in progress.
     - parameter form: A HTML form.
     
     - returns: The Headless Action.
     */
    public func submit<T: Page>(wait: NSTimeInterval)(form: HTMLForm) -> Action<T> {
        return submit(form, postAction: PostAction(type: .Wait, wait: wait))
    }
    
    /// Helper Method
    private func submit<T: Page>(form: HTMLForm, postAction: PostAction? = nil) -> Action<T> {
        return Action() { [unowned self] completion in
            if let name = form.name {
                let script = self.formSubmitScript(name, values: form.inputs)
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
        return click(link, postAction: nil)
    }
    
    /**
     Simulates the click of a HTML link.
     
     - parameter condition: After clicking the link, the action will complete if the specified JavaScript
     expression/script returns 'true' or a timeout occurs.
     - parameter link: The HTML link.
     
     - returns: The Headless Action.
     */
    public func click<T: Page>(condition: String)(link : HTMLLink) -> Action<T> {
        return click(link, postAction: PostAction(type: .Validate, script: condition))
    }
    
    /**
     Simulates the click of a HTML link.
     
     - parameter wait: After clickling the link, this is the time in seconds that the action will wait
     (after the page has been loaded) before returning. This is useful in cases where the
     page loading has been completed, but some JavaScript/Image loading is still in progress.
     - parameter link: The HTML link.
     
     - returns: The Headless Action.
     */
    public func click<T: Page>(wait: NSTimeInterval)(link : HTMLLink) -> Action<T> {
        return click(link, postAction: PostAction(type: .Wait, wait: wait))
    }
    
    /// Helper Method
    private func click<T: Page>(link : HTMLLink, postAction: PostAction? = nil) -> Action<T> {
        return Action() { [unowned self] completion in
            if let url = link.href {
                let script = self.clickLinkScript(url)
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
// MARK: Find Methods
//========================================

extension Headless {
    /**
     Returns a function that searches for a __link__ with the specified key/value pair.
     
     - parameter key:   key
     - parameter value: value
     
     - returns: return
     */
    public func findAll<T: HTMLElement>(query: String)(page: HTMLPage) -> Action<[T]> {
        return Action(result: page.elementsWithQuery(query))
    }
    
    public func findAll<T: HTMLElement>(key: String, _ value: String)(page: HTMLPage) -> Action<[T]> {
        let elements : Result<[T]> = page.elementsWithQuery(T.keyValueQuery(key, value: value))
        return Action(result: elements)
    }
    
    public func find<T: HTMLElement>(query: String)(page: HTMLPage) -> Action<T> {
        let elements : Result<[T]> = page.elementsWithQuery(query)
        return Action(result: elements.first())
    }
    
    public func find<T: HTMLElement>(key: String, _ value: String)(page: HTMLPage) -> Action<T> {
        let elements : Result<[T]> = page.elementsWithQuery(T.keyValueQuery(key, value: value))
        return Action(result: elements.first())
    }
}

//========================================
// MARK: Advanced Actions
//========================================

extension Headless {
    
    public func collect<T>(f: T -> Action<T>, until: T -> Bool)(initial: T) -> Action<[T]> {
        return Action.collect(initial, f: f, until: until)
    }
    
    public func batch<T, U>(f: T -> Action<U>)(elements: [T]) -> Action<[U]> {
        return Action.batch(elements, f: f)
    }
}
