//
//  ActivityService.swift
//  Slide
//
//  Created by bibek timalsina on 10/19/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import SwiftyJSON

class ActivityService: FirebaseManager {
    func getActivities(myId: String, completion: @escaping ([ActivityModel]) -> ()) {
        self.reference.child("Activities").queryOrdered(byChild: "receivers/\(myId)").queryEqual(toValue: true).observeSingleEvent(of: .value, with: {snapshot in
            if let value = snapshot.value {
                let activitiesJson = JSON(value)
                let activities = activitiesJson.flatMap({ value -> ActivityModel? in
                    return value.1.map()
                })
                completion(activities)
            }else {
                completion([])
            }
        })
    }
}
