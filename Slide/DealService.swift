//
//  DealService.swift
//  Slide
//
//  Created by Bibek on 7/8/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import Foundation
import Firebase
import ObjectMapper
import SwiftyJSON

class DealService: FirebaseManager {
    
    func getPlaceDeal(place: Place, completion: @escaping (Place) -> ()) {
        let placeName = place.nameAddress ?? ""
        self.reference.child(Node.PlacesList.rawValue).queryOrdered(byChild: "nameAddress").queryEqual(toValue: placeName).observeSingleEvent(of: .value, with: {snapShot in
            
            if let snapshotValue = ((snapShot.value) as? [String: Any])?.first?.value, let place: Place = JSON(snapshotValue).map() {
                completion(place)
            } else {
               // failure(FirebaseManagerError.noDataFound)
            }
        })
    }
    
    func getPlaceDealInPlace(place:Place, completion: @escaping (PlaceDeal) -> ()){
        let placeName = (place.nameAddress?.replacingOccurrences(of: " ", with: ""))!
        let dataRef = self.reference.child("Places").child(placeName).child("deal").child(place.deal?.uid ?? "--1")
        dataRef.observeSingleEvent(of: .value, with: {
            (snapshot) in
            if snapshot.value is NSNull{
                let deal = PlaceDeal()
                deal.count = 0
                deal.users = [:]
                completion(deal)
            }else{
                let dealDic = snapshot.value as! [String:Any]
                if let deal = Mapper<PlaceDeal>().map(JSON: dealDic) {
                    completion(deal)
                }
            }
        })
        
    }
    
    func useDeal(user: LocalUser, place:Place,time: String, completion: @escaping (Bool) -> ()){
        let placeName = (place.nameAddress?.replacingOccurrences(of: " ", with: ""))!
        let dataRef = self.reference.child("Places").child(placeName).child("deal").child(place.deal?.uid ?? "--1").child("users").child(user.id!).child("time")
        dataRef.setValue(time, withCompletionBlock: {
            (error,_) in
            if error != nil{
                completion(false)
            }else{
                completion(true)
            }
        })
        
    }
    
    func fetchUser(place:Place, completion: @escaping (Int,[String:Any]) -> ()){
        let placeName = (place.nameAddress?.replacingOccurrences(of: " ", with: ""))!
        let dataRef = self.reference.child("Places").child(placeName).child("deal").child(place.deal?.uid ?? "--1").child("users")
        dataRef.observe(.value, with: {
            (snapshot) in
            if snapshot.value is NSNull{
                let dic = [String:Any]()
                completion(0,dic)
            }else{
                let dic = snapshot.value as! [String:Any]
                completion(dic.count,dic)
            }
        })
    }
    
    func updateDeal(place:Place, count:Int){
        let placeName = (place.nameAddress?.replacingOccurrences(of: " ", with: ""))!
        let dataRef = self.reference.child("Places").child(placeName).child("deal").child(place.deal?.uid ?? "--1").child("useCount")
        dataRef.setValue(count)
    }
}
