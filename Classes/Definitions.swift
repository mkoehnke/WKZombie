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

//========================================
// MARK: Logging
//========================================

func HLLog(message: String, lineBreak: Bool = true) {
    #if DEBUG
        if lineBreak {
            print("\(message)")
        } else {
            print("\(message)", terminator: "")
        }
    #endif
}

public enum SearchType<T: HTMLElement> {
    case Id(String)
    
    case Name(String)
    
    case Text(String)
    
    case Class(String)
    
    /**
     Search by matching an attribute using key/value.
     */
    case Attribute(String, String?)
    /**
     Search by using a XPath Query.
     */
    case XPathQuery(String)
    
    func xPathQuery() -> String {
        switch self {
        case .Text(let value): return T.createXPathQuery("[contains(text(),'\(value)')]")
        case .Id(let id): return T.createXPathQuery("[@id='\(id)']")
        case .Name(let name): return T.createXPathQuery("[@name='\(name)']")
        case .Attribute(let key, let value): return T.createXPathQuery("[@\(key)='\(value ?? "")']")
        case .Class(let className): return T.createXPathQuery("[@class='\(className)']")
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

extension Result where T:CollectionType {
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
    var statusCode: Int = 500
    
    init(data: NSData?, urlResponse: NSURLResponse) {
        self.data = data
        if let httpResponse = urlResponse as? NSHTTPURLResponse {
            self.statusCode = httpResponse.statusCode
        }
    }
}

infix operator >>> { associativity left precedence 150 }
internal func >>><A, B>(a: Result<A>, f: A -> Result<B>) -> Result<B> {
    switch a {
    case let .Success(x):   return f(x)
    case let .Error(error): return .Error(error)
    }
}

public func >>><T, U>(a: Action<T>, f: T -> Action<U>) -> Action<U> {
    return a.andThen(f)
}

public func ===<T>(a: Action<T>, completion: (result: T?) -> Void) {
    return a.start { result in
        switch result {
        case .Success(let value): completion(result: value)
        case .Error: completion(result: nil)
        }
    }
}

internal func parseResponse(response: Response) -> Result<NSData> {
    guard let data = response.data else {
        return .Error(.NetworkRequestFailure)
    }
    
    let successRange = 200..<300
    if !successRange.contains(response.statusCode) {
        return .Error(.NetworkRequestFailure)
    }
    return Result(nil, data)
}

internal func resultFromOptional<A>(optional: A?, error: ActionError) -> Result<A> {
    if let a = optional {
        return .Success(a)
    } else {
        return .Error(error)
    }
}

internal func decodeResult<T: Page>(url: NSURL? = nil)(data: NSData?) -> Result<T> {
    return resultFromOptional(T.pageWithData(data, url: url) as? T, error: .NetworkRequestFailure)
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

extension Action {
    // TODO - implement flatMap
    
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

extension Action {
    
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

internal func parseJSON(data: NSData) -> Result<JSON> {
    var jsonOptional: JSON?
    var __error = ActionError.ParsingFailure
    
    do {
        if let data = htmlToData(NSString(data: data, encoding: NSUTF8StringEncoding)) {
            jsonOptional = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
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

/// Helper methods
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
