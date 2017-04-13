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
    
    var userId: String?
    let authenticator = Authenticator()
    
    var images = [String]() {
        didSet {
            if images.count == 1 {
                changeImage()
            }else if images.count == 2 {
                startTimer()
            }
        }
    }
    
    var currentImageIndex = 0
    
    var imageTimer: Timer?
    
    private var user: User? {
        didSet {
            self.editButton.isHidden = false
            self.bioLabel.isHidden = false
            self.bioLabel.text = user?.bio
            self.userImageView.kf.setImage(with: user?.images.first)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.editButton.isHidden = true
        self.bioLabel.isHidden = true
        
        if let userId = userId {
            FirebaseManager.shared.getUser(withId: userId, completion: { (user, error) in
                if let error = error {
                    self.alert(message: error.localizedDescription, okAction: {
                        _ = self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
                    })
                }else {
                    self.user = user
                }
            })
        }
        
        if let userPhotosPermission: Bool = GlobalConstants.UserDefaultKey.userPhotosPermissionStatusFromFacebook.value(), userPhotosPermission == true {
            proceedToTakeUserPhotos()
        }else {
            authenticator.delegate = self
            self.authenticator.authenticateWith(provider: .facebook)
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.images.count > 1 {
            currentImageIndex = 0
            changeImage()
            self.startTimer()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopTimer()
    }
    
    func startTimer() {
        self.imageTimer?.invalidate()
        self.imageTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        self.imageTimer?.invalidate()
        self.imageTimer = nil
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
    
    func permissionCheck() -> Bool {
        if let userPhotosPermission: Bool = GlobalConstants.UserDefaultKey.userPhotosPermissionStatusFromFacebook.value(), userPhotosPermission == true {
            return true
        }else {
            return false
        }
    }
    
    @IBAction func editProfile(_ sender: Any) {
    }
    
    func proceedToTakeUserPhotos() {
        let accesstoken = AccessToken.current
        
        if let fbUserId: String = accesstoken?.userId {
            let albumRequest = GraphRequest.init(graphPath: "/\(fbUserId)/albums", parameters: [ : ], accessToken: accesstoken, httpMethod: .GET, apiVersion: .defaultVersion)
            albumRequest.start({ [weak self] (response, result) in
                switch result {
                case .failed(let error):
                    print(error)
                case .success(response: let response):
                    // 103443236448565
                    guard let responseDict = response.dictionaryValue else {
                        return
                    }
                    let profileAlbumId = JSON(responseDict)["data"].arrayValue.reduce("") { (collection, json) -> String in
                        if collection.isEmpty && json["name"].stringValue == "Profile Pictures" {
                            return json["id"].stringValue
                        }
                        return collection
                    }
                    
                    let photosRequest = GraphRequest.init(graphPath: "/\(profileAlbumId)/photos", parameters: [:], accessToken: accesstoken, httpMethod: .GET, apiVersion: .defaultVersion)
                    photosRequest.start({ (response, result) in
                        switch result {
                        case .failed(let error):
                            print(error)
                        case .success(response: let response):
                            guard let responseDict = response.dictionaryValue else {
                                return
                            }
                            let photosIds = JSON(responseDict)["data"].arrayValue.map({
                                return $0["id"].stringValue
                            })
                            
                            let firstFive = photosIds.dropLast(photosIds.count - 5)
                            print(firstFive)
                            
                            firstFive.forEach({ (photoId) in
                                let photoRequest = GraphRequest.init(graphPath: "/\(photoId)", parameters: ["fields": "images"], accessToken: accesstoken, httpMethod: .GET, apiVersion: .defaultVersion)
                                photoRequest.start({ (response, result) in
                                    switch result {
                                    case .failed(let error):
                                        print(error)
                                    case .success(response: let response):
                                        guard let responseDict = response.dictionaryValue else {
                                            return
                                        }
                                        let imageJsons = JSON(responseDict)["images"].arrayValue
                                        if let imageURLString = JSON(responseDict)["images"].arrayValue.reduce(imageJsons[0], { (result, json) -> JSON in
                                            let jsonHeight = json["height"].intValue
                                            let resultHeight = result["height"].intValue
                                            if jsonHeight > resultHeight {
                                                return json
                                            }
                                            return result
                                        })["source"].string {
                                            if !(self?.images.contains(imageURLString) ?? true) {
                                                self?.images.append(imageURLString)
                                            }
                                        }
                                    }
                                })
                            })
                            //                            print(photos)
                        }
                    })
                    // /{album-id}/photos
                    
                }
            })
        }
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
        if !permissionCheck() {
            self.alert(message: "Facebook user photos permission is not granted.", okAction: {
                self.dismiss(animated: true, completion: nil)
            })
        }else {
            proceedToTakeUserPhotos()
        }
        return false
    }
}
