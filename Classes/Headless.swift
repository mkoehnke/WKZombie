//
//  Headless.swift
//  HeadlessDemo
//
//  Created by Mathias Köhnke on 23/11/15.
//  Copyright © 2015 Mathias Köhnke. All rights reserved.
//

import Foundation


public class Headless : NSObject {
    
    private var renderer : Renderer!
    
    public private(set) var name : String!
    public var allowRedirects : Bool = true
    public var loadMediaContent : Bool = true {
        didSet {
            renderer.loadMediaContent = loadMediaContent
        }
    }
    
    public init(name: String? = "Headless") {
        super.init()
        self.name = name
        self.renderer = Renderer()
    }
 
    // MARK: Get Page
    
    private func get<T: Page>(url: NSURL, postAction: PostAction? = nil) -> Future<T, Error> {
        return Future() { [unowned self] completion in
            let request = NSURLRequest(URL: url)
            self.renderer.renderPageWithRequest(request, postAction: postAction, completionHandler: { data, response, error in
                completion(self.handleResponse(data as? NSData, response: response, error: error))
            })
        }
    }
    
    public func get<T: Page>(url: NSURL) -> Future<T, Error> {
        return get(url, postAction: nil)
    }
    
    public func get<T: Page>(condition: String)(url: NSURL) -> Future<T, Error> {
        return get(url, postAction: PostAction(type: .Validate, script: condition))
    }

    public func get<T: Page>(wait: NSTimeInterval)(url: NSURL) -> Future<T, Error> {
        return get(url, postAction: PostAction(type: .Wait, wait: wait))
    }
    
    // MARK: Submit Form
    
    private func submit<T: Page>(form: HTMLForm, postAction: PostAction? = nil) -> Future<T, Error> {
        return Future() { [unowned self] completion in
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
    
    public func submit<T: Page>(form: HTMLForm) -> Future<T, Error> {
        return submit(form, postAction: nil)
    }
    
    public func submit<T: Page>(condition: String)(form: HTMLForm) -> Future<T, Error> {
        return submit(form, postAction: PostAction(type: .Validate, script: condition))
    }

    public func submit<T: Page>(wait: NSTimeInterval)(form: HTMLForm) -> Future<T, Error> {
        return submit(form, postAction: PostAction(type: .Wait, wait: wait))
    }
    
    
    // MARK: Click Event
    
    private func click<T: Page>(link : HTMLLink, postAction: PostAction? = nil) -> Future<T, Error> {
        return Future() { [unowned self] completion in
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
    
    public func click<T: Page>(link : HTMLLink) -> Future<T, Error> {
        return click(link, postAction: nil)
    }
    
    public func click<T: Page>(condition: String)(link : HTMLLink) -> Future<T, Error> {
        return click(link, postAction: PostAction(type: .Validate, script: condition))
    }
    
    public func click<T: Page>(wait: NSTimeInterval)(link : HTMLLink) -> Future<T, Error> {
        return click(link, postAction: PostAction(type: .Wait, wait: wait))
    }
    
    
    //
    // MARK: Private
    //
    private func handleResponse<T: Page>(data: NSData?, response: NSURLResponse?, error: NSError?) -> Result<T, Error> {
        guard let response = response else {
            return decodeResult(nil)(data: nil)
        }
        let errorDomain : Error? = (error == nil) ? nil : .NetworkRequestFailure
        let responseResult: Result<Response, Error> = Result(errorDomain, Response(data: data, urlResponse: response))
        return responseResult >>> parseResponse >>> decodeResult(response.URL)
    }
    
    
    // MARK : Scripts
    
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