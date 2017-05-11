//
//  Utilities.swift
//  Slide
//
//  Created by bibek on 5/3/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import UserNotifications


class Utilities: NSObject {

    class func returnAge(ofValue date: String, format :String) -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = NSTimeZone.system
        let birthday = dateFormatter.date(from: date)
        
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthday!, to: Date())
        let age = ageComponents.year!
        
        return age
    }
    
    class func fireChatNotification(chatItem :ChatItem) {
        
        UserService().getMe(withId: chatItem.userId!, completion: { user, error in
            
            if #available(iOS 10.0, *) {
                let content = UNMutableNotificationContent()
                content.title = "New Message from \(user?.profile.firstName)"
                content.body = chatItem.lastMessage ?? "check conversation"
                content.categoryIdentifier = "alarm"
                content.sound = UNNotificationSound.default()
                
                if let path = Bundle.main.path(forResource: "ladybird", ofType: "png") {
                    let url = URL(fileURLWithPath: path)
                    
                    do {
                        let attachment = try UNNotificationAttachment(identifier: "Socialize", url: url, options: nil)
                        content.attachments = [attachment]
                    } catch {
                        print("attachment not found.")
                    }
                }
                
                let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1.0, repeats: false)
                let request = UNNotificationRequest(identifier: Node.chatList.rawValue, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request){(error) in
                    
                    if (error != nil){
                        
                        print(error?.localizedDescription ?? "")
                    }
                }
                
            } else {
                
                // ios 9
                let notification = UILocalNotification()
                notification.fireDate = NSDate(timeIntervalSinceNow: 0) as Date
                notification.alertBody = chatItem.lastMessage ?? "check conversation"
                notification.alertAction = "New Message from \(user?.profile.firstName)"
                notification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.shared.scheduleLocalNotification(notification)
                
            }
        })
        
    }
    
    class func fireMatchedNotification(userId :String) {
        
        UserService().getMe(withId: userId, completion: { user, error in
            
            if #available(iOS 10.0, *) {
                let content = UNMutableNotificationContent()
                content.title = "New match"
                content.body = "New Match for \(user?.profile.firstName)"
                content.categoryIdentifier = "alarm"
                content.sound = UNNotificationSound.default()
                content.badge = (UIApplication.shared.applicationIconBadgeNumber + 1 ) as NSNumber?
                if let path = Bundle.main.path(forResource: "ladybird", ofType: "png") {
                    let url = URL(fileURLWithPath: path)
                    
                    do {
                        let attachment = try UNNotificationAttachment(identifier: "Socialize", url: url, options: nil)
                        content.attachments = [attachment]
                    } catch {
                        print("attachment not found.")
                    }
                }
                
                let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1.0, repeats: false)
                let request = UNNotificationRequest(identifier: Node.matchList.rawValue, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request){(error) in
                    
                    if (error != nil){
                        
                        print(error?.localizedDescription ?? "")
                    }
                }
                
            } else {
                
                // ios 9
                let notification = UILocalNotification()
                notification.fireDate = NSDate(timeIntervalSinceNow: 1) as Date
                notification.alertBody = "New Match for \(user?.profile.firstName)"
                notification.alertAction = "New Match"
                notification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.shared.scheduleLocalNotification(notification)
                
            }
        })
        
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


