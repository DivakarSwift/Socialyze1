//
//  Constants.swift
//  veda
//
//  Created by bibek timalsina on 3/8/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit
import FacebookCore

struct GlobalConstants {
    static private let ok = "Okay"
    static private let cancel = "Cancel"
    static private let error = "Error"
    
    struct APIKeys {
        static let googleMap = "AIzaSyDSWx1WCz8F_-4z0cjImhFpHEyQrvfIqyg"
        static let googlePlace = "AIzaSyCdk-1BuRcohP9f1IonO_G9wjc4CwDApG4"
        static let googleServerKey = "AAAA-DdoosY:APA91bHg4l8ikoFFfuK34WSvwGq-8iWb5Hr82jWfw49_NN3mTGU6HqvPWT4u5KvttApsSQ1SBYMqc716cbhJTGA-YKgZes475kWPycyqMFmejBiKvv-rt559Wu981C8sUO-noFciWfP8"
        static let googleLegacyServerKey = "AIzaSyBxoyciPQN6DQroc1zeLFu1dB_0CY3L4kU"
        static let googleSenderId = "1066081493702"
        
    }
    
    struct urls {
        static let itunesLink = "https://itunes.apple.com/us/app/socialyze/id1239571430"
    }
    
    struct UserDefaultKey {
        let key: String
        
        func set(value: Any?) {
            UserDefaults.standard.set(value, forKey: self.key)
        }
        
        func remove() {
            UserDefaults.standard.removeObject(forKey: self.key)
        }
        
        func value<T: Any>() -> T? {
            return UserDefaults.standard.value(forKey: self.key) as? T
        }
        
        static let userPhotosPermissionStatusFromFacebook = UserDefaultKey(key: "User_Photos_Permission_Status_From_Facebook")
        static let userFriendsPermissionStatusFromFacebook = UserDefaultKey(key: "User_Friends_Permission_Status_From_Facebook")
        static let userDOBPermissionStatusFromFacebook = UserDefaultKey(key: "User_Date_Of_Birth_Permission_Status_From_Facebook")
        static let taggableFriendsPermissionStatusFromFacebook = UserDefaultKey(key: "Taggable_Friends_Permission_Status_From_Facebook")
        static let userIdFromFacebook = UserDefaultKey(key: "User_ID_From_Facebook")
        static let fbAccessToken = UserDefaultKey(key: "Facebook_access_token".uppercased())
        static let firstTimeLogin = UserDefaultKey(key: "FIRST_TIME_APP_LOGIN")
    }
    
    struct Notification {
        let name: String
        
        var notification: NSNotification.Name {
            return NSNotification.Name(rawValue: self.name)
        }
        
        func fire(object: Any? = nil, userInfo: [AnyHashable : Any]? = nil) {
            NotificationCenter.default.post(name: notification, object: object, userInfo: userInfo)
        }
        
        static let locationAuthorizationStatusChanged = Notification(name: "Location_Authorization_Status_Changed".uppercased())
        static let newLocationObtained = Notification(name: "New_Location_Obtained".uppercased())
        static let locationUpdateError = Notification(name: "Location_Update_Error".uppercased())
    }
    
    struct Message {
        let title: String
        let message: String
        let okTitle: String
        let cancelTitle: String?
        var okAction: (()->())?
        var cancelAction: (()->())?
        
        static let oops = Message(title: error, message: "Oops! Something went wrong.", okTitle: ok, cancelTitle: nil, okAction: nil, cancelAction: nil)
        static let locationDenied = Message(title: "Warning", message: "Location is turned off for the app. Please enable permission in settings.", okTitle: ok, cancelTitle: nil, okAction: {
            let url = URL(string: UIApplicationOpenSettingsURLString)!
            UIApplication.shared.openURL(url)
        }, cancelAction: nil)
        static let userNotInPerimeter = Message(title: "Sorry", message: "Arrive at this place to start swiping", okTitle: "Okay", cancelTitle: nil, okAction: nil, cancelAction: nil)
    }
}
