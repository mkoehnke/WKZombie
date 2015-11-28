//
//  Form.swift
//  HeadlessDemo
//
//  Created by Mathias Köhnke on 23/11/15.
//  Copyright © 2015 Mathias Köhnke. All rights reserved.
//

import Foundation

public class Form : Element {
    
    private var inputs = [String : String]()
    
    public var action : String? {
        return objectForKey("action")
    }
    
    public var actionRequest : NSURLRequest? {
        if let action = action {
            return createURLRequest(action, parameters: inputs)
        }
        return nil
    }
 
    subscript(input: String) -> String? {
        get {
            return inputs[input]
        }
        set (newValue) {
            inputs[input] = newValue
        }
    }
    
    func collectInputs(element: Element) {
        if let tagName = element.tagName as String? where tagName == "input" {
            if let name = element.objectForKey("name") {
                inputs[name] = element.objectForKey("value")
            }
        }
        if let children = element.children where children.count > 0 {
            for child in children {
                collectInputs(child)
            }
        }
    }

    private func createURLRequest(path: String, parameters: [String : String]) -> NSURLRequest? {
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        request.HTTPMethod = "POST"
        
        let keysAndValues = parameters.map {"\($0)=\($1)"}
        let flatKeysAndValues = keysAndValues.joinWithSeparator("&")
        let data : NSData! = (flatKeysAndValues as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPBody = data
        
        return request
    }
}