//
//  ProfileViewController.swift
//  Slide
//
//  Created by Salem Khan on 3/8/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit
import Kingfisher
import FacebookCore
import SwiftyJSON

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var lblUserName: UILabel!
    
    var userId: String?
    let authenticator = Authenticator.shared
    let facebookService = FacebookService.shared
    let userService = UserService()
    
    var images = [String]() {
        didSet {
            if images.count == 1 {
                changeImage()
            } else if images.count == 2 {
//                startTimer()
            }
        }
    }
    
    var currentImageIndex = 0
    
    var imageTimer: Timer?
    
    private var user: User? {
        didSet {
            self.editButton.isHidden = false
            self.bioLabel.isHidden = false
            self.bioLabel.text = user?.profile.bio
            self.userImageView.kf.setImage(with: user?.profile.images.first)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.editButton.isHidden = true
        self.bioLabel.isHidden = true
        
        if let userId = userId {
            userService.getMe(withId: userId, completion: {[weak self] (user, error) in
                if let error = error {
                    self?.alert(message: error.localizedDescription, okAction: {
                        _ = self?.navigationController?.popViewController(animated: true)
                        self?.dismiss(animated: true, completion: nil)
                    })
                }else {
                    self?.user = user
                    if self?.facebookService.isPhotoPermissionGiven() ?? false {
                        self?.loadProfilePicturesFromFacebook()
                    }else {
                        self?.authenticator.delegate = self
                        self?.authenticator.authenticateWith(provider: .facebook)
                    }
                }
            })
        }
        
        self.adddTapGesture(toView: self.userImageView)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if self.images.count > 1 {
//            currentImageIndex = 0
//            changeImage()
//            self.startTimer()
//        }
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopTimer()
    }
    
    func adddTapGesture(toView view: UIView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
    }
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        self.changeImage()
    }
    
    func changeImage() {
        if currentImageIndex < images.count && currentImageIndex >= 0 {
            let imageURLString = images[currentImageIndex]
            if let url = URL(string: imageURLString) {
                self.userImageView.kf.setImage(with: url, placeholder: self.userImageView.image)
            }
        }
        if currentImageIndex == images.count - 1 {
            currentImageIndex = 0
        }else {
            currentImageIndex += 1
        }
    }
    
    func loadProfilePicturesFromFacebook() {
        facebookService.loadUserProfilePhotos(value: { [weak self] (photoUrlString) in
            self?.images.append(photoUrlString)
            }, completion: { [weak self] in
                if let me = self, let _ = me.user {
                    me.user?.profile.images = me.images.flatMap({URL(string: $0)})
                    me.userService.saveUser(user: me.user!, completion: {[weak self] (success, error) in
                        if let error = error {
                            self?.alert(message: error.localizedDescription)
                        }
                    })
                }
        }) {[weak self] (error) in
            self?.alert(message: error)
        }
    }
    
    func startTimer() {
        self.imageTimer?.invalidate()
        self.imageTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        self.imageTimer?.invalidate()
        self.imageTimer = nil
    }
    

    
    @IBAction func editProfile(_ sender: Any) {
    }
    
}

extension ProfileViewController: AuthenticatorDelegate {
    func didOccurAuthentication(error: AuthenticationError) {
        self.alert(message: error.localizedDescription)
    }
    
    func didSignInUser() {
        
    }
    
    func didLogoutUser() {
        
    }
    
    func shouldUserSignInIntoFirebase() -> Bool {
        if facebookService.isPhotoPermissionGiven() {
            self.loadProfilePicturesFromFacebook()
        }else {
            self.alert(message: "Facebook user photos permission is not granted.", okAction: {
                self.dismiss(animated: true, completion: nil)
            })
        }
        return false
    }
}
