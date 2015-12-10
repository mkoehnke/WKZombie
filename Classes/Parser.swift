//
// Parser.swift
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
import hpple

public class Parser : NSObject {
    
    public private(set) var url : NSURL?
    
    required public init(data: NSData, url: NSURL? = nil) {
        super.init()
        self.url = url
    }
    
}

//========================================
// MARK: HTML
//========================================

public class HTMLParser : Parser {
    
    private var doc : TFHpple?
    
    required public init(data: NSData, url: NSURL? = nil) {
        super.init(data: data, url: url)
        self.doc = TFHpple(HTMLData: data)
    }
    
    public func searchWithXPathQuery(xPathOrCSS: String) -> [AnyObject]? {
        return doc?.searchWithXPathQuery(xPathOrCSS)
    }
    
    public var data: NSData? {
        return doc?.data
    }
    
    override public var description : String {
        return (NSString(data: doc?.data ?? NSData(), encoding: NSUTF8StringEncoding) ?? "") as String
    }
}

public class HTMLParserElement : NSObject {
    private var element : TFHppleElement?
    public internal(set) var pageURL : NSURL?
    
    required public init?(element: AnyObject, pageURL: NSURL? = nil) {
        super.init()
        if let element = element as? TFHppleElement {
            self.element = element
            self.pageURL = pageURL
        } else {
            return nil
        }
    }
    
    public var innerContent : String? {
        return element?.raw as String?
    }
    
    public var text : String? {
        return element?.text() as String?
    }
    
    public var content : String? {
        return element?.content as String?
    }
    
    public var tagName : String? {
        return element?.tagName as String?
    }
    
    public func objectForKey(key: String) -> String? {
        return element?.objectForKey(key) as String?
    }
    
    public func childrenWithTagName<T: HTMLElement>(tagName: String) -> [T]? {
        return element?.childrenWithTagName(tagName).flatMap { T(element: $0, pageURL: pageURL) }
    }
    
    public func children<T: HTMLElement>() -> [T]? {
        return element?.children.flatMap { T(element:$0, pageURL: pageURL) }
    }
    
    public func hasChildren() -> Bool {
        return element?.hasChildren() ?? false
    }
    
    override public var description : String {
        return element?.raw ?? ""
    }
}


//========================================
// MARK: JSON
//========================================

public class JSONParser : Parser {
    
    private var json : JSON?
    
    required public init(data: NSData, url: NSURL? = nil) {
        super.init(data: data, url: url)
        let result = parseJSON(data)
        switch result {
        case .Success(let json): self.json = json
        case .Error: print("Error parsing JSON!")
        }
    }
    
    public func decodeObject<T: JSONDecodable>() -> Result<T, Error> {
        if let json = json {
            return decodeJSONObject(json)
        }
        return Result.Error(.ParsingFailure)
    }
    
    override public var description : String {
        return "\(json)"
    }
}



