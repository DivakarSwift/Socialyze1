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
    fileprivate var stop: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transform()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stop = true
    }
    
    func transform() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
            self.imageView.transform = self.imageView.transform.concatenating(CGAffineTransform.init(rotationAngle: CGFloat.pi))
        }, completion: {_ in
            if !self.stop {
                self.transform()
            }
        })
    }

}
