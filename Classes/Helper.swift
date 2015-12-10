//
//  Helper.swift
//  HeadlessDemo
//
//  Created by Mathias Köhnke on 25/11/15.
//  Copyright © 2015 Mathias Köhnke. All rights reserved.
//

import Foundation

//========================================
// MARK: Logging
//========================================

func HLLog(message: String, function: String = __FUNCTION__) {
    #if DEBUG
        print("\(function): \(message)")
    #endif
}

//========================================
// MARK: Result
//========================================

public enum Result<T, E: ErrorType> {
    case Success(T)
    case Error(E)
    
    init(_ error: E?, _ value: T) {
        if let err = error {
            self = .Error(err)
        } else {
            self = .Success(value)
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
internal func >>><A, B>(a: Result<A, Error>, f: A -> Result<B, Error>) -> Result<B, Error> {
    switch a {
    case let .Success(x):   return f(x)
    case let .Error(error): return .Error(error)
    }
}

public func >>><T, U, E: ErrorType>(a: Future<T, E>, f: T -> Future<U, E>) -> Future<U, E> {
    return a.andThen(f)
}

internal func parseResponse(response: Response) -> Result<NSData, Error> {
    guard let data = response.data else {
        return .Error(.NetworkRequestFailure)
    }
    
    let successRange = 200..<300
    if !successRange.contains(response.statusCode) {
        return .Error(.NetworkRequestFailure)
    }
    return Result(nil, data)
}

internal func resultFromOptional<A>(optional: A?, error: Error) -> Result<A, Error> {
    if let a = optional {
        return .Success(a)
    } else {
        return .Error(error)
    }
}

internal func decodeResult<T: Page>(url: NSURL? = nil)(data: NSData?) -> Result<T, Error> {
    return resultFromOptional(T.pageWithData(data, url: url) as? T, error: .NetworkRequestFailure)
}


//========================================
// MARK: Futures
// Borrowed from Javier Soto's 'Back to the Futures' Talk
// https://speakerdeck.com/javisoto/back-to-the-futures
//========================================

public struct Future<T, E: ErrorType> {
    public typealias ResultType = Result<T, E>
    public typealias Completion = ResultType -> ()
    public typealias AsyncOperation = Completion -> ()
    
    private let operation: AsyncOperation
    
    public init(result: ResultType) {
        self.init(operation: { completion in
            completion(result)
        })
    }
    
    public init(value: T) {
        self.init(result: .Success(value))
    }
    
    public init(error: E) {
        self.init(result: .Error(error))
    }
    
    public init(operation: AsyncOperation) {
        self.operation = operation
    }
    
    public func start(completion: Completion) {
        self.operation() { result in
            completion(result)
        }
    }
}

extension Future {
    // TODO - implement flatMap
    
    public func map<U>(f: T -> U) -> Future<U, E> {
        return Future<U, E>(operation: { completion in
            self.start { result in
                switch result {
                case .Success(let value): completion(Result.Success(f(value)))
                case .Error(let error): completion(Result.Error(error))
                }
            }
        })
    }
    
    public func mapError<F>(f: E -> F) -> Future<T, F> {
        return Future<T, F>(operation: { completion in
            self.start { result in
                switch result {
                case .Success(let value): completion(Result.Success(value))
                case .Error(let error): completion(Result.Error(f(error)))
                }
            }
        })
    }
    
    public func andThen<U>(f: T -> Future<U, E>) -> Future<U, E> {
        return Future<U, E>(operation: { completion in
            self.start { firstFutureResult in
                switch firstFutureResult {
                case .Success(let value): f(value).start(completion)
                case .Error(let error): completion(Result.Error(error))
                }
            }
        })
    }
}


//========================================
// MARK: Repeat andThen
//========================================

extension Future {
    
    public static func collect(initial: T, f: T -> Future<T, E>, until: T -> Bool) -> Future<[T], E> {
        var values = [T]()
        func loop(future: Future<T, E>) -> Future<[T], E> {
            return Future<[T], E>(operation: { completion in
                future.start { result in
                    switch result {
                    case .Success(let newValue):
                        values.append(newValue)
                        if until(newValue) == true {
                            loop(f(newValue)).start(completion)
                        } else {
                            completion(Result.Success(values))
                        }
                    case .Error(let error): completion(Result.Error(error))
                    }
                }
            })
        }
        return loop(f(initial))
    }
    
    public static func batch<U>(elements: [T], f: T -> Future<U, E>) -> Future<[U], E> {
        return Future<[U], E>(operation: { completion in
            let group = dispatch_group_create()
            var results = [U]()
            for element in elements {
                dispatch_group_enter(group)
                f(element).start({ result in
                    switch result {
                    case .Success(let value):
                        results.append(value)
                        dispatch_group_leave(group)
                    case .Error(let error): completion(Result.Error(error))
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
// MARK: JSON
// Borrowed from Tony DiPasquale 
// https://robots.thoughtbot.com/efficient-json-in-swift-with-functional-concepts-and-generics
//========================================

public typealias JSON = AnyObject
public typealias JSONObject = [String:AnyObject]
public typealias JSONArray = [AnyObject]

internal func _JSONParse<A>(object: JSON) -> A? {
    return object as? A
}

internal func parseJSON(data: NSData) -> Result<JSON, Error> {
    var jsonOptional: JSON
    var __error = Error.ParsingFailure
    
    do {
        let htmlString = NSString(data: data, encoding: NSUTF8StringEncoding)!
        let jsonString = htmlString.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: NSMakeRange(0, htmlString.length))
        let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
        jsonOptional = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions(rawValue: 0))
    } catch _ as NSError {
        __error = .ParsingFailure
        jsonOptional = []
    }
    
    return resultFromOptional(jsonOptional, error: __error)
}

internal func decodeJSONObject<U: JSONDecodable>(json: JSON) -> Result<U, Error> {
    return resultFromOptional(U.decode(json), error: .ParsingFailure)
}
