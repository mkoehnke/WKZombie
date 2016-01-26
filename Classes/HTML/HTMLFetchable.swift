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

//==========================================
// MARK: Fetchable Protocol
//==========================================

internal protocol HTMLFetchable {
    var fetchURL : NSURL? { get }
}


//==========================================
// MARK: FetchableContentType Protocol
//==========================================

public protocol HTMLFetchableContentType {
    typealias ContentType
    static func instanceFromData(data: NSData) -> Result<ContentType>
}

//==========================================
// MARK: Supported Fetchable Content Types
//==========================================

#if os(iOS)
    import UIKit
    extension UIImage : HTMLFetchableContentType {
        public static func instanceFromData(data: NSData) -> Result<UIImage> {
            if let image = UIImage(data: data) {
                return Result.Success(image)
            }
            return Result.Error(.TransformFailure)
        }
    }
#elseif os(OSX)
    import Cocoa
    extension NSImage : HTMLFetchableContentType {}
#endif

extension NSData : HTMLFetchableContentType {
    public static func instanceFromData(data: NSData) -> Result<NSData> {
        return Result.Success(data)
    }
}