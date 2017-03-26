//
//  User.swift
//  Slide
//
//  Created by bibek timalsina on 3/26/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import Foundation
import SwiftyJSON

struct User {
    var bio: String?
    var images: [URL] = []
    var distanceLowerBound: Double?
    var distanceUpperBound: Double?
    var ageLowerBound: Double?
    var ageUpperBound: Double?
    
//    init(dict: [String: Any]) {
//        self.bio = (dict["bio"] as? String) ?? ""
//        
//        let images = (dict["images"] as? [String]) ?? []
//        self.images = images.flatMap(URL.init(string: ))
//        
//        self.distanceLowerBound = (dict["distanceLowerBound"] as? Double) ?? 0.0
//        self.distanceUpperBound = (dict["distanceUpperBound"] as? Double) ?? 0.0
//         self.ageLowerBound = (dict["ageLowerBound"] as? Double) ?? 0.0
//         self.ageUpperBound = (dict["ageUpperBound"] as? Double) ?? 0.0
//    }
    
//    init
}
