//
//  PlaceService.swift
//  Slide
//
//  Created by bibek timalsina on 4/15/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import Foundation
import FirebaseDatabase

class PlaceService: FirebaseManager {
    func user(user: User, checkInAt place: Place, completion: @escaping (_ key: String, _ success: Bool, _ error: Error?) -> ()) {
        let values = [
            "userId": user.id!,
            "time": Date().timeIntervalSince1970
        ] as [String : Any]
        
        self.reference.child("Places").child(place.nameAddress.replacingOccurrences(of: " ", with: "")).child("checkIn").childByAutoId().setValue(values, withCompletionBlock: {(error: Error?, ref: FIRDatabaseReference) -> Void in
            
            completion(ref.key, error == nil, error)
        })
    }
    
    
    func updateCheckIn() {
        
    }
    
    func getCheckInUsers() {
        
    }
}
