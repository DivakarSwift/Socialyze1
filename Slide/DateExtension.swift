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
}
