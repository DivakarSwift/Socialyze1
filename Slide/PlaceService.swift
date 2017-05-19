//
//  PlaceService.swift
//  Slide
//
//  Created by bibek timalsina on 4/15/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import Foundation
import FirebaseDatabase
import  SwiftyJSON

class PlaceService: FirebaseManager {
    func user(_ user: User, checkInAt place: Place, completion: @escaping CallBackWithSuccessError) {
        
        let ref1 = self.reference.child("Places").child(place.nameAddress.replacingOccurrences(of: " ", with: "")).child(Node.checkIn.rawValue).child(user.id!)
        
        let ref2 = self.reference.child(Node.user.rawValue).child(user.id!).child(Node.checkIn.rawValue)
       
        var values:[String : Any] = [
            "userId": user.id!,
            "time": Date().timeIntervalSince1970,
            "fbId": user.profile.fbId!
            ]
        
        ref1.updateChildValues(values, withCompletionBlock: {(error: Error?, ref: FIRDatabaseReference) -> Void in
            
            values = [
                "place" : place.nameAddress,
                "placeID" : place.placeID,
                "time" : Date().timeIntervalSince1970
            ]
            ref2.updateChildValues(values, withCompletionBlock: {(error: Error?, ref: FIRDatabaseReference) -> Void in
                completion(error == nil, error)
            })
        })
    }
    
    
    func user(_ user: User, checkOutFrom place: Place, completion: @escaping CallBackWithSuccessError) {
        
        self.reference.child("Places").child(place.nameAddress.replacingOccurrences(of: " ", with: "")).child("checkIn").child(user.id!).observeSingleEvent(of: .value, with:{ (snapshot) in
            if let val = snapshot.value{
                let json = JSON(val)
                let time = json["time"].doubleValue
                let timeValid = (Date().timeIntervalSince1970 - time) < checkInThreshold
                completion(timeValid,nil)
            } else {
                completion(false,nil)
            }
        })
    }
    
    func getCheckInUsers(at place: Place, completion: @escaping ([Checkin])->(), failure: @escaping (FirebaseManagerError)->()) {
        self.reference.child("Places").child(place.nameAddress.replacingOccurrences(of: " ", with: "")).child("checkIn").observeSingleEvent(of: .value, with: {(snapshot: FIRDataSnapshot) in
            if let snapshotValue = snapshot.value {
                if let json: [Checkin] = JSON(snapshotValue).dictionary?.values.flatMap({ (json) -> Checkin? in
                    return json.map()
                }) {
                    completion(json)
                    return
                }
            }
            failure(FirebaseManagerError.noDataFound)
        })
    }
}
