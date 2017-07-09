//
//  DealService.swift
//  Slide
//
//  Created by Bibek on 7/8/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import Foundation
import Firebase

class DealService{
    
    func getDealInPlace(place:Place , completion: @escaping ([String:Any]) -> ()){
        let placeName = (place.nameAddress?.replacingOccurrences(of: " ", with: ""))!
        let dataRef = FirebaseManager().reference.child("Places").child(placeName).child("deal")
        dataRef.observe(.value, with: {
            (snapshot) in
            if snapshot.value is NSNull{
                
            }else{
            let dealDic = snapshot.value as! [String:Any]
            completion(dealDic)
          }  
        })
    
    }
    
    func useDeal(user : User, place:Place,time: String, completion: @escaping (Bool) -> ()){
        let placeName = (place.nameAddress?.replacingOccurrences(of: " ", with: ""))!
        let dataRef = FirebaseManager().reference.child("Places").child(placeName).child("deal").child("Users").child(user.uid).child("time")
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
        let dataRef = FirebaseManager().reference.child("Places").child(placeName).child("deal").child("Users")
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
        let dataRef = FirebaseManager().reference.child("Places").child(placeName).child("deal").child("Use Count")
        dataRef.setValue(count)
    }
}
