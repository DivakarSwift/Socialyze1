//
//  SwipingViewController.swift
//  Slide
//
//  Created by Salem Khan on 3/7/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit

class SwipingViewController: UIViewController {
    var users: [User] = [] {
        didSet {
            self.userBio.text = users.first?.bio
            self.imageView.kf.setImage(with: users.first?.images.first)
            self.userNameAgeLabel.text = users.first?.name
        }
    }
    
    lazy fileprivate var activityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: "ladybird.png")!
        return CustomActivityIndicatorView(image: image)
    }()
    
    @IBOutlet weak var userNameAgeLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var userBio: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    
    @IBAction func reportUser(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let block = UIAlertAction(title: "Block", style: .default) { (_) in
            if let user = self.users.first {
                self.activityIndicator.startAnimating()
                FirebaseManager.shared.block(user: user, completion: { (success, error) in
                    self.activityIndicator.stopAnimating()
                    if success {
                        self.alert(message: "User blocked.")
                        self.users.remove(at: 0)
                    }else {
                        self.alert(message: "Can't unblock the user. Try again!")
                    }
                })
            }
        }
        
        let reportAndBlock = UIAlertAction(title: "Report", style: .default) { (_) in
            if let user = self.users.first {
                let reportAlert = UIAlertController(title: "Report Remarks", message: "", preferredStyle: .alert)
                reportAlert.addTextField(configurationHandler: { (textField) in
                    textField.placeholder = "Remarks"
                })
                
                let ok = UIAlertAction(title: "Report", style: .default, handler: { (_) in
                    self.activityIndicator.startAnimating()
                    FirebaseManager.shared.blockAndReport(user: user, remark: "", completion: { (success, error) in
                        self.activityIndicator.stopAnimating()
                        if success {
                            self.alert(message: "Reported on user.")
                            self.users.remove(at: 0)
                        }else {
                            self.alert(message: "Can't report the user. Try again!")
                        }
                    })
                })
                
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                reportAlert.addAction(ok)
                reportAlert.addAction(cancel)
                
                self.present(reportAlert, animated: true, completion: nil)
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(block)
        alert.addAction(reportAndBlock)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
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
        
        self.infoButton.rounded()
        self.infoButton.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        
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
