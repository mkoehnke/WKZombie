//
//  Form.swift
//  HeadlessDemo
//
//  Created by Mathias Köhnke on 23/11/15.
//  Copyright © 2015 Mathias Köhnke. All rights reserved.
//

import Foundation

public class HTMLForm : HTMLElement {

    var inputs = [String : String]()
    
    required public init?(element: AnyObject, pageURL: NSURL? = nil) {
        super.init(element: element, pageURL: pageURL)
        if let element = HTMLElement(element: element) {
            self.collectInputs(element)
        }
    }
    
    public var action : String? {
        return objectForKey("action")
    }
    
    private var onSubmit : String? {
        return objectForKey("onSubmit")
    }
    
    public var name : String? {
        return objectForKey("name")
    }
     
    public subscript(input: String) -> String? {
        get {
            return inputs[input]
        }
        set (newValue) {
            inputs[input] = newValue
        }
    }
    
    private func collectInputs(element: HTMLElement) {
        if let tagName = element.tagName as String? where tagName == "input" {
            if let name = element.objectForKey("name") {
                inputs[name] = element.objectForKey("value")
            }
        }
        if let children = element.children() as [HTMLElement]? where children.count > 0 {
            for child in children {
                collectInputs(child)
            }
        }
    }
}