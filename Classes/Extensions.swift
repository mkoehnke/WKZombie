//
//  Extensions.swift
//  HeadlessDemo
//
//  Created by Mathias Köhnke on 29/11/15.
//  Copyright © 2015 Mathias Köhnke. All rights reserved.
//

import Foundation

internal extension String {
    internal func beginsWith (str: String) -> Bool {
        if let range = self.rangeOfString(str) {
            return range.startIndex == self.startIndex
        }
        return false
    }
    
    internal func endsWith (str: String) -> Bool {
        if let range = self.rangeOfString(str, options:NSStringCompareOptions.BackwardsSearch) {
            return range.endIndex == self.endIndex
        }
        return false
    }
}

extension NSMutableURLRequest {
    
    private func percentEscapeString(string: String) -> String {
        let characterSet = NSCharacterSet.alphanumericCharacterSet().mutableCopy() as! NSMutableCharacterSet
        characterSet.addCharactersInString("-._* ")
        
        return string
            .stringByAddingPercentEncodingWithAllowedCharacters(characterSet)!
            .stringByReplacingOccurrencesOfString(" ", withString: "+", options: [], range: nil)
    }
    
    func encodeParameters(parameters: [String : String]) {
        HTTPMethod = "POST"
        
        let parameterArray = parameters.map { (key, value) -> String in
            return "\(key)=\(self.percentEscapeString(value))"
        }
        
        HTTPBody = parameterArray.joinWithSeparator("&").dataUsingEncoding(NSUTF8StringEncoding)
    }
}