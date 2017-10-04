//
//  LoadingViewController.swift
//  Slide
//
//  Created by bibek timalsina on 10/4/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIView.animate(withDuration: 1, delay: 0, options: .repeat, animations: {
            self.imageView.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi * 2)
        }, completion: nil)
    }

}
