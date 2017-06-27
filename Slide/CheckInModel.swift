//
//  CheckInModel.swift
//  Slide
//
//  Created by bibek timalsina on 4/15/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import Foundation
import ObjectMapper

struct Checkin: Mappable {
    var fbId: String?
    var time: Double?
    var userId: String?
    var isGoing:Bool = false
    var isCheckedIn: Bool = false
    
    init?(map: Map) {
        self.mapping(map: map)
    }
    
    init(fbId: String, time: Double, userId: String) {
        self.fbId = fbId
        self.time = time
        self.userId = userId
    }
    
    mutating func mapping(map: Map) {
        self.fbId <- map["fbId"]
        self.time <- map["time"]
        self.userId <- map["userId"]
    }
}
