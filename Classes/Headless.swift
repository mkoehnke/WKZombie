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
     
     - returns: a headless instance
     */
    public init(name: String? = "Headless") {
        super.init()
        self.name = name
        self.renderer = Renderer()
    }
 
    //========================================
    // MARK: Get Page
    //========================================
    
    /**
    The Headless action will load and return a page for the specified URL.
    
    - parameter url: an URL referencing a HTML or JSON page
    
    - returns: the Headless action
    */
    public func get<T: Page>(url: NSURL) -> Action<T> {
        return get(url, postAction: nil)
    }
    
    /**
     The Headless action will load and return a page for the specified URL.
     
     - parameter condition: a JavaScript expression/script that returns 'true' if
     - parameter url: an URL referencing a HTML or JSON page
     
     - returns: the Headless action
     */
    public func get<T: Page>(condition: String)(url: NSURL) -> Action<T> {
        return get(url, postAction: PostAction(type: .Validate, script: condition))
    }
    
    public func get<T: Page>(wait: NSTimeInterval)(url: NSURL) -> Action<T> {
        return get(url, postAction: PostAction(type: .Wait, wait: wait))
    }
    
    private func get<T: Page>(url: NSURL, postAction: PostAction? = nil) -> Action<T> {
        return Action() { [unowned self] completion in
            let request = NSURLRequest(URL: url)
            self.renderer.renderPageWithRequest(request, postAction: postAction, completionHandler: { data, response, error in
                completion(self.handleResponse(data as? NSData, response: response, error: error))
            })
        }
    }
    
    //========================================
    // MARK: Submit Form
    //========================================
    
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
    
    public func submit<T: Page>(form: HTMLForm) -> Action<T> {
        return submit(form, postAction: nil)
    }
    
    public func submit<T: Page>(condition: String)(form: HTMLForm) -> Action<T> {
        return submit(form, postAction: PostAction(type: .Validate, script: condition))
    }

    public func submit<T: Page>(wait: NSTimeInterval)(form: HTMLForm) -> Action<T> {
        return submit(form, postAction: PostAction(type: .Wait, wait: wait))
    }
    
    //========================================
    // MARK: Click Event
    //========================================

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
    
    public func click<T: Page>(link : HTMLLink) -> Action<T> {
        return click(link, postAction: nil)
    }
    
    public func click<T: Page>(condition: String)(link : HTMLLink) -> Action<T> {
        return click(link, postAction: PostAction(type: .Validate, script: condition))
    }
    
    public func click<T: Page>(wait: NSTimeInterval)(link : HTMLLink) -> Action<T> {
        return click(link, postAction: PostAction(type: .Wait, wait: wait))
    }
    
    
    //========================================
    // MARK: Response Handling
    //========================================
    
    public func handleResponse<T: Page>(data: NSData?, response: NSURLResponse?, error: NSError?) -> Result<T> {
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
        if let values = values {
            for (key, value) in values {
                script += "document.\(name)['\(key)'].value='\(value)';"
            }
        }
        script += "document.\(name).submit();"
        return script
    }
    
    private func clickLinkScript(href: String) -> String {
        return "window.location.href='\(href)';"
    }
}