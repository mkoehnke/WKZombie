//
//  Page.swift
//  HeadlessDemo
//
//  Created by Mathias Köhnke on 23/11/15.
//  Copyright © 2015 Mathias Köhnke. All rights reserved.
//

import Foundation


public protocol Page {
    static func pageWithData(data: NSData?, url: NSURL?) -> Page?
}


