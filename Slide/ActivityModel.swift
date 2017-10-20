//
//  ActivityModel.swift
//  Slide
//
//  Created by bibek timalsina on 10/19/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import Foundation
import ObjectMapper

struct ActivityModel: Mappable {
    var message: String?
    var type: String?
    var sender: String?
    var time: Double?
    var place: String?
    var additionalMessage: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        message <- map["message"]
        type <- map["type"]
        sender <- map["sender"]
        time <- map["time"]
        place <- map["place"]
        additionalMessage <- map["additionalMessage"]
    }
}
