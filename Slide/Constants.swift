//
//  Constants.swift
//  veda
//
//  Created by bibek timalsina on 3/8/17.
//  Copyright © 2017 veda. All rights reserved.
//

import UIKit

struct GlobalConstants {
    static private let ok = "Ok"
    static private let cancel = "Cancel"
    static private let error = "Error"
    
    struct APIKeys {
        static let googleMap = "AIzaSyDSWx1WCz8F_-4z0cjImhFpHEyQrvfIqyg"
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
        static let userIdFromFacebook = UserDefaultKey(key: "User_ID_From_Facebook")
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
        static let locationDenied = Message(title: "Warning", message: "Location is turned off for Slyde app. Please enable permission in settings.", okTitle: ok, cancelTitle: nil, okAction: {
            let url = URL(string: UIApplicationOpenSettingsURLString)!
            UIApplication.shared.openURL(url)
        }, cancelAction: nil)
        static let userNotInPerimeter = Message(title: "Error", message: "You need to be in the premises to perform checkin.", okTitle: "Ok", cancelTitle: nil, okAction: nil, cancelAction: nil)
    }
}
