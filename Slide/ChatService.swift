//
//  ChatService.swift
//  Slide
//
//  Created by bibek timalsina on 4/20/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import Foundation
import FirebaseDatabase
import SwiftyJSON
import UserNotifications

class ChatService: FirebaseManager {
    private var chatRefIds = [String: UInt]()
    
    static let shared = ChatService()
    
    func logout() {
        reference.removeAllObservers()
    }
    
    private func addRef(for chat: ChatItem, ref: UInt) {
        self.stop(chat: chat)
        chatRefIds[chat.chatId!] = ref
    }
    
    func getChatListAndObserve(of user: LocalUser, completion: @escaping (ChatItem?, FirebaseManagerError?) -> ()) {
        reference.child(Node.user.rawValue).child(user.id!).child(Node.chatList.rawValue).observe(.childAdded, with: { (snapshot) in
            let json = JSON(snapshot.value ?? [])
            if let chatItem: ChatItem = json.map() {
                completion(chatItem, nil)
            }else {
                completion(nil, FirebaseManagerError.noDataFound)
            }
        })
    }
    
    func observeChatList(_ viewController: UIViewController) {
        if let userId = Authenticator.shared.user?.id {
            reference.child(Node.user.rawValue).child(userId).child(Node.chatList.rawValue).observe(.childChanged, with: { (snapshot) in
                let json = JSON(snapshot.value ?? [])
                print(json)
                if let chatItem: ChatItem = json.map() {
                    if chatItem.userId !=  userId {
                        Utilities.fireChatNotification(viewController,chatItem: chatItem)
                    }
                }
            })
        }
    }
    
    
    func observeMatchList(_ viewController: UIViewController) {
        if let userId = Authenticator.shared.user?.id {
            reference.child(Node.user.rawValue).child(userId).child(Node.matchList.rawValue).observe(.childChanged, with: { (snapshot) in
                let json = JSON(snapshot.value ?? [])
                print(json)
                if let id = json["userId"].string {
                       Utilities.fireMatchedNotification(viewController, userId: id)
                }
            })
        }
    }

    
    func getLastMessage(of user: LocalUser, forUserId: String,  completion: @escaping (ChatItem?, FirebaseManagerError?) -> ()) {
        reference.child(Node.user.rawValue).child(user.id!).child(Node.chatList.rawValue).child(forUserId).observeSingleEvent(of: .value, with: { (snapshot) in
            let json = JSON(snapshot.value ?? [])
            if let chatItem: ChatItem = json.map() {
                completion(chatItem, nil)
            }else {
                completion(nil, FirebaseManagerError.noDataFound)
            }
        })
    }
    
    func addChatList(for friend:String, withMe me :String, message: String,  completion : @escaping (_ chatId : String, _ error : Error?) -> Void) {
        
        
        let chatId =  friend > me ? friend+me : me+friend
        
        let ref = self.reference.child(Node.chat.rawValue).child(chatId)
        
        let value = [
            "time" : Date().timeIntervalSince1970
        ]
        ref.updateChildValues(value, withCompletionBlock: { error, _ in
            if error == nil {
            let refMe = self.reference.child(Node.user.rawValue).child(me).child(Node.chatList.rawValue).child(friend)
            let refFriend = self.reference.child(Node.user.rawValue).child(friend).child(Node.chatList.rawValue).child(me)
                
            let value = [
                "userId" : me,
                "chatId" : chatId,
                "lastMessage" : message
                ] as [String : Any]
                
            refFriend.updateChildValues(value, withCompletionBlock: { error, _ in
                if error == nil {
                    refMe.updateChildValues(value, withCompletionBlock: { error, _ in
                        completion(chatId, error)
                    })
                } else {
                    completion(chatId, error)
                }
            })
            } else {
                completion(chatId, error)
            }
        })
    }
    
    func getDataAndObserve(of chat: ChatItem, completion: @escaping (ChatData?, FirebaseManagerError?) -> ()) {
        let refId = reference.child(Node.chat.rawValue).child(chat.chatId!).queryLimited(toLast: 25).observe(.childAdded, with: { (snapshot) in
            let json = JSON(snapshot.value ?? [])
            if let chatData: ChatData = json.map() {
                completion(chatData, nil)
            }else {
                completion(nil, FirebaseManagerError.noDataFound)
            }
        })
        
        self.addRef(for: chat, ref: refId)
    }
    
    func loadMoreData(of chat: ChatItem, lastChatData: ChatData, completion: @escaping ([ChatData]?, FirebaseManagerError?) -> ()) {
        
        reference.child(Node.chat.rawValue).child(chat.chatId!).queryOrderedByKey().queryLimited(toLast: 25).queryEnding(atValue: lastChatData.id!).observeSingleEvent(of: .value, with: { (snapshot) in
            let json = JSON(snapshot.value ?? [])
            if let chatData: [ChatData] = json.map() {
                completion(chatData, nil)
            }else {
                completion(nil, FirebaseManagerError.noDataFound)
            }
        })
    }
    
    func stop(chat: ChatItem) {
        if let value = chatRefIds[chat.chatId!] {
            reference.removeObserver(withHandle: value)
        }
    }
    
    func send(message: ChatData, chatId: String, completion: @escaping CallBackWithSuccessError) {
        let ref = reference.child(Node.chat.rawValue).child(chatId).childByAutoId()
        var message = message
        message.id = ref.key
        
        ref.updateChildValues(message.toJSON(), withCompletionBlock: { error, _ in
            completion(error == nil, error)
        })
    }

}

