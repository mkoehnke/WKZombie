//
// Helper.swift
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


public enum SearchType<T: HTMLElement> {
    /**
     * Returns an element that matches the specified id.
     */
    case Id(String)
    /**
     * Returns all elements matching the specified value for their name attribute.
     */
    case Name(String)
    /**
     * Returns all elements with inner content, that contain the specified text.
     */
    case Text(String)
    /**
     * Returns all elements that match the specified class name.
     */
    case Class(String)
    /**
     Returns all elements that match the specified attribute name/value combination.
     */
    case Attribute(String, String)
    /**
     Returns all elements with an attribute containing the specified value.
     */
    case Contains(String, String)
    /**
     Returns all elements that match the specified XPath query.
     */
    case XPathQuery(String)
    
    func xPathQuery() -> String {
        switch self {
        case .Text(let value): return T.createXPathQuery("[contains(text(),'\(value)')]")
        case .Id(let id): return T.createXPathQuery("[@id='\(id)']")
        case .Name(let name): return T.createXPathQuery("[@name='\(name)']")
        case .Attribute(let key, let value): return T.createXPathQuery("[@\(key)='\(value)']")
        case .Class(let className): return T.createXPathQuery("[@class='\(className)']")
        case .Contains(let key, let value): return T.createXPathQuery("[contains(@\(key), '\(value)')]")
        case .XPathQuery(let query): return query
        }
    }
}

//========================================
// MARK: Result
//========================================

public enum Result<T> {
    case Success(T)
    case Error(ActionError)
    
    init(_ error: ActionError?, _ value: T) {
        if let err = error {
            self = .Error(err)
        } else {
            self = .Success(value)
        }
    }
}

public extension Result where T:CollectionType {
    public func first<A>() -> Result<A> {
        switch self {
        case .Success(let result): return resultFromOptional(result.first as? A, error: .NotFound)
        case .Error(let error): return resultFromOptional(nil, error: error)
        }
    }
}

extension Result: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .Success(let value):
            return "Success: \(String(value))"
        case .Error(let error):
            return "Error: \(String(error))"
        }
    }
}

//========================================
// MARK: Response
//========================================

internal struct Response {
    var data: NSData?
    var statusCode: Int = ActionError.Static.DefaultStatusCodeError
    
    init(data: NSData?, urlResponse: NSURLResponse) {
        self.data = data
        if let httpResponse = urlResponse as? NSHTTPURLResponse {
            self.statusCode = httpResponse.statusCode
        }
    }
    
    init(data: NSData?, statusCode: Int) {
        self.data = data
        self.statusCode = statusCode
    }
}

infix operator >>> { associativity left precedence 150 }
internal func >>><A, B>(a: Result<A>, f: A -> Result<B>) -> Result<B> {
    switch a {
    case let .Success(x):   return f(x)
    case let .Error(error): return .Error(error)
    }
}

/**
 This Operator equates to the andThen() method. Here, the left-hand side Action will be started 
 and the result is used as parameter for the right-hand side Action.
 
 - parameter a: An Action.
 - parameter f: A Function.
 
 - returns: An Action.
 */
public func >>><T, U>(a: Action<T>, f: T -> Action<U>) -> Action<U> {
    return a.andThen(f)
}

/**
 This Operator equates to the andThen() method with the exception, that the result of the left-hand 
 side Action will be ignored and not passed as paramter to the right-hand side Action.
 
 - parameter a: An Action.
 - parameter b: An Action.
 
 - returns: An Action.
 */
public func >>><T, U>(a: Action<T>, b: Action<U>) -> Action<U> {
    let f : (T -> Action<U>) = { _ in b }
    return a.andThen(f)
}

/**
 This Operator starts the left-hand side Action and passes the result as Optional to the 
 function on the right-hand side.
 
 - parameter a:          An Action.
 - parameter completion: A Completion Block.
 */
public func ===<T>(a: Action<T>, completion: T? -> Void) {
    return a.start { result in
        switch result {
        case .Success(let value): completion(value)
        case .Error: completion(nil)
        }
    }
}

/**
 This operator passes the left-hand side Action and passes the result it to the 
 function/closure on the right-hand side.
 
 - parameter a:          An Action.
 - parameter completion: An output function/closure.
 */
public func ===<T>(a: Action<T>, completion: Result<T> -> Void) {
    return a.start { result in
        completion(result)
    }
}

internal func parseResponse(response: Response) -> Result<NSData> {
    let successRange = 200..<300
    if !successRange.contains(response.statusCode) {
        return .Error(.NetworkRequestFailure)
    }
    return Result(nil, response.data ?? NSData())
}

internal func resultFromOptional<A>(optional: A?, error: ActionError) -> Result<A> {
    if let a = optional {
        return .Success(a)
    } else {
        return .Error(error)
    }
}

internal func decodeResult<T: Page>(url: NSURL? = nil) -> (data: NSData?) -> Result<T> {
    return { (data: NSData?) -> Result<T> in
        return resultFromOptional(T.pageWithData(data, url: url) as? T, error: .NetworkRequestFailure)
    }
}

internal func decodeString(data: NSData?) -> Result<String> {
    return resultFromOptional(data?.toString(), error: .TransformFailure)
}

//========================================
// MARK: Actions
// Borrowed from Javier Soto's 'Back to the Futures' Talk
// https://speakerdeck.com/javisoto/back-to-the-futures
//========================================

public struct Action<T> {
    public typealias ResultType = Result<T>
    public typealias Completion = ResultType -> ()
    public typealias AsyncOperation = Completion -> ()
    
    private let operation: AsyncOperation
    
    public init(result: ResultType) {
        self.init(operation: { completion in
            dispatch_async(dispatch_get_main_queue(), {
                completion(result)
            })
        })
    }
    
    public init(value: T) {
        self.init(result: .Success(value))
    }
    
    public init(error: ActionError) {
        self.init(result: .Error(error))
    }
    
    public init(operation: AsyncOperation) {
        self.operation = operation
    }
    
    public func start(completion: Completion) {
        self.operation() { result in
            dispatch_async(dispatch_get_main_queue(), {
                completion(result)
            })
        }
    }
}

public extension Action {
    public func map<U>(f: T -> U) -> Action<U> {
        return Action<U>(operation: { completion in
            self.start { result in
                dispatch_async(dispatch_get_main_queue(), {
                    switch result {
                    case .Success(let value): completion(Result.Success(f(value)))
                    case .Error(let error): completion(Result.Error(error))
                    }
                })
            }
        })
    }
    
    public func flatMap<U>(f: T -> U?) -> Action<U> {
        return Action<U>(operation: { completion in
            self.start { result in
                dispatch_async(dispatch_get_main_queue(), {
                    switch result {
                    case .Success(let value):
                        if let result = f(value) {
                            completion(Result.Success(result))
                        } else {
                            completion(Result.Error(.TransformFailure))
                        }
                    case .Error(let error): completion(Result.Error(error))
                    }
                })
            }
        })
    }
    
    public func andThen<U>(f: T -> Action<U>) -> Action<U> {
        return Action<U>(operation: { completion in
            self.start { firstFutureResult in
                switch firstFutureResult {
                case .Success(let value): f(value).start(completion)
                case .Error(let error):
                    dispatch_async(dispatch_get_main_queue(), {
                        completion(Result.Error(error))
                    })
                }
            }
        })
    }
}


//========================================
// MARK: Convenience Methods
//========================================

public extension Action {
    
    /**
     Executes the specified action (with the result of the previous action execution as input parameter) until
     a certain condition is met. Afterwards, it will return the collected action results.
     
     - parameter initial: The initial input parameter for the Action.
     - parameter f:       The Action which will be executed.
     - parameter until:   If 'true', the execution of the specified Action will stop.
     
     - returns: The collected Sction results.
     */
    internal static func collect(initial: T, f: T -> Action<T>, until: T -> Bool) -> Action<[T]> {
        var values = [T]()
        func loop(future: Action<T>) -> Action<[T]> {
            return Action<[T]>(operation: { completion in
                future.start { result in
                    switch result {
                    case .Success(let newValue):
                        values.append(newValue)
                        if until(newValue) == true {
                            loop(f(newValue)).start(completion)
                        } else {
                            dispatch_async(dispatch_get_main_queue(), {
                                completion(Result.Success(values))
                            })
                        }
                    case .Error(let error):
                        dispatch_async(dispatch_get_main_queue(), {
                            completion(Result.Error(error))
                        })
                    }
                }
            })
        }
        return loop(f(initial))
    }
    
    /**
     Makes a bulk execution of the specified action with the provided input values. Once all actions have
     finished, the collected results will be returned.
     
     - parameter elements: An array containing the input value for the Action.
     - parameter f:        The Action.
     
     - returns: The collected Action results.
     */
    internal static func batch<U>(elements: [T], f: T -> Action<U>) -> Action<[U]> {
        return Action<[U]>(operation: { completion in
            let group = dispatch_group_create()
            var results = [U]()
            for element in elements {
                dispatch_group_enter(group)
                f(element).start({ result in
                    switch result {
                    case .Success(let value):
                        results.append(value)
                        dispatch_group_leave(group)
                    case .Error(let error):
                        dispatch_async(dispatch_get_main_queue(), {
                            completion(Result.Error(error))
                        })
                    }
                })
            }
            dispatch_group_notify(group, dispatch_get_main_queue()) {
                completion(Result.Success(results))
            }
        })
    }
}


//========================================
// MARK: Post Action
//========================================

/**
An wait/validation action that will be performed after the page has reloaded.
*/
public enum PostAction {
    /**
     The time in seconds that the action will wait (after the page has been loaded) before returning.
     This is useful in cases where the page loading has been completed, but some JavaScript/Image loading
     is still in progress.
     
     - returns: Time in Seconds.
     */
    case Wait(NSTimeInterval)
    /**
     The action will complete if the specified JavaScript expression/script returns 'true'
     or a timeout occurs.
     
     - returns: Validation Script.
     */
    case Validate(String)
    /// No Post Action will be performed.
    case None
}


//========================================
// MARK: JSON
// Inspired by Tony DiPasquale's Article 
// https://robots.thoughtbot.com/efficient-json-in-swift-with-functional-concepts-and-generics
//========================================

public typealias JSON = AnyObject
public typealias JSONElement = [String : AnyObject]

internal func parseJSON<U: JSON>(data: NSData) -> Result<U> {
    var jsonOptional: U?
    var __error = ActionError.ParsingFailure
    
    do {
        if let data = htmlToData(NSString(data: data, encoding: NSUTF8StringEncoding)) {
            jsonOptional = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? U
        }
    } catch _ as NSError {
        __error = .ParsingFailure
        jsonOptional = nil
    }
    
    return resultFromOptional(jsonOptional, error: __error)
}

internal func decodeJSON<U: JSONDecodable>(json: JSON?) -> Result<U> {
    if let element = json as? JSONElement {
        return resultFromOptional(U.decode(element), error: .ParsingFailure)
    }
    return Result.Error(.ParsingFailure)
}

internal func decodeJSON<U: JSONDecodable>(json: JSON?) -> Result<[U]> {
    let result = [U]()
    if let elements = json as? [JSONElement] {
        var result = [U]()
        for element in elements {
            let decodable : Result<U> = decodeJSON(element)
            switch decodable {
            case .Success(let value): result.append(value)
            case .Error(let error): return Result.Error(error)
            }
        }
    }
    return Result.Success(result)
}



//========================================
// MARK: Helper Methods
//========================================


private func htmlToData(html: NSString?) -> NSData? {
    if let html = html {
        let json = html.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: NSMakeRange(0, html.length))
        return json.dataUsingEncoding(NSUTF8StringEncoding)
    }
    return nil
}

extension Dictionary : JSONParsable {
    public func content() -> JSON? {
        return self as? JSON
    }
}

extension Array : JSONParsable {
    public func content() -> JSON? {
        return self as? JSON
    }
}

extension String {
    internal func terminate() -> String {
        let terminator : Character = ";"
        var trimmed = stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if (trimmed.characters.last != terminator) { trimmed += String(terminator) }
        return trimmed
    }
}

extension NSData {
    internal func toString() -> String? {
        return String(data: self, encoding: NSUTF8StringEncoding)
    }
}


func dispatch_sync_on_main_thread(block: dispatch_block_t) {
    if NSThread.isMainThread() {
        block()
    } else {
        dispatch_sync(dispatch_get_main_queue(), block)
    }
}

internal func delay(time: NSTimeInterval, completion: () -> Void) {
    if let currentQueue = NSOperationQueue.currentQueue()?.underlyingQueue {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, currentQueue) {
            completion()
        }
    } else {
        completion()
    }
}
