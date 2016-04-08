//
//  Logger.swift
//  WKZombie
//
//  Created by Mathias Köhnke on 08/04/16.
//  Copyright © 2016 Mathias Köhnke. All rights reserved.
//

import Foundation

/// WKZombie Console Logger
public class Logger : NSObject {
    
    public static var enabled : Bool = true
    
    public class func log(message: String, lineBreak: Bool = true) {
        if enabled {
            if lineBreak {
                print("\(message)")
            } else {
                print("\(message)", terminator: "")
            }
        }
    }
}
