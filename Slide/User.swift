//
//  User.swift
//  Slide
//
//  Created by bibek timalsina on 3/26/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import Foundation
import ObjectMapper

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id
}

struct User: Mappable, Equatable {
    var id: String?
    var profile = Profile()
    var checkIn : UserCheckIn?
    var blockedUsers: [String] = []
    var userWhoBlockedMe: [String] = []
    var acceptedStatus = false
    
    init() {}
    
    init?(map: Map) {
        self.mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        profile <- map["profile"]
        checkIn <- map[Node.checkIn.rawValue]
        blockedUsers <- map["blockedUsers"]
        userWhoBlockedMe <- map["blockedByUsers"]
    }
}

struct UserCheckIn: Mappable {
    var place: String?
    var placeID: String?
    var time: Double?
    
    init?(map: Map) {
        self.mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        place <- map["place"]
        placeID <- map["placeID"]
        time <- map["time"]
    }
}

struct Profile: Mappable {
    var fbId: String?
    var dateOfBirth: String?
    var name: String?
    var firstName:String?
    var lastName:String?
    var bio: String?
    var images: [URL] = []
    var distanceLowerBound: Double?
    var distanceUpperBound: Double?
    var ageLowerBound: Double?
    var ageUpperBound: Double?
    
    init() {
        
    }
    
    init?(map: Map) {
        self.mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        fbId <- map["fbId"]
        dateOfBirth <- map["dateOfBirth"]
        name <- map["name"]
        firstName <- map["firstName"]
        lastName <- map["lastName"]
        bio <- map["bio"]
        images <- (map["images"], URLTransform())
        distanceLowerBound <- map["distanceLowerBound"]
        distanceUpperBound <- map["distanceUpperrBound"]
        ageLowerBound <- map["ageLowerBound"]
        ageUpperBound <- map["ageUpperBound"]
    }
    
}
