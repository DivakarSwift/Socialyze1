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
    
    func getChatListAndObserve(of user: User, completion: @escaping (ChatItem?, FirebaseManagerError?) -> ()) {
        reference.child(Node.user.rawValue).child(user.id!).child(Node.chatList.rawValue).observe(.childAdded, with: { (snapshot) in
            let json = JSON(snapshot.value ?? [])
            if let chatItem: ChatItem = json.map() {
                completion(chatItem, nil)
            }else {
                completion(nil, FirebaseManagerError.noDataFound)
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
}
