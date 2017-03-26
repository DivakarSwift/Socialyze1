//
//  FirebaseManager.swift
//  Slide
//
//  Created by bibek timalsina on 3/26/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FirebaseManager: NSObject {
    let reference = FIRDatabase.database().reference()
    
    func saveUser(user: User) {
        // reference.child("User").childByAutoId().updateChildValues(<#T##values: [AnyHashable : Any]##[AnyHashable : Any]#>, withCompletionBlock: <#T##(Error?, FIRDatabaseReference) -> Void#>)
    }
}
