//
//  User.swift
//  Slide
//
//  Created by bibek timalsina on 3/26/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import Foundation
import ObjectMapper

struct User: Mappable {
    var id: String?
    var fbId: String?
    var dateOfBirth: TimeInterval?
    var name: String?
    var bio: String?
    var images: [URL] = []
    var distanceLowerBound: Double?
    var distanceUpperBound: Double?
    var ageLowerBound: Double?
    var ageUpperBound: Double?
    var blockedUsers: [String] = []
    var userWhoBlockedMe: [String] = []
    
    init() {}
    
    init?(map: Map) {
        self.mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        fbId <- map["fbId"]
        dateOfBirth <- map["dateOfBirth"]
        name <- map["name"]
        bio <- map["bio"]
        images <- (map["images"], URLTransform())
        distanceLowerBound <- map["distanceLowerBound"]
        distanceUpperBound <- map["distanceUpperrBound"]
        ageLowerBound <- map["ageLowerBound"]
        ageUpperBound <- map["ageUpperBound"]
        blockedUsers <- map["blockedUsers"]
        userWhoBlockedMe <- map["blockedByUsers"]
    }
}
