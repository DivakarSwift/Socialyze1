//
//  SwipingViewController.swift
//  Slide
//
//  Created by Salem Khan on 3/7/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit

class SwipingViewController: UIViewController {
    lazy fileprivate var activityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: "ladybird.png")!
        return CustomActivityIndicatorView(image: image)
    }()
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var userBio: UILabel!
    @IBAction func reportUser(_ sender: Any) {
    }
     func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        
        let translation = gestureRecognizer.translation(in: view)
        
        let label = gestureRecognizer.view!
        
        label.center = CGPoint(x: self.view.bounds.width / 2 + translation.x, y: self.view.bounds.height / 2 + translation.y)
        
        let xFromCenter = label.center.x - self.view.bounds.width / 2
        
        var rotation = CGAffineTransform(rotationAngle: xFromCenter / 200)
        
        let scale = min(abs(100 / xFromCenter), 1)
        
        var stretchAndRotation = rotation.scaledBy(x: scale, y: scale) // rotation.scaleBy(x: scale, y: scale) is now rotation.scaledBy(x: scale, y: scale)
        
        label.transform = stretchAndRotation
        
        
        if gestureRecognizer.state == UIGestureRecognizerState.ended {
            
            if label.center.x < 100 {
                
                print("Reject")
                
            } else if label.center.x > self.view.bounds.width - 100 {
                
                print("Accept")
                
            }
            
            rotation = CGAffineTransform(rotationAngle: 0)
            
            stretchAndRotation = rotation.scaledBy(x: 1, y: 1) // rotation.scaleBy(x: scale, y: scale) is now rotation.scaledBy(x: scale, y: scale)
            
            
            label.transform = stretchAndRotation
            
            label.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
            
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addLoadingIndicator()
   
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.wasDragged(gestureRecognizer:)))
        
        imageView.isUserInteractionEnabled = true
        
        imageView.addGestureRecognizer(gesture)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.activityIndicator.stopAnimating()
    }
    
    func addLoadingIndicator () {
        self.view.addSubview(activityIndicator)
        activityIndicator.center = self.view.center
    }

}
