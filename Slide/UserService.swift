//
//  FireBaseUserService.swift
//  Slide
//
//  Created by bibek timalsina on 4/15/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import SwiftyJSON

class UserService: FirebaseManager {
    
    var user:LocalUser?
    
    func saveUser(user: LocalUser, completion: @escaping CallBackWithSuccessError) {
        let userDict = user.toJSON()
        reference.child(Node.user.rawValue).child(user.id!).updateChildValues(userDict) { (error, _) in
            completion(error == nil, error)
        }
    }
    
    func addGoogleToken(user: LocalUser, fcmToken: String) {
        let userDict = ["fcmToken":fcmToken]
        reference.child(Node.user.rawValue).child(user.id!).updateChildValues(userDict) { (error, _) in
        }
    }
    
    func updateUserProfileImage(user: LocalUser, image: (URL?,UIImage?), index: String, completion: @escaping (((URL?,UIImage?), Error?) -> Void)) {
        
        if let img = image.1 {
            let data = UIImageJPEGRepresentation(img, 0.7)
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            
            let ref = storageRef.child("image_\(user.id!)_photo\(index).jpg")
            
            let uploadAction = ref.putData(data!, metadata: metaData)
            uploadAction.observe(.progress, handler: { (snapshot) in
                let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                    / Double(snapshot.progress!.totalUnitCount)
                print(percentComplete)
            })
            uploadAction.observe(.failure, handler: { (snapshot) in
                completion((image.0,image.1), snapshot.error)
                return
            })
            uploadAction.observe(.success, handler: { (snapshot) in
                ref.downloadURL(completion: { (url, error) in
                    if error == nil {
                        completion((url,nil), snapshot.error)
                    }
                    else {
                        completion((image.0,image.1), error)
                    }
                })
            })
        } else if let _ = image.0 {
            completion((image.0,nil), FirebaseManagerError.noDataFound)
        } else {
            completion((image.0,image.1), FirebaseManagerError.noDataFound)
        }
    }
    
    func removeFirebaseImage(image:URL , completion: @escaping CallBackWithError) {
        print(image)
        let imageString = image.absoluteString
        if imageString.range(of: "firebasestorage.googleapis.com") != nil {
            let ref = storagee.reference(forURL: imageString)
            ref.delete { (error) in
                completion(error)
            }
        } else {
            completion(nil)
        }
    }

    func downloadProfileImage(userId: String, index:String, completion : @escaping (URL?,FirebaseManagerError?) -> Void) {
        
        let ref = storageRef.child("images_\(userId)_photo\(index).jpg")
        print(ref.fullPath)
        ref.downloadURL(completion: { (url, error) in
            
            if error == nil {
                completion(url,nil)
            } else {
                guard let errorCode = (error as NSError?)?.code else {
                    return
                }
                guard let error = StorageErrorCode(rawValue: errorCode) else {
                    return
                }
                switch (error) {
                case .objectNotFound:
                    completion(nil,FirebaseManagerError.noDataFound)
                default:
                    completion(nil,FirebaseManagerError.noUserFound)
                    break
                }
            }
        })
    }
    
    func getMe(withId userId: String, completion: @escaping (LocalUser?, FirebaseManagerError?) -> Void) {
        reference.child(Node.user.rawValue).child(userId).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let json = JSON(snapshot.value ?? [])
            if let user: LocalUser = json.map() {
                completion(user, nil)
            }else {
                completion(nil, FirebaseManagerError.noUserFound)
            }
        })
    }

    
    func getUser(withId userId: String, completion: @escaping (LocalUser?, FirebaseManagerError?) -> Void) {
        reference.child(Node.user.rawValue).child(userId).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let json = JSON(snapshot.value ?? [])
            if let user: LocalUser = json.map() {
                completion(user, nil)
            }else {
                completion(nil, FirebaseManagerError.noUserFound)
            }
        })
    }
    
    func getAllUser(completion: @escaping ([LocalUser]) -> Void) {
        reference.child(Node.user.rawValue).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if let val = snapshot.value {
                let json = JSON(val)
                if let users:[LocalUser] = json.map() {
                    completion(users)
                } else {
                    var users:[LocalUser] = []
                    for (_,data) in json {
                        if let user:LocalUser = data.map() {
                            users.append(user)
                        }
                    }
                    completion(users)
                }
            }
        })
    }
    
    func getMatchListUsers(of user: LocalUser, completion: @escaping ([LocalUser]?, FirebaseManagerError?) -> ()) {
        reference.child(Node.user.rawValue).child(user.id!).child(Node.matchList.rawValue).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value {
                let matchList = JSON(value)
                if matchList.isEmpty {
                    completion(nil, FirebaseManagerError.noDataFound)
                    return
                }
                var users:[LocalUser] = []
                for (key,_) in matchList {
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
                }
            }
            else {
                completion(nil, FirebaseManagerError.noDataFound)
            }
        })
    }
    
    func getBlockedIds(of user: LocalUser, completion: @escaping ([String]?, FirebaseManagerError?) -> ()) {
        reference.child(Node.user.rawValue).child(user.id!).child(Node.blockedUsers.rawValue).observe(.value, with: { (snapshot) in
            if let value = snapshot.value {
                print(value)
                let json = JSON(value)
                var blockedIds:[String] = []
                for (key,_) in json {
                    blockedIds.append(key)
                }
                completion(blockedIds, nil)
            }
            else {
                completion(nil, FirebaseManagerError.noDataFound)
            }
        })
    }
    
    func getMatchedIds(of user: LocalUser, completion: @escaping ([String], FirebaseManagerError?) -> ()) {
        reference.child(Node.user.rawValue).child(user.id!).child(Node.matchList.rawValue).observe(.value, with: { (snapshot) in
            if let value = snapshot.value {
                print(value)
                let json = JSON(value)
                var matchedIds:[String] = []
                for (key,_) in json {
                    matchedIds.append(key)
                }
                completion(matchedIds, nil)
            }
            else {
                completion([], FirebaseManagerError.noDataFound)
            }
        })
    }
    
    func getChatListAndObserve(of user: LocalUser, completion: @escaping ([ChatItem]?, FirebaseManagerError?) -> ()) {
        reference.child(Node.user.rawValue).child(user.id!).child(Node.chatList.rawValue).observe(.value, with: { (snapshot) in
            if let value = snapshot.value {
                print(value)
                let chatList = JSON(value)
                var chatItems:[ChatItem] = []
                for (key,data) in chatList {
                    if var chatItem: ChatItem = data.map() {
                        chatItem.inUser = key
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
    
    func accept(user: LocalUser, myId: String, completion: @escaping(_ success: Bool, _ isMatching: Bool) -> Void) {
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
                print(isMatching)
            }
            
            let value = [
                "match": match,
                "time": Date().timeIntervalSince1970
                ] as [String : Any]
            
            self.reference.child(Node.user.rawValue).child(myId).child(Node.acceptList.rawValue).child(user.id!).updateChildValues(value) { (error, _) in
                
                if match {
                    
                    let value = [
                        "match": match
                        ] as [String : Any]
                    
                    self.reference.child(Node.user.rawValue).child(user.id!).child(Node.acceptList.rawValue).child(myId).updateChildValues(value) { (error, _) in
                        completion(error == nil, match)
                        
                        self.reference.child(Node.user.rawValue).child(myId).child(Node.matchList.rawValue).child(user.id!).updateChildValues(["time" : Date().timeIntervalSince1970, "userId":user.id!], withCompletionBlock: { (_, _) in
                            self.reference.child(Node.user.rawValue).child(user.id!).child(Node.matchList.rawValue).child(myId).updateChildValues(["time" : Date().timeIntervalSince1970, "userId":myId], withCompletionBlock: { (_, _) in
                                completion(error == nil, match)
                            })
                        })
                    }
                } else {
                    completion(error == nil, match)
                }
                
            }
        })
    }
    
    func reject(user: LocalUser, myId: String, completion: @escaping() -> Void) {
        // reference.child(FireBaseNodes.ConnectionsPending.rawValue).queryOrderedByChild(requestType.rawValue).queryEqualToValue(ofUid)
        
        print("OpponentId: \(user.id!)")
        print("MyId: \(myId)")
        reference.child(Node.user.rawValue).child(user.id!).child(Node.acceptList.rawValue).child(myId).observeSingleEvent(of: .value, with: {(snapshot) in
            
            var match:Bool?
            let value = [
                "time": Date().timeIntervalSince1970
                ] as [String : Any]
            if let val = snapshot.value {
                let json = JSON(val)
                if let _ = json["match"].bool {
                    match = false
                }
            }
            self.reference.child(Node.user.rawValue).child(myId).child(Node.acceptList.rawValue).child(user.id!).updateChildValues(value) { (error, _) in
                
                if let match = match {
                    
                    let value = [
                        "match": match
                        ] as [String : Any]
                    self.reference.child(Node.user.rawValue).child(user.id!).child(Node.acceptList.rawValue).child(myId).updateChildValues(value) { (error, _) in
                        completion()
                        
                        // If asked for remove from match list then uncomment below code
                        /* self.reference.child(Node.user.rawValue).child(myId).child(Node.matchList.rawValue).child(user.id!).removeValue()
                         self.reference.child(Node.user.rawValue).child(user.id!).child(Node.matchList.rawValue).child(myId).removeValue()
                         */
                    }
                } else {
                    completion()
                }
            }
        })
    }
    
    func getReportedAndBlockedUsers(completion: @escaping ([LocalUser]) -> Void) {
        
    }
    
    func block(user: LocalUser, myId: String, completion: @escaping CallBackWithSuccessError) {
        
        guard let opponetId = user.id, let fbID = user.profile.fbId else {
            completion(false,nil)
            return
        }
        
        let values:[String: Any] = [
            "userId" : opponetId,
            "fbId" : fbID,
            "time" : Date().timeIntervalSince1970
        ]
        
        reference.child(Node.user.rawValue).child(myId).child(Node.blockedUsers.rawValue).child(opponetId).updateChildValues(values) { (error, _) in
            if let error = error {
                completion(false, error)
            }else {
                completion(true, nil)
            }
        }
    }
    
    func blockAndReport(user: LocalUser, remark: String, completion: @escaping CallBackWithSuccessError) {
        guard let me = Authenticator.shared.user?.id else {
            completion(false, FirebaseManagerError.noUserFound)
            return
        }
        self.block(user: user, myId: me) { (success, error) in
            if success {
                self.report(user: user, remark: remark, completion: completion)
            }else {
                completion(false, error)
            }
        }
    }
    
    func report(user: LocalUser, remark: String, completion: @escaping CallBackWithSuccessError) {
        let dict = [
            "reportedBy": Authenticator.currentFIRUser!.uid,
            "remarks": remark,
            "reportedOn": user.id!
        ]
        reference.child(Node.report.rawValue).childByAutoId().updateChildValues(dict) { (error, _) in
            completion(error == nil, error)
        }
    }
    
    func expectUserIdsOfacceptList(userId:String , completion: @escaping (_ users : [String]) -> Void) {
        let refAccept = reference.child(Node.user.rawValue).child(userId).child(Node.acceptList.rawValue)
        var usersIds:[String] = []
        refAccept.observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value {
                let acceptList = JSON(value)
                if acceptList.count == 0 {
                    completion(usersIds)
                    return
                }
                var i = 0
                for (key,list) in acceptList {
                    i += 1
                    let acceptTime = list["time"].doubleValue
                    let timeValid = (Date().timeIntervalSince1970 - acceptTime) < checkInThreshold
                    if timeValid {
                        usersIds.append(key)
                    }
                    if acceptList.count == i {
                        completion(usersIds)
                    }
                }
            } else {
                completion(usersIds)
            }
            
        })
    }
    
    private func deleteChat(userId:String , completion: @escaping (_ references : [DatabaseReference]?, _ error : Error?) -> Void) {
        // Delete ChatList
        let ref = reference.child(Node.user.rawValue).child(userId).child(Node.chatList.rawValue)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value {
                let chatList = JSON(value)
                var chatItems:[ChatItem] = []
                var refs:[DatabaseReference] = []
                if chatList.count == 0 {
                    completion(refs,nil)
                    return
                }
                for (_,data) in chatList {
                    if let chatItem: ChatItem = data.map(), let chatId =  chatItem.chatId, let chatUser =  chatItem.userId {
                        chatItems.append(chatItem)
                        let ref = self.reference.child(Node.user.rawValue).child(chatUser).child(Node.chatList.rawValue).child(userId)
                        let ref2 = self.reference.child(Node.chat.rawValue).child(chatId)
                        refs.append(ref)
                        refs.append(ref2)
                        if refs.count == chatList.count*2 {
                            completion(refs,nil)
                        }
                    }
                }
            } else {
                completion(nil,DeleteError.chat)
            }
        })
    }
    
    private func deleteAcceptAndMatchList(userId:String , completion: @escaping (_ references : [DatabaseReference]?, _ error : Error?) -> Void) {
        // Delete MatchList and Accept List
        let refAccept = reference.child(Node.user.rawValue).child(userId).child(Node.acceptList.rawValue)
        refAccept.observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value {
                let acceptList = JSON(value)
                var acceptedUser:[String] = []
                var refs:[DatabaseReference] = []
                if acceptList.count == 0 {
                    completion(refs,nil)
                    return
                }
                for (key,_) in acceptList {
                    acceptedUser.append(key)
                    let ref = self.reference.child(Node.user.rawValue).child(key).child(Node.acceptList.rawValue).child(userId)
                    let ref2 = self.reference.child(Node.user.rawValue).child(key).child(Node.matchList.rawValue).child(userId)
                    refs.append(ref)
                    refs.append(ref2)
                    if refs.count == acceptedUser.count*2 {
                        completion(refs,nil)
                    }
                }
            } else {
                completion(nil, DeleteError.acceptList)
            }
        })
    }
    
    private func deleteCheckIns(userId:String , completion: @escaping (_ references : [DatabaseReference]?, _ error : Error?) -> Void) {
        // Delete MatchList and Accept List
        
        var PlacesRefs:[DatabaseReference] = []
        if let places = Authenticator.shared.places {
            places.forEach({ (place) in
                if let placeName = place.nameAddress {
                    let ref = self.reference.child(Node.Places.rawValue).child(placeName.replacingOccurrences(of: " ", with: "")).child(Node.checkIn.rawValue).child(userId)
                    PlacesRefs.append(ref)
                }
                if place.nameAddress == places.last?.nameAddress {
                    completion(PlacesRefs, nil)
                }
            })
        } else {
            completion(nil, DeleteError.checkIn)
        }
    }
    
    func deleteUser(userId:String , completion: @escaping CallBackWithSuccessError)  {
        var firebaseRefereces:[DatabaseReference] = []
        self.deleteChat(userId: userId, completion: { (chatRefs,error) in
            if let error = error {
                completion(false, error)
            } else {
                chatRefs?.forEach({ (ref) in
                    firebaseRefereces.append(ref)
                })
                
                self.deleteAcceptAndMatchList(userId: userId, completion: { (acceptRefs,error) in
                    if let err = error {
                        completion(false, err)
                    } else {
                        acceptRefs?.forEach({ (ref) in
                            firebaseRefereces.append(ref)
                        })
                        
                        // get checkIn Refs
                        self.deleteCheckIns(userId: userId, completion: { (checkInRefs, error) in
                            if let error = error {
                                completion(false, error)
                            } else {
                                checkInRefs?.forEach({ (ref) in
                                    firebaseRefereces.append(ref)
                                })
                                
                                // finally remove user
                                firebaseRefereces.forEach({ (ref) in
                                    ref.removeValue()
                                })
                                self.reference.child(Node.user.rawValue).child(userId).removeValue { (error, _) in
                                    if let error = error {
                                        completion(false, error)
                                    } else {
                                        completion(true, nil)
                                    }
                                }
                            }
                        })
                        
                    }
                })
            }
        })
    }
    
    func unMatch(opponent opponentId: String, withMe myId: String, chatId: String, completion: @escaping CallBackWithSuccessError) {
        /* This will
         1. remove my matchlist for opponent, opponent matchlist for me
         2. remove chat for chatId
         3. remove my chatlist for opponent, opponent chatlist for me
         4. remove acceptlist for opponet
         5. update accept list match to false in opponent
         */
        
        // 1
        _ = reference.child(Node.user.rawValue).child(myId).child(Node.matchList.rawValue).child(opponentId).removeValue()
        _ = reference.child(Node.user.rawValue).child(opponentId).child(Node.matchList.rawValue).child(myId).removeValue()
        
        // 4
        _ = reference.child(Node.user.rawValue).child(myId).child(Node.acceptList.rawValue).child(opponentId).removeValue()
        
        // 5
        let ref = reference.child(Node.user.rawValue).child(opponentId).child(Node.acceptList.rawValue).child(myId)
        let value = [
            "match": false
            ] as [String : Any]
        ref.updateChildValues(value, withCompletionBlock: { (error, _) in
            if error == nil {
                completion(true, nil)
            } else {
                completion(false, error)
            }
        })
        
    }

}
