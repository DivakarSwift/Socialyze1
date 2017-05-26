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

enum Node: String {
    case user
    case report
    case acceptList
    case matchList
    case profile
    case chatList
    case chat
    case checkIn
    case blockedUsers
    case Places
    case PlacesList
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

enum DeleteError: Error {
    case chat
    case checkIn
    case acceptList
    var localizedDescription: String {
        switch self {
        case .chat: return "Server error in deleting ChatList"
        case .checkIn: return "Server error in deleting checkIns"
        case .acceptList: return "Server error in deleting checkIns"
        }
    }
}

class FirebaseManager {
    
    init() {}
    
    private static let _reference = FIRDatabase.database().reference()
    private static let _storageReference = FIRStorage.storage().reference()
    private static let _storagee = FIRStorage.storage()
    
    let reference = FirebaseManager._reference
    let storageRef = FirebaseManager._storageReference
    let storagee = FirebaseManager._storagee
    
}
