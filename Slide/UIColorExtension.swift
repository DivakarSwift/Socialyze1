//
//  UIColorExtension.swift
//  Slide
//
//  Created by Rajendra on 6/24/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    open class var appPurple: UIColor {
        return UIColor(0x813284)
    }
    
    open class var appGreen : UIColor {
        return UIColor(0x17CD41)
    }
}

extension UIColor {

    convenience init(_ hex: UInt) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
}
