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
    
    var user:User?
    
    func saveUser(user: User, completion: @escaping CallBackWithSuccessError) {
        let userDict = user.toJSON()
        
        reference.child(Node.user.rawValue).child(user.id!).updateChildValues(userDict) { (error, _) in
            completion(error == nil, error)
        }
    }
    
    func updateUserProfileImage(user: User, image: (URL?,UIImage?), index: String, completion: @escaping (((URL?,UIImage?), Error?) -> Void)) {
        
        if let img = image.1 {
            let data = UIImageJPEGRepresentation(img, 0.7)
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpeg"
            
            let ref = storageRef.child("images/\(user.id!)/photo\(index).jpg")
            let uploadAction = ref.put(data!, metadata: metaData)
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
        let ref = storagee.reference(forURL: image.absoluteString)
        ref.delete { (error) in
            print(error?.localizedDescription ?? "No error")
            completion(error)
        }
    }

    func downloadProfileImage(userId: String, index:String, completion : @escaping (URL?,FirebaseManagerError?) -> Void) {
        
        let ref = storageRef.child("images/\(userId)/photo\(index).jpg")
        print(ref.fullPath)
        ref.downloadURL(completion: { (url, error) in
            
            if error == nil {
                completion(url,nil)
            } else {
                guard let errorCode = (error as? NSError)?.code else {
                    return
                }
                guard let error = FIRStorageErrorCode(rawValue: errorCode) else {
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
