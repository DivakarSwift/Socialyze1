//
//  PDGradientView.swift
//  PlanetDaily
//
//  Created by Mac on 12/14/16.
//  Copyright © 2016 Kick Punch Labs. All rights reserved.
//

import UIKit

class PDGradientView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    // Default Colors
    override open class var layerClass: AnyClass {
        get{
            return CAGradientLayer.classForCoder()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let gradientLayer = self.layer as! CAGradientLayer
        let color1 = UIColor.black.withAlphaComponent(0.1).cgColor as CGColor
        let color2 = UIColor.black.withAlphaComponent(0.1).cgColor as CGColor
        gradientLayer.locations = [0.10, 0.90]
        gradientLayer.colors = [color1, color2]
    }
}
