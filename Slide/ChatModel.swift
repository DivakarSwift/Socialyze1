//
//  ChatModel.swift
//  Slide
//
//  Created by bibek timalsina on 4/20/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import Foundation
import ObjectMapper

struct ChatItem: Mappable {
    var userId: String?
    var lastMessage: String?
    var isSeenByOtherUser: Bool?
    var newMessageCount: Int?
    var chatId: String?
    
    init?(map: Map) {
        self.mapping(map: map)
    }
    
    init () {
        
    }
        
    mutating func mapping(map: Map) {
        userId <- map["userId"]
        lastMessage <- map["lastMessage"]
        isSeenByOtherUser <- map["isSeenByOtherUser"]
        newMessageCount <- map["newMessageCount"]
        chatId <- map["chatId"]
    }
}

struct ChatData: Mappable {
    var fromUser: String?
    var toUser: String?
    var time: Double?
    var message: String?
    var id: String?
    
    init?(map: Map) {
        self.mapping(map: map)
    }
    
    init () {
        
    }
    
    mutating func mapping(map: Map) {
        fromUser <- map["fromUser"]
        toUser <- map["toUser"]
        time <- map["time"]
        message <- map["message"]
    }
}
