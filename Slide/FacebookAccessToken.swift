//
//  FacebookAccessToken.swift
//  Slide
//
//  Created by Rajendra on 6/21/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import Foundation
import ObjectMapper

struct FacebookAccessToken: Mappable {
    
    public var appId: String?
    public var authenticationToken: String?
    public var userId: String?
    public var refreshDate: String?
    public var expirationDate: String?
    
    
    init() {
        
    }
    
    init?(map: Map) {
        self.mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        appId <- map["appId"]
        authenticationToken <- map["authenticationToken"]
        userId <- map["userId"]
        refreshDate <- map["refreshDate"]
        expirationDate <- map["expirationDate"]
    }
}
