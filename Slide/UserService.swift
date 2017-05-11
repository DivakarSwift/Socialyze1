//
//  FireBaseUserService.swift
//  Slide
//
//  Created by bibek timalsina on 4/15/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import Foundation
import FirebaseDatabase
import SwiftyJSON

class UserService: FirebaseManager {
    
    func saveUser(user: User, completion: @escaping CallBackWithSuccessError) {
        let userDict = user.toJSON()
        
        reference.child(Node.user.rawValue).child(user.id!).updateChildValues(userDict) { (error, _) in
            completion(error == nil, error)
        }
    }
    
    func getMe(withId userId: String, completion: @escaping (User?, FirebaseManagerError?) -> Void) {
        reference.child(Node.user.rawValue).child(userId).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            let json = JSON(snapshot.value ?? [])
            if let user: User = json.map() {
                completion(user, nil)
            }else {
                completion(nil, FirebaseManagerError.noUserFound)
            }
        })
    }
    
    func getUser(withId userId: String, completion: @escaping (User?, FirebaseManagerError?) -> Void) {
        reference.child(Node.user.rawValue).child(userId).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            let json = JSON(snapshot.value ?? [])
            if let user: User = json.map() {
                completion(user, nil)
            }else {
                completion(nil, FirebaseManagerError.noUserFound)
            }
        })
    }
    
    func getAllUser(completion: @escaping ([User]) -> Void) {
        reference.child(Node.user.rawValue).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            let json = JSON(snapshot)
            if let users: [User] = json.map() {
                completion(users)
            }
        })
    }
    
    func getMatchListUsers(of user: User, completion: @escaping ([User]?, FirebaseManagerError?) -> ()) {
        reference.child(Node.user.rawValue).child(user.id!).child(Node.acceptList.rawValue).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value {
                print(value)
                let acceptList = JSON(value)
                var users:[User] = []
                for (key,data) in acceptList {
                    if data["match"].boolValue {
                        self.getUser(withId: key, completion: { (user, error) in
                            if error == nil {
                                if let user = user {
                                    users.append(user)
                                    completion(users,nil)
                                }
                            } else {
                                completion(nil, error)
                                return
                            }
                        })
                    } else {
                        completion(users,nil)
                    }
                }
            }
            else {
                completion(nil, FirebaseManagerError.noDataFound)
            }
        })
    }
    
    func getChatListAndObserve(of user: User, completion: @escaping ([ChatItem]?, FirebaseManagerError?) -> ()) {
        reference.child(Node.user.rawValue).child(user.id!).child(Node.chatList.rawValue).observe(.value, with: { (snapshot) in
            if let value = snapshot.value {
                print(value)
                let chatList = JSON(value)
                var chatItems:[ChatItem] = []
                for (_,data) in chatList {
                    if let chatItem: ChatItem = data.map() {
                        chatItems.append(chatItem)
                    } else {
                        completion(nil, FirebaseManagerError.noDataFound)
                    }
                }
                completion(chatItems, nil)
            }
            else {
                completion(nil, FirebaseManagerError.noDataFound)
            }
        })
    }
    
    func accept(user: User, myId: String, completion: @escaping(_ success: Bool, _ isMatching: Bool) -> Void) {
        // reference.child(FireBaseNodes.ConnectionsPending.rawValue).queryOrderedByChild(requestType.rawValue).queryEqualToValue(ofUid)
        
        print("OpponentId: \(user.id!)")
        print("MyId: \(myId)")
        reference.child(Node.user.rawValue).child(user.id!).child(Node.acceptList.rawValue).child(myId).observeSingleEvent(of: .value, with: {(snapshot) in
            
            var isMatching = false
            var match = false
            if let val = snapshot.value {
                let json = JSON(val)
                if let matchValue = json["match"].bool {
                    print(matchValue)
                    match = true
                }
                let time = json["time"].doubleValue
                let timeValid = (Date().timeIntervalSince1970 - time) < checkInThreshold
                isMatching = match && timeValid
            }
            
            let value = [
                "match": match,
                "time": Date().timeIntervalSince1970
                ] as [String : Any]
            
            
            
            self.reference.child(Node.user.rawValue).child(myId).child(Node.acceptList.rawValue).child(user.id!).updateChildValues(value) { (error, _) in
                
                self.reference.child(Node.user.rawValue).child(myId).child(Node.matchList.rawValue).child(user.id!).updateChildValues(["time" : Date().timeIntervalSince1970], withCompletionBlock: { (_, _) in
                    
                })
                self.reference.child(Node.user.rawValue).child(user.id!).child(Node.matchList.rawValue).child(myId).updateChildValues(["time" : Date().timeIntervalSince1970], withCompletionBlock: { (_, _) in
                    
                })
                
                if match {
                    let value = [
                        "match": match
                        ] as [String : Any]
                    self.reference.child(Node.user.rawValue).child(user.id!).child(Node.matchList.rawValue).child(myId).updateChildValues(["time" : Date().timeIntervalSince1970], withCompletionBlock: { (_, _) in
                        
                    })
                    self.reference.child(Node.user.rawValue).child(user.id!).child(Node.acceptList.rawValue).child(myId).updateChildValues(value) { (error, _) in
                        completion(error == nil, isMatching)
                    }
                } else {
                    completion(error == nil, isMatching)
                }
                
            }
        })
    }
    
    func getReportedAndBlockedUsers(completion: @escaping ([User]) -> Void) {
        
    }
    
    func block(user: User, completion: @escaping CallBackWithSuccessError) {
        reference.child(Node.user.rawValue).child(user.id!).updateChildValues(["blockedByUsers" : Authenticator.currentFIRUser!.uid]) { (error, _) in
            if let error = error {
                completion(false, error)
            }else {
                self.reference.child(Node.user.rawValue).child(Authenticator.currentFIRUser!.uid).updateChildValues(["blockedUsers" : user.id!], withCompletionBlock: { (error, _) in
                    completion(error == nil, error)
                })
            }
        }
    }
    
    func blockAndReport(user: User, remark: String, completion: @escaping CallBackWithSuccessError) {
        self.block(user: user) { (success, error) in
            if success {
                self.report(user: user, remark: remark, completion: completion)
            }else {
                completion(false, error)
            }
        }
    }
    
    func report(user: User, remark: String, completion: @escaping CallBackWithSuccessError) {
        let dict = [
            "reportedBy": Authenticator.currentFIRUser!.uid,
            "remarks": remark,
            "reportedOn": user.id!
        ]
        
        reference.child(Node.report.rawValue).childByAutoId().updateChildValues(dict) { (error, _) in
            completion(error == nil, error)
        }
    }
}
