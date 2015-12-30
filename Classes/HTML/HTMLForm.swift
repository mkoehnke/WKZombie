//
// HTMLForm.swift
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

/// HTML Form class, which represents the <form> element in the DOM.
public class HTMLForm : HTMLElement {

    /// All inputs fields (keys and values) of this form.
    var inputs = [String : String]()
    
    required public init?(element: AnyObject, pageURL: NSURL? = nil) {
        super.init(element: element, pageURL: pageURL)
        if let element = HTMLElement(element: element) {
            retrieveAllInputs(element)
        }
    }
    
    /// Returns the value for the name attribute.
    public var name : String? {
        return objectForKey("name")
    }
    
    /// Returns the value for the action attribute.
    public var action : String? {
        return objectForKey("action")
    }
    
    /**
     Enables subscripting for modifying the input field values.
     
     - parameter input: The Input field attribute name.
     
     - returns: The Input field attribute value.
     */
    public subscript(input: String) -> String? {
        get {
            return inputs[input]
        }
        set (newValue) {
            inputs[input] = newValue
        }
    }
    
    //========================================
    // MARK: Overrides
    //========================================
    
    internal override class func keyValueQuery(key: String, value: String) -> String {
        return "//form[@\(key)='\(value)']"
    }
    
    //========================================
    // MARK: Private Methods
    //========================================
    
    private func retrieveAllInputs(element: HTMLElement) {
        if let tagName = element.tagName as String? where tagName == "input" {
            if let name = element.objectForKey("name") {
                inputs[name] = element.objectForKey("value")
            }
        }
        if let children = element.children() as [HTMLElement]? where children.count > 0 {
            for child in children {
                retrieveAllInputs(child)
            }
        }
    }
}