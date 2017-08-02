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
    
    func getFreshPlace(place: Place, completion: @escaping (Place) -> ()) {
        let placeName = place.nameAddress ?? ""
        self.reference.child(Node.PlacesList.rawValue).queryOrdered(byChild: "nameAddress").queryEqual(toValue: placeName).observeSingleEvent(of: .value, with: {snapShot in
            
            if let snapshotValue = ((snapShot.value) as? [String: Any])?.first?.value, let place: Place = JSON(snapshotValue).map() {
                completion(place)
            } else {
                // failure(FirebaseManagerError.noDataFound)
            }
        })
    }
    
    func getPlaces( completion: @escaping ([Place])->(), failure: @escaping (FirebaseManagerError)->()) {
        self.reference.child(Node.PlacesList.rawValue).observeSingleEvent(of: .value, with: {(snapshot: DataSnapshot) in
            if let snapshotValue = snapshot.value, let places:[Place] = JSON(snapshotValue).map() {
                completion(places)
            } else {
                failure(FirebaseManagerError.noDataFound)
            }
        })
    }
    
    
    
    func user(_ user: LocalUser, checkInAt place: Place, completion: @escaping CallBackWithSuccessError) {
        
        let ref1 = self.reference.child(Node.Places.rawValue).child((place.nameAddress?.replacingOccurrences(of: " ", with: ""))!).child(Node.checkIn.rawValue).child(user.id!)
        
        let ref2 = self.reference.child(Node.user.rawValue).child(user.id!).child(Node.checkIn.rawValue)
        
        var values:[String : Any] = [
            "userId": user.id!,
            "time": Date().timeIntervalSince1970,
            "fbId": user.profile.fbId!
        ]
        
        ref1.updateChildValues(values, withCompletionBlock: {(error: Error?, ref: DatabaseReference) -> Void in
            
            values = [
                "place" : place.nameAddress ?? "",
                "placeID" : place.placeId ?? "",
                "time" : Date().timeIntervalSince1970
            ]
            ref2.updateChildValues(values, withCompletionBlock: {(error: Error?, ref: DatabaseReference) -> Void in
                completion(error == nil, error)
            })
        })
    }
    
    func user(_ user: LocalUser, checkOutFrom place: Place, completion: @escaping CallBackWithSuccessError) {
        guard let placeName = place.nameAddress else {
            completion(false,nil)
            return
        }
        self.reference.child(Node.Places.rawValue).child(placeName.replacingOccurrences(of: " ", with: "")).child(Node.checkIn.rawValue).child(user.id!).observeSingleEvent(of: .value, with:{ (snapshot) in
            if let val = snapshot.value{
                let json = JSON(val)
                let time = json["time"].doubleValue
                let timeValid = (Date().timeIntervalSince1970 - time) < checkInThreshold
                completion(timeValid,nil)
            } else {
                completion(false,nil)
            }
        })
        
        self.reference.child(Node.Places.rawValue).child(placeName.replacingOccurrences(of: " ", with: "")).child(Node.checkIn.rawValue).child(user.id!).observeSingleEvent(of: .value, with:{ (snapshot) in
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
        guard let placeName = place.nameAddress else {
            failure(FirebaseManagerError.noUserFound)
            return
        }
        self.reference.child(Node.Places.rawValue).child(placeName.replacingOccurrences(of: " ", with: "")).child(Node.checkIn.rawValue).observeSingleEvent(of: .value, with: {(snapshot: DataSnapshot) in
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
    
    func user(_ user: LocalUser, goingAt event: Place, completion: @escaping CallBackWithSuccessError) {
        
        let ref1 = self.reference.child(Node.Places.rawValue).child((event.nameAddress?.replacingOccurrences(of: " ", with: ""))!).child(Node.going.rawValue).child(event.event?.uid ?? "--1").child(user.id!)
        
        let values:[String : Any] = [
            "userId": user.id!,
            "time": Date().timeIntervalSince1970,
            "fbId": user.profile.fbId!
        ]
        
        ref1.updateChildValues(values, withCompletionBlock: {(error: Error?, ref: DatabaseReference) -> Void in
            completion(error == nil, error)
        })
    }
    
    
    func getGoingUsers(at place: Place, completion: @escaping ([Checkin])->(), failure: @escaping (FirebaseManagerError)->()) {
        guard let placeName = place.nameAddress else {
            failure(FirebaseManagerError.noUserFound)
            return
        }
        if place.event?.expiryDate?.compare(Date()) == ComparisonResult.orderedAscending {
            completion([])
            return
        }
        self.reference.child(Node.Places.rawValue).child(placeName.replacingOccurrences(of: " ", with: "")).child(Node.going.rawValue).child(place.event?.uid ?? "--1").observeSingleEvent(of: .value, with: {(snapshot: DataSnapshot) in
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
