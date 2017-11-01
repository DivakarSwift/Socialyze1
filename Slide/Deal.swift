//
//  Deal.swift
//  Slide
//
//  Created by Bibek on 7/8/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import Foundation
import ObjectMapper

class Deal: Mappable{
    var detail:String?
    var expiry:String?
    var minimumFriends: Int?
    var uid: String?
    var image: String?
    var endTime: String?
    var fromTime: String?
    var startDate: String?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        detail <- map["dealDetail"]
        expiry <- map["expiryDate"]
        minimumFriends <- map["minimumFriends"]
        uid <- map["uid"]
        image <- map["image"]
        endTime <- map["endTime"]
        fromTime <- map["fromTime"]
        startDate <- map["startDate"]
    }
    
    func isActive() -> (Bool, String?) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        let todayDateString = formatter.string(from: Date())
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        
        let startDateTimeStringForDeal = todayDateString + "T" + (fromTime ?? "")
        let startDateTimeForDeal = formatter.date(from: startDateTimeStringForDeal)
        
        let endDateTimeStringForDeal = todayDateString + "T" + (endTime ?? "")
        let endDateTimeForDeal = formatter.date(from: endDateTimeStringForDeal)
        
        var isActiveNow: Bool = false
        var msg: String?
        if let startDateTimeForDeal = startDateTimeForDeal, let endDateTimeForDeal = endDateTimeForDeal {
            let date = Date()
            let startDateCompareResult = date.compare(startDateTimeForDeal)
            let endDateCompareResult = date.compare(endDateTimeForDeal)
            
            isActiveNow = (startDateCompareResult == .orderedDescending || startDateCompareResult == .orderedSame) && endDateCompareResult == .orderedAscending
            
            if !isActiveNow {
                if startDateCompareResult == .orderedAscending {
                    msg = "resumes in " + (startDateTimeForDeal.left(to: date) ?? "")
                }else {
                    msg = "resumes in " + (startDateTimeForDeal.addingTimeInterval(24*60*60).left(to: date) ?? "")
                }
            }
            
        }
        return (isActiveNow, msg)
    }
    
    func isValid() -> Bool {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        
        let startDateTimeStringForDeal = (startDate ?? "") + "T" + (fromTime ?? "")
        let startDateTimeForDeal = formatter.date(from: startDateTimeStringForDeal)
        
        let endDateTimeStringForDeal = (expiry ?? "") + "T" + (endTime ?? "")
        let endDateTimeForDeal = formatter.date(from: endDateTimeStringForDeal)
        
        if let startDateTimeForDeal = startDateTimeForDeal, let endDateTimeForDeal = endDateTimeForDeal {
            let date = Date()
            let startDateCompareResult = date.compare(startDateTimeForDeal)
            let endDateCompareResult = date.compare(endDateTimeForDeal)
            
            return (startDateCompareResult == .orderedDescending || startDateCompareResult == .orderedSame) && endDateCompareResult == .orderedAscending
        }
        return false
    }
}

class PlaceDeal: Mappable {
    var count:Int?
    var users:[String:Any]?
    
    init() {}
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        count <- map["useCount"]
        users <- map["users"]
    }
}
