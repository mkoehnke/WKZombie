//
//  Error.swift
//  HeadlessDemo
//
//  Created by Mathias Köhnke on 26/11/15.
//  Copyright © 2015 Mathias Köhnke. All rights reserved.
//

import Foundation

public protocol ErrorType { }

public enum NoError: ErrorType { }

extension NSError: ErrorType { }

public enum Error: ErrorType {
    case NetworkRequestFailure
    case NotFound
}

extension Error: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .NetworkRequestFailure: return "NetworkRequestFailure"
        case .NotFound: return "NotFound"
        }
    }
}
