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
    
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var lblUserName: UILabel!
    
    @IBAction func didSwipe(_ sender: UISwipeGestureRecognizer) {
        performSegue(withIdentifier: "matches", sender: nil)
    }
    
    var userId: String?
    let authenticator = Authenticator.shared
    let facebookService = FacebookService.shared
    let userService = UserService()
    
    var images = [URL]()
    
    var currentImageIndex = 0
    
    var imageTimer: Timer?
    
    fileprivate var user: LocalUser? {
        didSet {
            self.editButton.isHidden = false
            self.updateBio()
            if let dob = user?.profile.dateOfBirth {
                let age = Utilities.returnAge(ofValue: dob, format: "MM/dd/yyyy")
                self.lblUserName.text = (user?.profile.firstName  ?? "Username" ) + ", \(age!)"
            }
            
            if let images = self.user?.profile.images {
                self.userImageView.kf.indicatorType = .activity
                let p = Bundle.main.path(forResource: "indicator_149", ofType: "gif")!
                let data = try! Data(contentsOf: URL(fileURLWithPath: p))
                self.userImageView.kf.indicatorType = .image(imageData: data)
                self.userImageView.kf.setImage(with: images.first, placeholder: nil)
                self.images = images
            }
        }
    }
    
    lazy fileprivate var activityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: "ladybird.png")!
        return CustomActivityIndicatorView(image: image)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.editButton.isHidden = true
        self.hideKeyboardWhenTappedAround()
        self.navigationItem.setHidesBackButton(true, animated: true)
        lblUserName.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        lblUserName.layer.shadowRadius = 3
        lblUserName.layer.shadowOpacity = 1
//        self.user = Authenticator.shared.user
        
        self.adddTapGesture(toView: self.userImageView)
        
        view.addSubview(activityIndicator)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.user = Authenticator.shared.user
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        //self.navigationController?.navigationBar.isHidden = true
//        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isStatusBarHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        //self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func matchTouched(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Matches", bundle: nil).instantiateViewController(withIdentifier: "MatchesViewController") as! MatchesViewController
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }
    
    @IBAction func goToHome(_ sender: Any) {
        NotificationCenter.default.post(name: GlobalConstants.Notification.changePage.notification, object: 1)
    }
    
    @IBAction func swipeHome(_ sender: Any) {
        performSegue(withIdentifier: "unwindFromProfile", sender: nil)
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
            let url = images[currentImageIndex]
            let p = Bundle.main.path(forResource: "indicator_149", ofType: "gif")!
            let data = try! Data(contentsOf: URL(fileURLWithPath: p))
            self.userImageView.kf.indicatorType = .image(imageData: data)
            self.userImageView.kf.setImage(with: url)
        }
        if currentImageIndex == images.count - 1 {
            currentImageIndex = 0
        }else {
            currentImageIndex += 1
        }
    }
    
    func loadProfilePicturesFromFacebook() {
        facebookService.loadUserProfilePhotos(value: { [weak self] (photoUrlString) in
            if let url = URL(string: photoUrlString) {
                self?.images.append(url)
            }
            }, completion: { [weak self] images in
                if let me = self, let _ = me.user {
                    me.user?.profile.images = images.flatMap({ (image) -> URL? in
                        return URL(string: image)
                    })
                    me.userService.saveUser(user: me.user!, completion: {[weak self] (success, error) in
                        if let error = error {
                            self?.alert(message: error.localizedDescription)
                        }
                    })
                }
        }) {[weak self] (error) in
            
            if let images = self?.user?.profile.images {
                self?.images = []
                for image in images {
                    self?.images.append(image)
                }
            }
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
    
    func updateBio() {
        let maxLength = 200 //char length
        if let orgText = user?.profile.bio {
            if orgText.characters.count > maxLength {
                let range =  orgText.rangeOfComposedCharacterSequences(for: orgText.startIndex..<orgText.index(orgText.startIndex, offsetBy: maxLength))
                let tmpValue = orgText.substring(with: range).appending("...")
                self.bioTextView.text = tmpValue
                self.bioLabel.text = self.bioTextView.text
                //updateBio(bio: tmpValue)
            } else {
                self.bioTextView.text = user?.profile.bio
                self.bioLabel.text = self.bioTextView.text
            }
        }
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

extension ProfileViewController: UITextViewDelegate {
   
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
    }
    
    // For checking whether enter text can be taken or not.
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            self.savebio(textView)
        }
        
        if textView == bioTextView && text != ""{
            let x = (textView.text ?? "").characters.count
            return x <= 199
        }
        
        
        return true
    }
    
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    func savebio(_ sender: UITextView){
        if let id = Authenticator.shared.user?.id {
            FirebaseManager().reference.child("user/\(id)/profile/bio").setValue(sender.text)
            self.user?.profile.bio = sender.text
            Authenticator.shared.user = self.user
        }
    }
    
}
