//
//  Table.swift
//  HeadlessDemo
//
//  Created by Mathias Köhnke on 30/11/15.
//  Copyright © 2015 Mathias Köhnke. All rights reserved.
//

import Foundation

public class HTMLTableRow : HTMLElement {
    var columns : [HTMLTableColumn]? {
        return children()
    }
}

public class HTMLTableColumn : HTMLElement {
    
}

public class HTMLTable : HTMLElement {
    
    var rows : [HTMLTableRow]? {
        let rows : [HTMLTableRow]? = children()
        return (rows?.first?.tagName == "tbody") ? rows?.first?.children() : rows
    }
    

    func columnsWithPattern(key: String, value: String) -> [HTMLTableColumn]? {
        
        var elements = [HTMLTableColumn]()
        func findColumns(column: HTMLTableColumn) {
            if let tagName = column.tagName as String? where tagName == "td" {
                if let _value = column.objectForKey(key) where value == _value  {
                    elements.append(column)
                }
            }
            if let children = column.children() as [HTMLTableColumn]? where children.count > 0 {
                for child in children {
                    findColumns(child)
                }
            }
        }

        if let rows = rows {
            for row in rows {
                if let columns = row.columns {
                    for column in columns {
                        findColumns(column)
                    }
                }
            }
        }

        return elements
    }
}
