//
//  FacebookUser.swift
//  Slide
//
//  Created by bibek timalsina on 4/15/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import Foundation

struct FacebookFriend: Equatable {
    var id: String
    var name: String
    var profileURLString: String
    var dateOfBirth:String?
}

func ==(lhs: FacebookFriend, rhs: FacebookFriend) -> Bool {
    return lhs.id == rhs.id
}
