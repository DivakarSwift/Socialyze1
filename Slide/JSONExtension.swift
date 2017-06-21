//
//  JSONExtension.swift
//  EKTracking
//
//  Created by Salem Khan on 1/2/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import Foundation
import SwiftyJSON
import ObjectMapper

extension JSON {
    func map<T: Mappable>() -> [T]? {
        let json = self.array
        let mapped: [T]? = json?.flatMap({$0.map()})
        return mapped
    }
    
    func map<T: Mappable>() -> T? {
        let obj: T? = Mapper<T>().map(JSONObject: self.object)
        return obj
    }
    
    public var date: Date? {
        get {
            if let str = self.string {
                return JSON.jsonDateFormatter.date(from: str)
            }
            return nil
        }
    }
    
    private static let jsonDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        return dateFormatter
    }()
}


