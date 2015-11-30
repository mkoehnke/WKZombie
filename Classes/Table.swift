//
//  Table.swift
//  HeadlessDemo
//
//  Created by Mathias Köhnke on 30/11/15.
//  Copyright © 2015 Mathias Köhnke. All rights reserved.
//

import Foundation

public class Table : Element {
    
    var rows : [Element]? {
        return children
    }
    
}
