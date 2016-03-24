//
// HTMLFetchable.swift
//
// Copyright (c) 2016 Mathias Koehnke (http://www.mathiaskoehnke.com)
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
import ObjectiveC

//==========================================
// MARK: Fetchable Protocol
//==========================================

public protocol HTMLFetchable : NSObjectProtocol {
    var fetchURL : NSURL? { get }
    func fetchedContent<T: HTMLFetchableContent>() -> T?
}

private var WKZFetchedDataKey: UInt8 = 0

//==========================================
// MARK: Fetchable Default Implementation
//==========================================

extension HTMLFetchable {
    internal var fetchedData: NSData? {
        get {
            return objc_getAssociatedObject(self, &WKZFetchedDataKey) as? NSData
        }
        set(newValue) {
            objc_setAssociatedObject(self, &WKZFetchedDataKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    public func fetchedContent<T : HTMLFetchableContent>() -> T? {
        if let fetchedData = fetchedData {
            switch T.instanceFromData(fetchedData) {
            case .Success(let value): return value as? T
            case .Error: return nil
            }
        }
        return nil
    }
}


//==========================================
// MARK: FetchableContentType Protocol
//==========================================

public protocol HTMLFetchableContent {
    associatedtype ContentType
    static func instanceFromData(data: NSData) -> Result<ContentType>
}

//==========================================
// MARK: Supported Fetchable Content Types
//==========================================

#if os(iOS)
    import UIKit
    extension UIImage : HTMLFetchableContent {
        public typealias ContentType = UIImage
        public static func instanceFromData(data: NSData) -> Result<ContentType> {
            if let image = UIImage(data: data) {
                return Result.Success(image)
            }
            return Result.Error(.TransformFailure)
        }
    }
#elseif os(OSX)
    import Cocoa
    extension NSImage : HTMLFetchableContent {
        public typealias ContentType = NSImage
        public static func instanceFromData(data: NSData) -> Result<ContentType> {
            if let image = NSImage(data: data) {
                return Result.Success(image)
            }
            return Result.Error(.TransformFailure)
        }
    }
#endif

extension NSData : HTMLFetchableContent {
    public typealias ContentType = NSData
    public static func instanceFromData(data: NSData) -> Result<ContentType> {
        return Result.Success(data)
    }
}