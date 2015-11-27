//
//  Headless.swift
//  HeadlessDemo
//
//  Created by Mathias Köhnke on 23/11/15.
//  Copyright © 2015 Mathias Köhnke. All rights reserved.
//

import Foundation


public class Headless : NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate {
    
    public private(set) var name : String!
    public var allowRedirects : Bool = true
    
    public init(name: String? = "Headless") {
        super.init()
        self.name = name
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
    }
 
    public func get(url: NSURL) -> Future<Page, NetworkErrorDomain> {
        return Future() { [unowned self] completion in
            let request = NSURLRequest(URL: url)
            let task = self.session.dataTaskWithRequest(request) { [unowned self] data, response, error in
                completion(self.handleResponse(data, response: response, error: error))
            }
            task.resume()
        }
    }

    public func submit(form: Form) -> Future<Page, NetworkErrorDomain> {
        return Future() { [unowned self] completion in
            if let request = form.actionRequest {
                let task = self.session.dataTaskWithRequest(request) { [unowned self] data, response, error in
                    completion(self.handleResponse(data, response: response, error: error))
                }
                task.resume()
            } else {
                completion(Result.Error(.NetworkRequestFailure))
            }
        }
    }
    
    public func click(link : Link) -> Future<Page, NetworkErrorDomain> {
        return Future() { [unowned self] completion in
            if let url = link.hrefURL {
                let task = self.session.dataTaskWithRequest(NSURLRequest(URL: url)) { [unowned self] data, response, error in
                    completion(self.handleResponse(data, response: response, error: error))
                }
                task.resume()
            } else {
                completion(Result.Error(.NetworkRequestFailure))
            }
        }
    }
    
    //
    // MARK: Delegate
    //
    
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void) {
        completionHandler((allowRedirects) ? request : nil)
    }
    
    
    //
    // MARK: Private
    //
    private var session : NSURLSession!
    
    private func handleResponse(data: NSData?, response: NSURLResponse?, error: NSError?) -> Result<Page, NetworkErrorDomain> {
        guard let response = response else {
            return decodeResult(nil)(data: nil)
        }
        let errorDomain : NetworkErrorDomain? = (error == nil) ? nil : .NetworkRequestFailure
        let responseResult: Result<Response, NetworkErrorDomain> = Result(errorDomain, Response(data: data, urlResponse: response))
        return responseResult >>> parseResponse >>> decodeResult(response.URL)
    }
}