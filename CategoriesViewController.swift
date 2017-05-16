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
            
            let maxLength = 200 //char length
            if let orgText = users.first?.profile.bio {
                if orgText.characters.count > maxLength {
                    let range =  orgText.rangeOfComposedCharacterSequences(for: orgText.startIndex..<orgText.index(orgText.startIndex, offsetBy: maxLength))
                    let tmpValue = orgText.substring(with: range).appending("...")
                    self.bioLabel.text = tmpValue
                }
            }
            
            if oldValue.count == 0 && users.count == 1 {
                self.activityIndicator.stopAnimating()
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
    var place:Place?
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
    var fromFBFriends:User?
    
    @IBOutlet weak var actionImageView: UIImageView!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var userName: UILabel!
        
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.infoButton.rounded()
        self.infoButton.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        
        addLoadingIndicator()
        
        imageView.isUserInteractionEnabled = true
        
        actionImageView.isHidden = true
        
        self.addTapGesture(toView: self.imageView)
        
        self.activityIndicator.startAnimating()
        if let friend = self.fromFBFriends {
            self.users = []
            self.users.append(friend)
        } else {
            self.getAllCheckedInUsers()
            self.addSwipeGesture(toView: self.imageView)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let  friend = self.fromFBFriends {
           self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.navigationItem.title  = friend.profile.firstName
        } else {
            self.navigationController?.navigationBar.isHidden = true
        }
    }
    
    
    // MARK: - Gestures Action
    
    func addSwipeGesture(toView view: UIView) {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.wasDragged(gestureRecognizer:)))
        view.addGestureRecognizer(gesture)
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
            
            self.activityIndicator.startAnimating()
            self.imageView.kf.setImage(with: imageURL, placeholder: nil, options: [.transition(.fade(0.2))], progressBlock: { receivedSize, totalSize in
                let percentage = (Float(receivedSize) / Float(totalSize)) * 100.0
                print("downloading progress: \(percentage)%")
                if percentage == 100.0 {
                    self.activityIndicator.isAnimating = false
                    self.activityIndicator.stopAnimating()
                }
            },completionHandler: { _ in
                self.activityIndicator.isAnimating = false
                self.activityIndicator.stopAnimating()
            })
        }
        
        if currentImageIndex == images.count - 1 {
            currentImageIndex = 0
        }else {
            currentImageIndex += 1
        }
    }
    
    // MARK: - User Actions
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
        
        if let _ =  self.fromFBFriends {} else {
            
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
                self.bioLabel.isHidden = true
            }else if label.center.x > self.view.bounds.width - 150 {
                actionImageView.image = #imageLiteral(resourceName: "checkmark")
                actionImageView.isHidden = false
                self.bioLabel.isHidden = true
            }else {
                actionImageView.isHidden = true
                self.bioLabel.isHidden = false
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
        
    }
    
    func removeTopUser() -> User? {
        let rejectedUser = self.users.first
        self.users = Array(users.dropFirst())
        self.changeUser()
        return rejectedUser
    }
    
    func rejectUser() {
        if let rejectedUser = self.users.first, let myId = Authenticator.shared.user?.id {
            self.userService.reject(user: rejectedUser, myId: myId, completion: { [weak self] _ in
                _ = self?.removeTopUser()
            })
        }
    }
    
    func acceptUser() {
        if let acceptedUser = self.users.first, let myId = Authenticator.shared.user?.id {
            self.userService.accept(user: acceptedUser, myId: myId, completion: { [weak self] (success, isMatching) in
                
                if isMatching {
                    self?.showMatchedPopover(opponent: acceptedUser, myId: myId)
                } else {
                    _ = self?.removeTopUser()
                }
                return
            })
        }
    }
    
    func addLoadingIndicator () {
        self.view.addSubview(activityIndicator)
        self.view.bringSubview(toFront: activityIndicator)
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
            acknowledgedCount += 1
        }
    }
    
    func changeUser() {
        self.bioLabel.isHidden = false
        if let user = users.first {
            self.imageView.kf.setImage(with: user.profile.images.first)
            //            self.imageView.kf.setImage(with: user.profile.images.first)
            self.userName.text = user.profile.firstName ?? "Username"
            if let dob = user.profile.dateOfBirth {
                let age = Utilities.returnAge(ofValue: dob, format: "MM/dd/yyyy")
                
                self.userName.text = (user.profile.firstName  ?? "Username" ) + ", \(age!)"
            }
            self.bioLabel.text = user.profile.bio
        } else {
            if let name = self.place?.mainImage, name == #imageLiteral(resourceName: "Union") {
                self.alert(message: "No result found. Try again later.", okAction: {
                    if let nav = self.navigationController {
                        nav.popToRootViewController(animated: true)
                    }
                })     
            } else if let nav = self.navigationController {
                    nav.popToRootViewController(animated: true)
            }
        }
    }
    
    private func showMatchedPopover(opponent user: User, myId: String) {
        
        let popoverVC = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "MatchedViewController") as! MatchedViewController
        
        popoverVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        let popoverController = popoverVC.popoverPresentationController
        
        popoverController?.delegate = self
        popoverController?.sourceView = self.view
        popoverController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY,width: 0, height: 0)
        
        popoverController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        popoverVC.friend = user
        
        popoverVC.backToCheckIn = { chatItem in
            if let item = chatItem {
                let vc = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                vc.chatItem = item
                vc.chatUserName = user.profile.firstName!
                vc.chatOppentId = user.id
                vc.chatUser = user
                if let nav =  self.navigationController {
                    nav.pushViewController(vc, animated: true)
                } else {
                    self.present(vc, animated: true, completion: nil)
                }
            }
            else {
                self.rejectUser()
            }
        }
        self.present(popoverVC,animated: true,completion: nil)
    }
}


extension CategoriesViewController: UIPopoverControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        self.view.alpha = 1.0
    }
}

