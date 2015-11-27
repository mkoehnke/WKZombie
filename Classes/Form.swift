//
//  Form.swift
//  HeadlessDemo
//
//  Created by Mathias Köhnke on 23/11/15.
//  Copyright © 2015 Mathias Köhnke. All rights reserved.
//

import Foundation
import hpple

public class Form : Element {
    
    private var inputs = [String : String]()
    
    public var action : String? {
        return parsedObject?.objectForKey("action")
    }
    
    public var actionRequest : NSURLRequest? {
        if let action = action {
            return createURLRequest(action, parameters: inputs)
        }
        return nil
    }
    
    override init?(parsedObject: AnyObject) {
        super.init(parsedObject: parsedObject)
        if let parsedObject = self.parsedObject {
            self.collectInputs(parsedObject)
        } else {
            return nil
        }
    }
 
    subscript(input: String) -> String? {
        get {
            return inputs[input]
        }
        set (newValue) {
            inputs[input] = newValue
        }
    }
    
    func collectInputs(element: TFHppleElement) {
        if let tagName = element.tagName as String? where tagName == "input" {
            if let name = element.objectForKey("name") {
                inputs[name] = element.objectForKey("value")
            }
        }
        if element.children.count > 0 {
            for child in element.children {
                collectInputs(child as! TFHppleElement)
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