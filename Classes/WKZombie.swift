//
// WKZombie.swift
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

public class WKZombie : NSObject {
    
    private var renderer : Renderer!
    private var fetcher : ContentFetcher!
    
    /// Returns the name of this WKZombie session.
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
     
     - parameter name: The name of the WKZombie session.
     
     - returns: A WKZombie instance.
     */
    public init(name: String? = "WKZombie") {
        super.init()
        self.name = name
        self.renderer = Renderer()
        self.fetcher = ContentFetcher()
    }
 
    //========================================
    // MARK: Response Handling
    //========================================
    
    private func handleResponse(data: NSData?, response: NSURLResponse?, error: NSError?) -> Result<NSData> {
        guard let response = response else {
            return Result.Error(.NetworkRequestFailure)
        }
        let errorDomain : ActionError? = (error == nil) ? nil : .NetworkRequestFailure
        let responseResult: Result<Response> = Result(errorDomain, Response(data: data, urlResponse: response))
        return responseResult >>> parseResponse
    }
}


//========================================
// MARK: Get Page
//========================================

extension WKZombie {
    /**
     The returned WKZombie Action will load and return a HTML or JSON page for the specified URL.
     
     - parameter url: An URL referencing a HTML or JSON page.
     
     - returns: The WKZombie Action.
     */
    public func open<T: Page>(url: NSURL) -> Action<T> {
        return open(then: .None)(url: url)
    }
    
    /**
     The returned WKZombie Action will load and return a page for the specified URL.
     
     - parameter postAction: An wait/validation action that will be performed after the page has finished loading.
     - parameter url: An URL referencing a HTML or JSON page.
     
     - returns: The WKZombie Action.
     */
    public func open<T: Page>(then postAction: PostAction = .None)(url: NSURL) -> Action<T> {
        return Action() { [unowned self] completion in
            let request = NSURLRequest(URL: url)
            self.renderer.renderPageWithRequest(request, postAction: postAction, completionHandler: { data, response, error in
                let data = self.handleResponse(data as? NSData, response: response, error: error)
                completion(data >>> decodeResult(response?.URL))
            })
        }
    }
}


//========================================
// MARK: Submit Form
//========================================

extension WKZombie {
    /**
     Submits the specified HTML form.
     
     - parameter form: A HTML form.
     
     - returns: The WKZombie Action.
     */
    public func submit<T: Page>(form: HTMLForm) -> Action<T> {
        return submit(then: .None)(form: form)
    }
    
    /**
     Submits the specified HTML form.
     
     - parameter postAction: An wait/validation action that will be performed after the page has reloaded.
     - parameter url: An URL referencing a HTML or JSON page.
     
     - returns: The WKZombie Action.
     */
    public func submit<T: Page>(then postAction: PostAction = .None)(form: HTMLForm) -> Action<T> {
        return Action() { [unowned self] completion in
            if let script = form.actionScript() {
                self.renderer.executeScript(script, willLoadPage: true, postAction: postAction, completionHandler: { result, response, error in
                    let data = self.handleResponse(result as? NSData, response: response, error: error)
                    completion(data >>> decodeResult(response?.URL))
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

extension WKZombie {
    /**
     Simulates the click of a HTML link.
     
     - parameter link: The HTML link.
     
     - returns: The WKZombie Action.
     */
    public func click<T: Page>(link : HTMLLink) -> Action<T> {
        return click(then: .None)(link: link)
    }
    
    /**
     Simulates the click of a HTML link.
     
     - parameter postAction: An wait/validation action that will be performed after the page has reloaded.
     - parameter url: An URL referencing a HTML or JSON page.
     
     - returns: The WKZombie Action.
     */
    public func click<T: Page>(then postAction: PostAction = .None)(link : HTMLLink) -> Action<T> {
        return Action() { [unowned self] completion in
            if let script = link.actionScript() {
                self.renderer.executeScript(script, willLoadPage: true, postAction: postAction, completionHandler: { result, response, error in
                    let data = self.handleResponse(result as? NSData, response: response, error: error)
                    completion(data >>> decodeResult(response?.URL))
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

extension WKZombie {
    
    /**
     The returned WKZombie Action will set or update a attribute/value pair on the specified HTMLElement.
     
     - parameter key:   A Attribute Name.
     - parameter value: A Value.
     - parameter element: A HTML element.
     
     - returns: The WKZombie Action.
     */
    public func setAttribute<T: HTMLElement>(key: String, value: String?)(element: T) -> Action<HTMLPage> {
        return Action() { [unowned self] completion in
            if let script = element.createSetAttributeCommand(key, value: value) {
                self.renderer.executeScript("\(script) \(Renderer.scrapingCommand);", completionHandler: { result, response, error in
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

extension WKZombie {    
    /**
     The returned WKZombie Action will search a page and return all elements matching the generic HTML element type and
     the passed key/value attributes.
     
     - parameter by: Key/Value Pairs.
     - parameter page: A HTML page.
     
     - returns: The WKZombie Action.
     */
    public func getAll<T: HTMLElement>(by searchType: SearchType<T>)(page: HTMLPage) -> Action<[T]> {
        let elements : Result<[T]> = page.findElements(searchType)
        return Action(result: elements)
    }
        
    /**
     The returned WKZombie Action will search a page and return the first element matching the generic HTML element type and
     the passed key/value attributes.
     
     - parameter by: Key/Value Pairs.
     - parameter page: A HTML page.
     
     - returns: The WKZombie Action.
     */
    public func get<T: HTMLElement>(by searchType: SearchType<T>)(page: HTMLPage) -> Action<T> {
        let elements : Result<[T]> = page.findElements(searchType)
        return Action(result: elements.first())
    }
}


//========================================
// MARK: Fetch Actions
//========================================

extension WKZombie {
    /**
     The returned WKZombie Action will download the linked data of the passed HTMLFetchable object.
     
     - parameter fetchable: A HTMLElement that implements the HTMLFetchable protocol.
     
     - returns: The WKZombie Action.
     */
    public func fetch<T: HTMLFetchable>(fetchable: T) -> Action<T> {
        return Action() { [unowned self] completion in
            if let fetchURL = fetchable.fetchURL {
                self.fetcher.fetch(fetchURL, completion: { (result, response, error) in
                    let data = self.handleResponse(result, response: response, error: error)
                    switch data {
                    case .Success(let value): fetchable.fetchedData = value
                    case .Error(let error):
                        completion(Result.Error(error))
                        return
                    }
                    completion(Result.Success(fetchable))
                })
            } else {
                completion(Result.Error(.NotFound))
            }
        }
    }
}


//========================================
// MARK: Transform Actions
//========================================

extension WKZombie {
    /**
     The returned WKZombie Action will transform a HTMLElement into another HTMLElement using the specified function.
     
     - parameter f: The function that takes a certain HTMLElement as parameter and transforms it into another HTMLElement.
     - parameter element: A HTML element.
     
     - returns: The WKZombie Action.
     */
    public func map<T: HTMLElement, A: HTMLElement>(f: T -> A)(element: T) -> Action<A> {
        return Action(result: resultFromOptional(f(element), error: .NotFound))
    }
}

//========================================
// MARK: Advanced Actions
//========================================

extension WKZombie {
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
// MARK: JSON Actions
//========================================

extension WKZombie {
    
    /**
     The returned WKZombie Action will parse NSData and create a JSON object.
     
     - parameter data: A NSData object.
     
     - returns: A JSON object.
     */
    public func parse<T: JSON>(data: NSData) -> Action<T> {
        return Action(result: parseJSON(data))
    }
    
    /**
     The returned WKZombie Action will take a JSONParsable (Array, Dictionary and JSONPage) and 
     decode it into a Model object. This particular Model class has to implement the 
     JSONDecodable protocol.
     
     - parameter element: A JSONParsable instance.
     
     - returns: A JSONDecodable object.
     */
    public func decode<T : JSONDecodable>(element: JSONParsable) -> Action<T> {
        return Action(result: decodeJSON(element.content()))
    }
    
    /**
     The returned WKZombie Action will take a JSONParsable (Array, Dictionary and JSONPage) and
     decode it into an array of Model objects of the same class. The class has to implement the
     JSONDecodable protocol.
     
     - parameter element: A JSONParsable instance.
     
     - returns: A JSONDecodable array.
     */
    public func decode<T : JSONDecodable>(array: JSONParsable) -> Action<[T]> {
        return Action(result: decodeJSON(array.content()))
    }
    
}


//========================================
// MARK: Debug Methods
//========================================

extension WKZombie {
    /**
     Prints the current state of the WKZombie browser to the console.
     */
    func dump() {
        renderer.dump()
    }
}
