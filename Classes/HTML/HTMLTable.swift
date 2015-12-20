//
// HTMLTable.swift
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

/// HTML Table class, which represents the <table> element in the DOM.
public class HTMLTable : HTMLElement {
    
    /// Returns all row elements within this table
    var rows : [HTMLTableRow]? {
        let rows : [HTMLTableRow]? = children()
        return (rows?.first?.tagName == "tbody") ? rows?.first?.children() : rows
    }
    
    /**
     Finds all table columns that match the specified key-value pattern.
     
     - parameter key:   The attribute name.
     - parameter value: The attribute value.
     
     - returns: An Array containing table columns.
     */
    func findColumnsWithPattern(key: String, value: String) -> [HTMLTableColumn]? {
        var elements = [HTMLTableColumn]()
        
        // Helper: Search recursively for columns with pattern
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

        // Call helper function for each column
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


/// HTML Table Row Class, which represents the <tr> element in the DOM.
public class HTMLTableRow : HTMLElement {
    
    /// Returns all columns within this row.
    var columns : [HTMLTableColumn]? {
        return children()
    }
}

/// HTML Table Column class, which represents the <td> element in the DOM.
public class HTMLTableColumn : HTMLElement {
    
}
