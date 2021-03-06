//
//  EventAPIExtension.swift
//  Slide
//
//  Created by Rajendra on 6/30/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import Foundation
import Alamofire

extension EventDetailViewController {
    
    // MARK: - API Calls
    func checkIn(completion: ((Bool)->())? = nil) {
        
        if self.isCheckedIn {
            completion?(true)
            return
        }
        
        guard self.place?.nameAddress != nil, self.checkInButton.isEnabled, !self.isCheckedIn else {return}
        
        let fbIds = self.faceBookFriends.map({$0.id}) // + ["101281293814104"];
        let params = [
            "sound": "default",
            "place": self.place!.nameAddress!,
            "placeId": self.place!.nameAddress!.replacingOccurrences(of: " ", with: ""),
            "fbId": authenticator.user?.profile.fbId ?? "",
            "time": Date().timeIntervalSince1970,
            "userId": authenticator.user?.id ?? "",
            "notificationTitle": "\(authenticator.user?.profile.firstName ?? "") is @ \(self.place?.nameAddress ?? "")",
            "notificationBody": "Meet your friend in the next 3 hours to use your deal @ \(self.place?.nameAddress ?? "").",
            "friendsFbId": fbIds,
            "type": "checkIn"
            ] as [String : Any]
        
        self.checkInButton.isEnabled = false
        
        if completion == nil { // if nil then it is from checkin not use deal
            self.activityIndicator.startAnimating()
        }
        
        Alamofire.request(GlobalConstants.urls.baseUrl + "checkIn", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { [weak self](data) in
            self?.checkInButton.isEnabled = true
            if completion == nil { // if nil then it is from checkin not use deal
                self?.activityIndicator.stopAnimating()
            }
            if data.response?.statusCode == 200 {
                self?.isCheckedIn = true
                self?.eventAction = .checkInSwipe
                self?.locationPinButton.setImage(#imageLiteral(resourceName: "checkinbutton32x32"), for: .normal)
                self?.placeDistanceLabel.isHidden = true
                if let me = self {
                    SlydeLocationManager.shared.stopUpdatingLocation()
                    Timer.scheduledTimer(timeInterval: checkInThreshold, target: me, selector: #selector(me.recheckin), userInfo: nil, repeats: false)
                }
                completion?(true)
                self?.getCheckedinUsers()
            }else {
                completion?(false)
                self?.isCheckedIn = false
                self?.alert(message: "Something went wrong. Try again!")
            }
        }
    }
    
    func useDealApiCall(deal: Deal) {
        let fbIds = self.faceBookFriends.map({$0.id})
        
        let params = [
            "sound": "default",
            "place": self.place!.nameAddress!,
            "placeId": self.place!.nameAddress!.replacingOccurrences(of: " ", with: ""),
            "fbId": self.authenticator.user?.profile.fbId ?? "",
            "time": Date().timeIntervalSince1970,
            "userId": self.authenticator.user?.id ?? "",
            "notificationTitle": "\(self.authenticator.user?.profile.firstName ?? "") used the deal @ \(self.place?.nameAddress ?? "")",
            "notificationBody": "Sweet! Your deal is unlocked for the next 3 hours @ \(self.place?.nameAddress ?? "").",
            "friendsFbId": fbIds,
            "dealUid": deal.uid ?? "--1",
            "type": "usedDeal"
            ] as [String : Any]
        
        Alamofire.request(GlobalConstants.urls.baseUrl + "useDeal", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { [weak self](data) in
            self?.activityIndicator.stopAnimating()
            self?.useDealApiCalling = false
            if data.response?.statusCode == 200 {
                // self?.useDealButton.isHidden = true
                // self?.getDeals()
                
                self?.lastDealUsedDate = Date()
                self?.userCanUseDealForToday = false
                
            }else {
                self?.alert(message: "Something went wrong. Try again!")
            }
        }
    }
    
    func going() {
        guard self.place?.nameAddress != nil else {return}
        
        let fbIds = self.faceBookFriends.map({$0.id}) // + ["101281293814104"];
        let params = [
            "sound": "default",
            "place": self.place!.nameAddress!,
            "placeId": self.place!.nameAddress!.replacingOccurrences(of: " ", with: ""),
            "fbId": authenticator.user?.profile.fbId ?? "",
            "time": Date().timeIntervalSince1970,
            "userId": authenticator.user?.id ?? "",
            "notificationTitle": "\(authenticator.user?.profile.firstName ?? "") is going to \(self.place?.nameAddress ?? "")",
            "notificationBody": "Meet your friend to unlock exclusive deals @ \(self.place?.nameAddress ?? "").",
            "friendsFbId": fbIds,
            "eventUid": self.place?.event?.uid ?? "--1",
            "type": "going"
            ] as [String : Any]
        
        self.checkInButton.isEnabled = false
        
        self.activityIndicator.startAnimating()
        Alamofire.request(GlobalConstants.urls.baseUrl + "iAmGoing", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { [weak self](data) in
            self?.activityIndicator.stopAnimating()
            self?.checkInButton.isEnabled = true
            
            if data.response?.statusCode == 200 {
                self?.isGoing = true
                self?.eventAction = .goingSwipe
                self?.getGoingUsers()
            }else {
                self?.alert(message: "Something went wrong. Try again!")
            }
        }
        
        
        //        self.placeService.user(authenticator.user!, goingAt: self.place!) { [weak self] (success, error) in
        //            success ?
        //                onSuccess() :
        //                self?.alert(message: error?.localizedDescription)
        //
        //            print(error ?? "GOING")
        //        }
    }
    
    func getUserFriends() {
        facebookService.getUserFriends(success: {[weak self] (friends: [FacebookFriend]) in
            self?.faceBookFriends = friends
            }, failure: { (error) in
                //                self?.alert(message: error)
                print(error)
        })
    }
    
    func getCheckedInFriends() -> [FacebookFriend] {
        let fbIds = self.checkinWithExpectUser.flatMap({$0.fbId})
        let friendCheckins = self.faceBookFriends.filter({fbIds.contains($0.id)})
        return friendCheckins
    }
    
    func getCheckedinUsers() {
        self.activityIndicator.startAnimating()
        if let authUserId = self.authenticator.user?.id {
            UserService().expectUserIdsOfacceptList(userId: authUserId, completion: { [weak self] (userIds) in
                self?.exceptedUsers = userIds
                self?.placeService.getCheckInUsers(at: (self?.place)!, completion: {[weak self] (checkins) in
                    self?.activityIndicator.stopAnimating()
                    
                    self?.checkinWithExpectUser = checkins.filter({(checkin) -> Bool in
                        if let checkInUserId = checkin.userId, let authUserId = self?.authenticator.user?.id, let checkinTime = checkin.time {
                            let isMe = checkInUserId == authUserId
                            let checkTimeValid = (Date().timeIntervalSince1970 - checkinTime) < checkInThreshold
                            
                            if isMe && checkTimeValid {
                                self?.isCheckedIn = true
                            }
                            
                            return checkTimeValid//!isMe && checkTimeValid
                        }
                        return false
                    })
                    }, failure: {[weak self] error in
                        self?.activityIndicator.stopAnimating()
                })
                
            })
        }
    }
    
    func getGoingUsers() {
        self.activityIndicator.startAnimating()
        if let authUserId = self.authenticator.user?.id {
            UserService().expectUserIdsOfacceptList(userId: authUserId, completion: { [weak self] (userIds) in
                self?.exceptedUsers = userIds
                self?.placeService.getGoingUsers(at: (self?.place)!, completion: {[weak self] (checkins) in
                    
                    self?.goingWithExpectUser = checkins.filter({(checkin) -> Bool in
                        
                       // var val:Bool = true
                        if let checkInUserId = checkin.userId, let myId = Authenticator.shared.user?.id {
                            
                            let me = checkInUserId == myId
                            if me {
                                self?.isGoing = me
                                self?.changeGoingStatus()
                            }
                            // val = !me
                        }
                        return true //val
                    })
                    
                    self?.activityIndicator.stopAnimating()
                    self?.getCheckedinUsers()
                    
                    }, failure: {[weak self] error in
                        self?.activityIndicator.stopAnimating()
                        self?.getCheckedinUsers()
                })
            })
        }
    }
    
    func getAllGoingUsers() {
        
        var data:[Checkin] = [Checkin]()
        data = self.goingWithExpectUser
        
        let dataIds = data.map {
            $0.userId!
        }
        
        _ = self.checkinData.map { (val) -> Checkin in
            var value = val
            if dataIds.contains(value.userId!) {
                
            } else {
                data.append(value)
            }
            return value
        }
        
        self.activityIndicator.startAnimating()
        var acknowledgedCount = 0 {
            didSet {
                if acknowledgedCount == data.count {
                    self.activityIndicator.stopAnimating()
                }
            }
        }
        acknowledgedCount = 0
        
        let userIdsSet = Set(data.flatMap({$0.userId}))
        userIdsSet.forEach { (userId) in
            
            self.userService.getUser(withId: userId, completion: { [weak self] (userData, error) in
                
                acknowledgedCount += 1
                if let _ = error {
                    //                    self?.alert(message: error.localizedDescription)
                    return
                }
                
                if var user = userData {
                    // For checkedin
                    var dataIds = self?.checkinData.map {
                        $0.userId!
                    }
                    if let id = user.id, dataIds?.contains(id) ?? false {
                        user.isCheckedIn = true
                    }
                    
                    // For checkedin
                    dataIds = self?.goingWithExpectUser.map {
                        $0.userId!
                    }
                    if let id = user.id, dataIds?.contains(id) ?? false {
                        user.isGoing = true
                    }
                    
                    if let index = self?.eventUsers.index(of: user) {
                        self?.eventUsers[index] = user
                    }else {
                        self?.eventUsers.append(user)
                    }
                    // self?.friendsCollectionView.reloadData()
                }
            })
        }
    }
    
}
