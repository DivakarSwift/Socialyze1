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
            if let images = users.first?.profile.images {
                self.images = images
            }
            if oldValue.count == 0 && users.count == 1 {
                changeUser()
            }
        }
    }
    
    var images = [URL]() {
        didSet {
            if images.count == 1 {
                changeImage()
            }else if images.count == 2 {
                //  startTimer()
            }
        }
    }
    var currentImageIndex = 0
    
    var events: [Event] = [] {
        didSet {
            //            self.eventDescription.text = events.first
        }
    }
    
    var checkinUserIds = Set<String>()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.infoButton.rounded()
        self.infoButton.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        
        addLoadingIndicator()
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.wasDragged(gestureRecognizer:)))
        
        imageView.isUserInteractionEnabled = true
        
        imageView.addGestureRecognizer(gesture)
        actionImageView.isHidden = true
        
        self.addTapGesture(toView: self.imageView)
        
        self.activityIndicator.startAnimating()
        self.getAllCheckedInUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.activityIndicator.stopAnimating()
    }
    
    func addTapGesture(toView view: UIView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
    }
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        self.changeImage()
    }
    
    func changeImage() {
        if currentImageIndex < images.count && currentImageIndex >= 0 {
            let imageURL = images[currentImageIndex]
            self.imageView.kf.setImage(with: imageURL, placeholder: self.imageView.image)
        }
        if currentImageIndex == images.count - 1 {
            currentImageIndex = 0
        }else {
            currentImageIndex += 1
        }
    }
    
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
               rejectUser()
            } else if label.center.x > self.view.bounds.width - 100 {
                acceptUser()
            }
            
            rotation = CGAffineTransform(rotationAngle: 0)
            
            stretchAndRotation = rotation.scaledBy(x: 1, y: 1) // rotation.scaleBy(x: scale, y: scale) is now rotation.scaledBy(x: scale, y: scale)
            
            
            label.transform = stretchAndRotation
            
            label.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
            
            actionImageView.isHidden = true
        }
        
    }
    
    func removeTopUser() -> User? {
        let rejectedUser = self.users.first
        self.users = Array(users.dropFirst())
        self.changeUser()
        return rejectedUser
    }
    
    func rejectUser() {
        _ = removeTopUser()
    }
    
    func acceptUser() {
        if let acceptedUser = self.users.first, let myId = Authenticator.shared.user?.id {
            self.userService.accept(user: acceptedUser, myId: myId, completion: { [weak self] (success, isMatching) in
                
                if isMatching {
                    self?.addChatList(opponent: acceptedUser, myId: myId)
                } else {
                    _ = self?.removeTopUser()
                }
                return
            })
        }
    }
    
    func addChatList(opponent user: User, myId: String) {
        ChatService.shared.addChatList(for: user.id!, withMe: myId, completion: { [weak self] (success, error) in
            
            if success {
                
                let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "MatchedViewController") as! MatchedViewController
                vc.friend = user
                if let nav =  self?.navigationController {
                    nav.pushViewController(vc, animated: true)
                } else {
                    self?.present(vc, animated: true, completion: {
                        
                    })
                }
                
            } else {
                self?.alert(message: GlobalConstants.Message.oops)
            }
            
        })
    }
    
    func addLoadingIndicator () {
        self.view.addSubview(activityIndicator)
        activityIndicator.center = self.view.center
    }
    
    func getAllCheckedInUsers() {
        var acknowledgedCount = 0 {
            didSet {
                if acknowledgedCount == self.checkinUserIds.count {
                    self.activityIndicator.stopAnimating()
                }
            }
        }
        acknowledgedCount = 0
        self.checkinUserIds.forEach { (userId) in
            userService.getUser(withId: userId, completion: { [weak self] (user, error) in
                
                if let error = error {
                    self?.alert(message: error.localizedDescription)
                    return
                }
                
                if let user = user {
                    if let index = self?.users.index(of: user) {
                        self?.users[index] = user
                    }else {
                        self?.users.append(user)
                    }
                }
            })
        }
    }
    
    func changeUser() {
        if let user = users.first {
            self.imageView.kf.setImage(with: user.profile.images.first, placeholder: #imageLiteral(resourceName: "testprofile2.JPG"), options: nil, progressBlock: nil, completionHandler: nil)
//            self.imageView.kf.setImage(with: user.profile.images.first)
            self.userName.text = user.profile.name ?? "Username"
            if let dob = user.profile.dateOfBirth {
                let age = Utilities.returnAge(ofValue: dob, format: "MM/dd/yyyy")
                
                self.userName.text = (user.profile.name  ?? "Username" ) + ",\(age!)"
            }
            self.eventDescription.text = user.profile.bio ?? "User Bio"
        }else {
            

            self.alert(message: "No result found. Try again later.", okAction: {
                if let nav = self.navigationController {
                    nav.popToRootViewController(animated: true)
                }

            })
        }
    }
}
