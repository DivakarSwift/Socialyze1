//
//  FirebaseManager.swift
//  Slide
//
//  Created by bibek timalsina on 3/26/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

typealias CallBackWithSuccessError = (_: Bool, _: Error?) -> Void

enum Node: String {
    case user
    case report
    case acceptList
    case matchList
    case profile
    case chatList
    case chat
}

enum FirebaseManagerError: Error {
    case noUserFound
    case noDataFound
    var localizedDescription: String {
        switch self {
        case .noUserFound: return "No more users."
        case .noDataFound: return "No data found."
        }
    }
}

class FirebaseManager {
    
    init() {}
    
    private static let _reference = FIRDatabase.database().reference()
    private static let _storageReference = FIRStorage.storage().reference()
    
    let reference = FirebaseManager._reference
    let storageRef = FirebaseManager._storageReference
    
}
