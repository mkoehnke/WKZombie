//
//  JSONPage.swift
//  HeadlessDemo
//
//  Created by Mathias Köhnke on 08/12/15.
//  Copyright © 2015 Mathias Köhnke. All rights reserved.
//

import Foundation

public protocol JSONDecodable {
    static func decode(json: JSON) -> Self?
}

public class JSONPage : JSONParser, Page {
    
    public static func pageWithData(data: NSData?, url: NSURL?) -> Page? {
        if let data = data {
            return JSONPage(data: data, url: url)
        }
        return nil
    }
    
}