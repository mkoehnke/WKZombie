//
//  Parser.swift
//  HeadlessDemo
//
//  Created by Mathias Köhnke on 28/11/15.
//  Copyright © 2015 Mathias Köhnke. All rights reserved.
//

import Foundation
import hpple

public class Parser : NSObject {
    private var doc : TFHpple?
    init?(doc: AnyObject) {
        super.init()
        if let doc = doc as? TFHpple {
            self.doc = doc
        } else {
            return nil
        }
    }
}



public class ParserElement : NSObject {
    private var element : TFHppleElement?
    init?(element: AnyObject) {
        super.init()
        if let element = element as? TFHppleElement {
            self.element = element
        } else {
            return nil
        }
    }
    
    public var text : String? {
        return element?.text() as String?
    }
    
    public var tagName : String? {
        return element?.tagName as String?
    }
    
    public func objectForKey(key: String) -> String? {
        return element?.objectForKey(key) as String?
    }
    
    public var children: [Element]? {
        return element?.children.flatMap { Element(element:$0) }
    }
    
    override public var description : String {
        return element?.raw ?? ""
    }
}
