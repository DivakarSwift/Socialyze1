//
//  UIViewExtension.swift
//  veda
//
//  Created by bibek timalsina on 1/10/17.
//  Copyright © 2017 veda. All rights reserved.
//

import UIKit

extension UIView {
    func set(cornerRadius radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    func set(border: UIColor) {
        self.layer.borderColor = border.cgColor;
    }
    
    func set(borderWidth: CGFloat) {
        self.layer.borderWidth = borderWidth
    }
    
    func set(borderWidth width: CGFloat, of color: UIColor) {
        self.set(border: color)
        self.set(borderWidth: width)
    }
    
    func rounded() {
        self.set(cornerRadius: self.frame.height/2)
    }
    
    func show(value: Bool) {
        self.isHidden = !value
    }
    
    func roundedImage() {
        self.rounded()
        self.set(borderWidth: 2, of: .white)
    }
    
}
