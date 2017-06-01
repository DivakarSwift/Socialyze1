//
//  AdsViewController.swift
//  Slide
//
//  Created by Rajendra on 5/29/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit

class AdsViewController: UIViewController {
    
    var place:Place!
    var imageView:UIImageView!
    
    override func viewDidLoad() {
        
        self.addSwipeGesture(toView: self.view)
        self.imageView = self.view.viewWithTag(1) as! UIImageView!
        if let url = self.place.ads?.first?.image {
            let imageUrl = URL(string: url)
            imageView.kf.indicatorType = .activity
            self.imageView.kf.setImage(with: imageUrl)
        }
    }
    
    func addSwipeGesture(toView view: UIView) {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(wasSwipped))
        gesture.direction = .down
        view.addGestureRecognizer(gesture)
    }
    
    func wasSwipped(_ gesture: UISwipeGestureRecognizer) {
                dismiss(animated: true, completion: nil)
        UIApplication.shared.isStatusBarHidden = false
    }
}
