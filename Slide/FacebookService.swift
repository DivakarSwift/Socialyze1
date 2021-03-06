//
//  FacebookService.swift
//  Slide
//
//  Created by bibek timalsina on 4/15/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import Foundation
import FacebookCore
import SwiftyJSON
import ObjectMapper

class FacebookService {
    private init() {
        
    }
    
    static let shared = FacebookService()
    
    private var images:[String] = []
    private var hasImageCount = -1
    private var user:LocalUser?
    private var friends = [FacebookFriend]()
    
    func logout() {
        images = []
        hasImageCount = -1
        friends = []
    }
    
    func isPhotoPermissionGiven() -> Bool {
        if let userPhotosPermission: Bool = GlobalConstants.UserDefaultKey.userPhotosPermissionStatusFromFacebook.value(), userPhotosPermission == true {
            return true
        }else {
            return false
        }
    }
    
    func getAccessToken() -> AccessToken? {
        guard let fbtoken:[String:Any] = GlobalConstants.UserDefaultKey.fbAccessToken.value() else {
            return nil
        }
        let json = JSON(fbtoken)
        guard let token:FacebookAccessToken = json.map() else {
            return nil
        }
        var expiryDate:Date = Date()
        var refreshDate:Date = Date()
        if let date = token.expirationDate {
           expiryDate = Utilities.returnDate(ofValue: date)!
        }
        if let date = token.refreshDate {
            refreshDate = Utilities.returnDate(ofValue: date)!
        }
        
        let accesstoken = AccessToken(appId: token.appId!, authenticationToken: token.authenticationToken!, userId: token.userId, refreshDate: refreshDate, expirationDate: expiryDate)
        
        AccessToken.current = accesstoken
        return AccessToken.current
    }
    
    func isUserFriendsPermissionGiven() -> Bool {
        if let userFriendsPermission: Bool = GlobalConstants.UserDefaultKey.userFriendsPermissionStatusFromFacebook.value(), userFriendsPermission == true {
            return true
        } else {
            return false
        }
    }
    
    func isUserDOBPermissionGiven() -> Bool {
        if let userDOBPermission: Bool = GlobalConstants.UserDefaultKey.userDOBPermissionStatusFromFacebook.value(), userDOBPermission == true {
            return true
        }else {
            return false
        }
    }
    
    func getUserDetails(success: @escaping (LocalUser) -> (), failure: @escaping (GlobalConstants.Message)->()) {
        self.getUserDetails(nextPageCursor: nil, complete: {
            success(self.user!)
        }) { (error) in
            failure(error)
        }
    }
    
    private func getUserDetails(nextPageCursor: String?, complete: @escaping ()->(), failure: @escaping (GlobalConstants.Message)->()) {
        let param = ["fields": "id, first_name, last_name, name, email, picture, gender, birthday"]
        let path = "me"
        
        self.createGraphRequestAndStart(forPath: path, params: param, httpMethod: .GET, success: { (response) in
            
            print(response.dictionaryValue ?? [:])
            guard let responseDict = response.dictionaryValue else {
                return
            }
            let json = JSON(responseDict)
            print(json)
            if let id = json["id"].string, let firstName = json["first_name"].string, let lastName = json["last_name"].string {
                
                var user = LocalUser()
                user.profile.fbId = id
                user.profile.firstName = firstName
                user.profile.lastName = lastName
                user.profile.name = firstName + " " + lastName
                if let dob = json["birthday"].string {
                user.profile.dateOfBirth = dob
                }
                
                if let pic = json["picture", "data", "url"].string {
                    user.profile.images.append(URL(string: pic)!)
                }
                self.user = user
                complete()
            }
        }, failure: { (error) in
            print(error)
            
        })
    }
    
    private func createGraphRequestAndStart(forPath path: String, params: [String : Any] = [:], httpMethod: GraphRequestHTTPMethod = .GET, success: @escaping (GraphResponse) -> (), failure: @escaping (GlobalConstants.Message)->()) {
        var accesstoken = AccessToken.current
        if let _ = AccessToken.current?.authenticationToken {
            print("Facebook Access-token available")
        } else {
             accesstoken = self.getAccessToken()
        }
        
        let graphRequest = GraphRequest.init(graphPath: path, parameters: params, accessToken: accesstoken, httpMethod: .GET, apiVersion: .defaultVersion)
        graphRequest.start { (response, result) in
            switch result {
            case .failed(let error):
                failure(GlobalConstants.Message.oops)
                print(error)
            case .success(response: let response):
                success(response)
            }
        }
    }
    
    func getUserFriends(success: @escaping ([FacebookFriend]) -> (), failure: @escaping (GlobalConstants.Message)->()) {
        self.getUserFriends(nextPageCursor: nil, complete: { 
            success(self.friends)
        }) { (error) in
            failure(error)
            success(self.friends)
        }
    }
    
    private func getUserFriends(nextPageCursor: String?, complete: @escaping ()->(), failure: @escaping (GlobalConstants.Message)->()) {
        var params = ["fields": "id, first_name, last_name, name, picture, birthday", "limit" : 200] as [String : Any]
        if let nextPageCursor = nextPageCursor {
            params["after"] = nextPageCursor
        }
        
        self.createGraphRequestAndStart(forPath: "/me/friends",  params: params, success: { (response) in
            print(response.dictionaryValue ?? [:])
            guard let responseDict = response.dictionaryValue else {
                return
            }
            let json = JSON(responseDict)
            json["data"].arrayValue.forEach({
                if let id = $0["id"].string, let name = $0["name"].string, let firstName = $0["first_name"].string, let profileImageURL = $0["picture","data", "url"].string {
                    var friend = FacebookFriend(id: id, firstName: firstName, name: name, profileURLString: profileImageURL, dataOfBirth: nil)
                    if let dob = $0["birthday"].string {
                        friend.dataOfBirth = dob
                    }
                    if !self.friends.contains(friend) {
                        self.friends.append(friend)
                    }
                }
            })
            if let nextPageCursor = json["paging","cursors", "after"].string {
                self.getUserFriends(nextPageCursor: nextPageCursor, complete: complete, failure: failure)
            }else {
                complete()
            }
        }, failure: failure)
    }
    
    
    func loadUserProfilePhotos(value: @escaping (String) -> (), completion: @escaping ([String]) -> (), failure: @escaping (GlobalConstants.Message)->()) {
        
        let accesstoken = AccessToken.current
        if let fbUserId: String = accesstoken?.userId {
            // GET ALBUMS
            self.createGraphRequestAndStart(forPath: "/\(fbUserId)/albums", success: { [weak self] (response) in
                guard let responseDict = response.dictionaryValue else {
                    return
                }
                let profileAlbumId = JSON(responseDict)["data"].arrayValue.reduce("") { (collection, json) -> String in
                    if collection.isEmpty && json["name"].stringValue == "Profile Pictures" {
                        return json["id"].stringValue
                    }
                    return collection
                }
                // GET PHOTOS OF ALBUM
                self?.createGraphRequestAndStart(forPath: "/\(profileAlbumId)/photos", success: {[weak self] (response) in
                    guard let responseDict = response.dictionaryValue else {
                        return
                    }
                    let photosIds = JSON(responseDict)["data"].arrayValue.map({
                        return $0["id"].stringValue
                    })
                    let photoCount = photosIds.count
                    
                    if photoCount == 0 {
                        failure(GlobalConstants.Message(title: "Error", message: "Please upload/change profile picture in facebook.", okTitle: "Ok", cancelTitle: nil, okAction: nil, cancelAction: nil))
                        return
                    }
                    
                    self?.hasImageCount = photoCount
                    var firstFive = [String]()
                    for i in 0...min(4, photoCount - 1) {
                        firstFive.append(photosIds[i])
                    }
                    print(firstFive)
                    
                    self?.getImage(photoIds: firstFive, index: 0, completion: { _ in
                        if let images = self?.images {
                            completion(images)
                        }
                    }, failure: failure)
                    
//                    if let me = self {
//                        
//                        firstFive.enumerated().forEach({ (index, photoId) in
//                            // GET PHOTO FROM ID
//                            me.createGraphRequestAndStart(forPath: "/\(photoId)", params: ["fields": "images"], success: { (response) in
//                                //                                print(response)
//                                guard let responseDict = response.dictionaryValue else {
//                                    return
//                                }
//                                let imageJsons = JSON(responseDict)["images"].arrayValue
//                                if imageJsons.count == 0 {
//                                    failure(GlobalConstants.Message.oops)
//                                    return
//                                }
//                                let imagereducedJsons = JSON(responseDict)["images"].arrayValue.reduce(imageJsons[0], { (result, json) -> JSON in
//                                    let jsonHeight = json["height"].intValue
//                                    let resultHeight = result["height"].intValue
//                                    if jsonHeight > resultHeight {
//                                        return json
//                                    }
//                                    return result
//                                })
//                                print()
//                                if let imageURLString = imagereducedJsons["source"].string {
//                                    print("\(index). \(imageURLString)")
//                                    if !me.images.contains(imageURLString) {
//                                        value(imageURLString)
//                                        me.images.append(imageURLString)
//                                    }
//                                }
//                                else {
//                                    print("\(index). \(imagereducedJsons)")
//                                }
//                                if firstFive.count - 1 == index {
//                                    print(index)
//                                    completion()
//                                }
//                            }, failure: failure)
//                        })
//                    }
                    
                    }, failure: failure)
                
                }, failure: failure)
        }
    }
    
    func getImage(photoIds: [String], index : Int, completion: @escaping () -> (), failure: @escaping (GlobalConstants.Message)->()) {
        if index < photoIds.count {
            let photoId = photoIds[index]
            self.createGraphRequestAndStart(forPath: "/\(photoId)", params: ["fields": "images"], success: { (response) in
                
                guard let responseDict = response.dictionaryValue else {
                    return
                }
                let imageJsons = JSON(responseDict)["images"].arrayValue
                if imageJsons.count == 0 {
                    failure(GlobalConstants.Message.oops)
                    return
                }
                let imagereducedJsons = JSON(responseDict)["images"].arrayValue.reduce(imageJsons[0], { (result, json) -> JSON in
                    let jsonHeight = json["height"].intValue
                    let resultHeight = result["height"].intValue
                    if jsonHeight > resultHeight {
                        return json
                    }
                    return result
                })
                
                if let imageURLString = imagereducedJsons["source"].string {
                    print("\(index). \(imageURLString)")
                    if !self.images.contains(imageURLString) {
                        self.images.append(imageURLString)
                        self.getImage(photoIds: photoIds, index: index+1, completion: completion, failure: failure)
                    }
                }
            }, failure: { _ in
                
            })
        } else {
            completion()
        }
    }
}
