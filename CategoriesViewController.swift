//
//  CategoriesViewController.swift
//  Slide
//
//  Created by Salem Khan on 3/8/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit

class CategoriesViewController: UIViewController {
    
    var users: [User] = [] {
        didSet {
            self.imageView.kf.setImage(with: users.first?.images.first)
            self.userName.text = users.first?.name
        }
    }
    
    var events: [Event] = [] {
        didSet {
//            self.eventDescription.text = events.first
        }
    }
  
    let categoryDefaults = UserDefaults.standard
    
    lazy fileprivate var activityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: "ladybird.png")!
        return CustomActivityIndicatorView(image: image)
    }()
    
    let userService = UserService()
    
    @IBOutlet weak var actionImageView: UIImageView!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var eventDescription: UILabel!
    @IBOutlet var userName: UILabel!
    
    @IBAction func reportUser(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let block = UIAlertAction(title: "Block", style: .default) { (_) in
            if let user = self.users.first {
                self.activityIndicator.startAnimating()
                self.userService.block(user: user, completion: {[weak self] (success, error) in
                    self?.activityIndicator.stopAnimating()
                    if success {
                        self?.alert(message: "User blocked.")
                        self?.users.remove(at: 0)
                        self?.events.remove(at: 0)
                    }else {
                        self?.alert(message: "Can't unblock the user. Try again!")
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
                    self.userService.blockAndReport(user: user, remark: "", completion: { [weak self] (success, error) in
                        self?.activityIndicator.stopAnimating()
                        if success {
                            self?.alert(message: "Reported on user.")
                            self?.users.remove(at: 0)
                            self?.events.remove(at: 0)
                        }else {
                            self?.alert(message: "Can't report the user. Try again!")
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
        
        if label.center.x < 150 {
            actionImageView.image = #imageLiteral(resourceName: "crossmark")
            actionImageView.isHidden = false
        }else if label.center.x > self.view.bounds.width - 150 {
            actionImageView.image = #imageLiteral(resourceName: "checkmark")
            actionImageView.isHidden = false
        }else {
            actionImageView.isHidden = true
        }
        
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
