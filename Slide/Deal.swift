//
//  Deal.swift
//  Slide
//
//  Created by Lizan Pradhanang on 7/8/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import Foundation
import ObjectMapper

class Deal: Mappable{
    var detail:String?
    var expiry:String?
    var count:Int?
    var users:[[String:Any]]?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        detail <- map["Deal Details"]
        expiry <- map["Expiry Date"]
        count <- map["Use Count"]
        users <- map["Users"]
    }
}
