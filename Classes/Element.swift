//
//  Element.swift
//  HeadlessDemo
//
//  Created by Mathias Köhnke on 26/11/15.
//  Copyright © 2015 Mathias Köhnke. All rights reserved.
//

import Foundation

public class Element : NSObject {
    
    internal var parsedObject : TFHppleElement?
    
    public init?(parsedObject: AnyObject) {
        super.init()
        if let parsedObject = parsedObject as? TFHppleElement {
            self.parsedObject = parsedObject
        } else {
            return nil
        }
    }
    
    override public var description : String {
        return parsedObject?.raw ?? ""
    }
}