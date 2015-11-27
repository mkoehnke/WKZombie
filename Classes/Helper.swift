//
//  Helper.swift
//  HeadlessDemo
//
//  Created by Mathias Köhnke on 25/11/15.
//  Copyright © 2015 Mathias Köhnke. All rights reserved.
//

import Foundation

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

//
// MARK: Futures
// Borrowed from Javier Soto's 'Back to the Futures' Talk
// https://speakerdeck.com/javisoto/back-to-the-futures
//

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
    
    func mapError<F>(f: E -> F) -> Future<T, F> {
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

public func repeatUntil<T, E: ErrorType>(initial: T, f: T -> Future<T, E>, condition: T -> Bool) -> Future<[T], E> {
    var values : [T] = [initial]
    func loop(value : T) -> Future<[T], E> {
        if condition(value) == true {
            return Future<[T], E>(operation: { completion in
                f(value).start({ result in
                    switch result {
                    case .Success(let newValue):
                        values.append(newValue)
                        loop(newValue).start(completion)
                    case .Error(let error): completion(Result.Error(error))
                    }
                })
            })
        } else {
            return Future<[T], E>(result: Result.Success(values))
        }
    }
    return loop(initial)
}


//
// MARK: Response
//


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
internal func >>><A, B>(a: Result<A, NetworkErrorDomain>, f: A -> Result<B, NetworkErrorDomain>) -> Result<B, NetworkErrorDomain> {
    switch a {
    case let .Success(x):   return f(x)
    case let .Error(error): return .Error(error)
    }
}

public func >>><T, U, E: ErrorType>(a: Future<T, E>, f: T -> Future<U, E>) -> Future<U, E> {
    return a.andThen(f)
}


internal func parseResponse(response: Response) -> Result<NSData, NetworkErrorDomain> {
    guard let data = response.data else {
        return .Error(.NetworkRequestFailure)
    }
    
    let successRange = 200..<300
    if !successRange.contains(response.statusCode) {
        return .Error(.NetworkRequestFailure)
    }
    return Result(nil, data)
}

internal func resultFromOptional<A>(optional: A?, error: NetworkErrorDomain) -> Result<A, NetworkErrorDomain> {
    if let a = optional {
        return .Success(a)
    } else {
        return .Error(error)
    }
}

internal func decodeResult(url: NSURL? = nil)(data: NSData?) -> Result<Page, NetworkErrorDomain> {
    return resultFromOptional((data == nil) ? nil : Page(data: data!, url: url), error: .NetworkRequestFailure)
}
