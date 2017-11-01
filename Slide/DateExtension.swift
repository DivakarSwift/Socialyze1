//
//  DateExtension.swift
//  Slide
//
//  Created by bibek timalsina on 8/17/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import Foundation

extension Date {
    func startOfNextDay() -> Date {
        return Calendar.current.startOfDay(for: self).addingTimeInterval(24*60*60)
    }
    
    func ago(from: Date) -> String? {
        var textTimeElapsed: String?
        if from >= self {
            let timeMag = getTimeMag(from)
            textTimeElapsed = timeMag.time > 0 && timeMag.mag != "" ? "\(timeMag.time) \(timeMag.mag)\(timeMag.time > 1 ? "s" : "") ago" : "a moment ago"
        }
        return textTimeElapsed
    }
    
    private func getTimeMag(_ compareToDate: Date) -> (time: Int, mag: String) {
        var time: Int = 0
        var mag: String = ""
        let calender = Calendar.current
        
        let dateComponents = calender.dateComponents([.day, .month, .year, .hour, .minute, .second], from: self, to: compareToDate)
        
        let netYr    = abs(dateComponents.year ?? 0)
        let netMonth = abs(dateComponents.month ?? 0)
        let netDay   = abs(dateComponents.day ?? 0)
        let netHours = abs(dateComponents.hour ?? 0)
        let netMin   = abs(dateComponents.minute ?? 0)
        // let netSec   = abs(dateComponents.second)
        
        if netYr >= 1 {
            time = netYr
            mag = "yr"
        }else if netMonth >= 1 {
            time = netMonth
            mag = "month"
        } else if netDay >= 1 {
            time = netDay
            mag = "day"
        } else if netHours >= 1 {
            time = netHours
            mag = "hr"
        } else if netMin >= 1 {
            time = netMin
            mag = "min"
        }
        //        else if abs(netSec) >= 0 {
        //            time = abs(netSec)
        //            mag = "sec"
        //        }
        return (time, mag)
    }
    
    func left(to: Date) -> String? {
        var textTimeRemaining: String?
        if to <= self {
            let timeMag = getTimeMag(to)
            textTimeRemaining = timeMag.time > 0 && timeMag.mag != "" ? "\(timeMag.time) \(timeMag.mag)\(timeMag.time > 1 ? "s" : "")" : "a moment"
        }
        return textTimeRemaining
    }
}
