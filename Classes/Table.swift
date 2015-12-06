//
//  Table.swift
//  HeadlessDemo
//
//  Created by Mathias Köhnke on 30/11/15.
//  Copyright © 2015 Mathias Köhnke. All rights reserved.
//

import Foundation

public class TableRow : Element {
    var columns : [TableColumn]? {
        return children()
    }
}

public class TableColumn : Element {
    
}

public class Table : Element {
    
    var rows : [TableRow]? {
        let rows : [TableRow]? = children()
        return (rows?.first?.tagName == "tbody") ? rows?.first?.children() : rows
    }
    

    func columnsWithPattern(key: String, value: String) -> [TableColumn]? {
        
        var elements = [TableColumn]()
        func findColumns(column: TableColumn) {
            if let tagName = column.tagName as String? where tagName == "td" {
                if let _value = column.objectForKey(key) where value == _value  {
                    elements.append(column)
                }
            }
            if let children = column.children() as [TableColumn]? where children.count > 0 {
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
