//
//  Utilities.swift
//  Slide
//
//  Created by bibek on 5/3/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import Foundation
import FacebookCore
import UIKit
import Kingfisher
import UserNotifications
import SwiftyJSON


class Utilities: NSObject {
    
    class func returnAge(ofValue date: String, format :String) -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.current
        let birthday = dateFormatter.date(from: date)
        
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthday!, to: Date())
        let age = ageComponents.year!
        
        return age
    }
    
    class func fireChatNotification(_ viewController: UIViewController, chatItem :ChatItem) {
        
        UserService().getMe(withId: chatItem.userId!, completion: { user, error in
            var title = "New Message"
            if let name = user?.profile.firstName {
                title = name
            }
            let body = chatItem.lastMessage ?? "Check conversation"
            var userInfo:[String:Any] = [:]
            userInfo["chat"] = chatItem.toJSON()
            userInfo["user"] = user?.toJSON()
            localNotif(withTitle: title, body: body,userInfo: userInfo, viewController: viewController)
        })
    }
    
    class func fireMatchedNotification(_ viewController: UIViewController, userId :String) {
        
        UserService().getMe(withId: userId, completion: { user, error in
            let title = "New match"
            var body = "New Match. Check Connections"
            if let name = user?.profile.firstName {
                body = "New Match from \(name)"
            }
            localNotif(withTitle: title, body: body, viewController: viewController)
        })
        
    }
    
    class func firePushNotification(with parameters:Dictionary<String, Any>, completion: (() -> ())? = nil) {
        //create the url with URL
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
        
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("key=\(GlobalConstants.APIKeys.googleLegacyServerKey)", forHTTPHeaderField: "Authorization")
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            completion?()
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(json)
                }
                
            } catch let error {
                
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    class func openChat(user: LocalUser, chatItem :ChatItem) {
        let accesstoken = AccessToken.current
        //        if let _ = accesstoken?.authenticationToken {
        print("Facebook Access-token available")
        // redirect to required location
        
        let vc = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        
        vc.fromMatch = true
        vc.chatItem = chatItem
        vc.chatUser = user
        vc.chatUserName = user.profile.firstName ?? ""
        vc.chatOppentId = user.id
        
        let nav = UINavigationController(rootViewController: vc)
        appDelegate.window?.rootViewController = nav
        //            if let nav =  self.navigationController {
        //                nav.pushViewController(vc, animated: true)
        //            } else {
        //                self.present(vc, animated: true, completion: {
        //
        //                })
        //            }
        
        //        } else {
        //            print("Facebook Access-token not found")
        //            appDelegate.checkForLogin()
        //        }
    }
    
    class func openMatch() {
        let vc = UIStoryboard(name: "Matches", bundle: nil).instantiateViewController(withIdentifier: "MatchesViewController") as! MatchesViewController
        let nav = UINavigationController(rootViewController: vc)
        
        appDelegate.window?.rootViewController = nav
        //        self.present(nav, animated: true, completion: nil)
    }
    
    class func openMain() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainNav")
        appDelegate.window?.rootViewController = vc
    }
    
    class func openLogin() {
        let identifier = "LoginViewController"
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
        appDelegate.window?.rootViewController = vc
    }
    
    class func localNotif(withTitle title: String, body:String, userInfo: [String:Any]? = nil, viewController: UIViewController) {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            if let userInfo = userInfo {
                content.userInfo = userInfo
            }
            content.categoryIdentifier = "alarm"
            content.sound = UNNotificationSound.default()
            
            //                let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 5.0, repeats: false)
            
            //Setting time for notification trigger
            let date = Date(timeIntervalSinceNow: 1)
            let dateCompenents = Calendar.current.dateComponents([.year,.month,.day ,.hour,.minute,.second], from: date)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateCompenents, repeats: false)
            
            let request = UNNotificationRequest(identifier: Node.chatList.rawValue, content: content, trigger: trigger)
            
            center.delegate = viewController
            center.add(request){(error) in
                
                if (error != nil){
                    
                    print(error?.localizedDescription ?? "")
                }
            }
            
        } else {
            
            // ios 9
            let notification = UILocalNotification()
            notification.fireDate = NSDate(timeIntervalSinceNow: 0) as Date
            notification.alertBody = body
            notification.alertAction = title
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.shared.scheduleLocalNotification(notification)
            
        }
    }
    
    class func timeAgoSince(_ date: Date) -> String {
        
        let calendar = Calendar.current
        let now = Date()
        let unitFlags: NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfYear, .month, .year]
        let components = (calendar as NSCalendar).components(unitFlags, from: date, to: now, options: [])
        
        if let year = components.year, year >= 2 {
            return "\(year)y"
        }
        
        if let year = components.year, year >= 1 {
            return "1y"
        }
        
        if let month = components.month, month >= 2 {
            return "\(month)M"
        }
        
        if let month = components.month, month >= 1 {
            return "1M"
        }
        
        if let week = components.weekOfYear, week >= 2 {
            return "\(week)w"
        }
        
        if let week = components.weekOfYear, week >= 1 {
            return "1w"
        }
        
        if let day = components.day, day >= 2 {
            return "\(day)d"
        }
        
        if let day = components.day, day >= 1 {
            return "1d"
        }
        
        if let hour = components.hour, hour >= 2 {
            return "\(hour)h"
        }
        
        if let hour = components.hour, hour >= 1 {
            return "1h"
        }
        
        if let minute = components.minute, minute >= 2 {
            return "\(minute)m"
        }
        
        if let minute = components.minute, minute >= 1 {
            return "1m"
        }
        
        if let second = components.second, second >= 3 {
            return "\(second)s"
        }
        
        return "1s"
        
    }
    
    class func returnDate(dateValue: Date, timeZone:String? = nil) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
        if let zone = timeZone {
            dateFormatter.timeZone = TimeZone(identifier: zone)
        }
        let datee = dateFormatter.string(from: dateValue)
        return datee
    }
    
    class func returnDate(ofValue date: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
        let datee = dateFormatter.date(from: date)
        return datee
    }
    
}

struct MyIndicator: Indicator {
    let view: UIView = CustomActivityIndicatorView(image: #imageLiteral(resourceName: "ladybird.png"))
    let indicatorView = CustomActivityIndicatorView(image: #imageLiteral(resourceName: "ladybird.png"))
    func startAnimatingView() { indicatorView.startAnimating() }
    func stopAnimatingView() { indicatorView.stopAnimating() }
    
    init() {
        view.backgroundColor = .red
        view.addSubview(indicatorView)
    }
}


