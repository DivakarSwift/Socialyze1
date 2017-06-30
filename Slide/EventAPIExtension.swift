//
//  EventAPIExtension.swift
//  Slide
//
//  Created by Rajendra on 6/30/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import Foundation

extension EventDetailViewController {
    
    // MARK: - API Calls
    internal func checkIn(onSuccess: @escaping () -> ()) {
        self.placeService.user(authenticator.user!, checkInAt: self.place!, completion: {[weak self] (success, error) in
            success ?
                onSuccess() :
                self?.alert(message: error?.localizedDescription)
            if let me = self {
                me.isCheckedIn = success
                
                if success {
                    SlydeLocationManager.shared.stopUpdatingLocation()
                    Timer.scheduledTimer(timeInterval: 20*60, target: me, selector: #selector(me.recheckin), userInfo: nil, repeats: false)
                }
            }
            
            print(error ?? "CHECKED IN")
        })
    }
    
    internal func goingIn(onSuccess: @escaping () -> ()) {
        
        self.placeService.user(authenticator.user!, goingAt: self.place!) { [weak self] (success, error) in
            success ?
                onSuccess() :
                self?.alert(message: error?.localizedDescription)
            
            print(error ?? "GOING")
        }
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
                        var val:Bool = true
                        if let checkInUserId = checkin.userId, let myId = Authenticator.shared.user?.id {
                            // return true
                            if checkInUserId == myId {
                                //                                self?.isCheckedIn = true
                                //                                self?.changeGoingStatus()
                                val = false
                            } else {
                                val = true
                            }
                        }
                        return val
                    })
                    
                    }, failure: {[weak self] error in
                        self?.activityIndicator.stopAnimating()
                        //                        self?.alert(message: error.localizedDescription)
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
                        
                        var val:Bool = true
                        if let checkInUserId = checkin.userId, let myId = Authenticator.shared.user?.id {
                            // return true
                            if checkInUserId == myId {
                                self?.isGoing = true
                                self?.changeGoingStatus()
                                val = false
                            } else {
                                val = true
                            }
                        }
                        return val
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
                    self?.friendsCollectionView.reloadData()
                }
            })
        }
    }
    
}
