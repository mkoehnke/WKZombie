//
//  Button.swift
//  HeadlessDemo
//
//  Created by Mathias Köhnke on 06/12/15.
//  Copyright © 2015 Mathias Köhnke. All rights reserved.
//

import UIKit

public class Button : UIButton {
    
    override public var enabled: Bool {
        didSet {
            if enabled == true {
                backgroundColor = UIColor(red: 0.0/255.9, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            } else {
                backgroundColor = .darkGrayColor()
            }
        }
    }
    
}
