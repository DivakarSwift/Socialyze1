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
            albumRequest.start({ (response, result) in
                switch result {
                case .failed(let error):
                    print(error)
                case .success(response: let response):
                    // 103443236448565
                    let profileAlbumId = JSON(response.dictionaryValue)["data"].arrayValue.reduce("") { (collection, json) -> String in
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
                            let photosIds = JSON(response.dictionaryValue)["data"].arrayValue.map({
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
                                        print(response.arrayValue)
                                        print(response.dictionaryValue)
                                        print(response.stringValue)
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
