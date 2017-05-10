//
//  Utilities.swift
//  Slide
//
//  Created by bibek on 5/3/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher


class Utilities: NSObject {

    class func returnAge(ofValue date: String, format :String) -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = NSTimeZone.system
        let birthday = dateFormatter.date(from: date)
        
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthday!, to: Date())
        let age = ageComponents.year!
        
        return age
    }
    
}

struct MyIndicator: Indicator {
    let view: UIView = CustomActivityIndicatorView(image: #imageLiteral(resourceName: "ladybird.png"))
    let indicatorView = CustomActivityIndicatorView(image: #imageLiteral(resourceName: "ladybird.png"))
    func startAnimatingView() { indicatorView.startAnimating() }
    func stopAnimatingView() { indicatorView.stopAnimating() }
    
    init() {
        view.backgroundColor = .red
        view.addSubview(indicatorView)
    }
}


