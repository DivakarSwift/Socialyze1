//
//  AppDelegate.swift
//  Slide
//
//  Created by Salem Khan on 3/3/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import FacebookCore
import GoogleMaps
import UserNotifications

func doLog(_ items: Any...) {
    print(items)
}

var currentUser: User?

let appDelegate = UIApplication.shared.delegate as! AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        FIRApp.configure()
        IQKeyboardManager.sharedManager().enable = true
        GMSServices.provideAPIKey(GlobalConstants.APIKeys.googleMap)
        
        //SlydeLocationManager.shared.requestLocation()
        
        //UINavigationBar.appearance().barTintColor = UIColor(red: 18.0/255.0, green: 18.0/255.0, blue: 18.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().barTintColor = UIColor(red: 162.0/255.0, green: 11.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        //Requesting Authorization for User Interactions
        if #available(iOS 10.0, *) {
//            let center = UNUserNotificationCenter.current()
//            center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
//                // Enable or disable features based on authorization.
//                if !granted {
//                    print("Something went wrong")
//                }
//            }
//            center.getNotificationSettings(completionHandler: { (setting) in
//                if setting.authorizationStatus != .authorized {
//                    // Notifications not allowed
//                    print("Notification not allowed")
//                }
//            })
        } else {
            // Fallback on earlier versions
            application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert], categories: nil))
        }
        
        
        checkForLogin()
        
        return true
    }
    
    func checkForLogin() {
        
        let fbTokenNeedsRefrehsed = AccessToken.current?.expirationDate.timeIntervalSinceNow ?? 0 < 60*60*5
        
        
        if Authenticator.isUserLoggedIn, let loggedInAlready: Bool = GlobalConstants.UserDefaultKey.firstTimeLogin.value(), loggedInAlready && !fbTokenNeedsRefrehsed {
            let identifier = "mainNav"
            let userId = Authenticator.currentFIRUser?.uid
            
            UserService().getMe(withId: userId!, completion: { (user, error) in
                print(error ?? "Success get user detail")
                Authenticator.shared.user = user
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
                self.window?.rootViewController = vc
            })
        }else {
            let identifier = "LoginViewController"
            Authenticator.shared.logout()
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
            self.window?.rootViewController = vc
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppEventsLogger.activate(application)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return SDKApplicationDelegate.shared.application(app, open: url, options: options)
    }
    

    
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
        
    }
    
    @available(iOS 10.0, *)
    private func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
        print("Tapped in notification")
        
        // Must be called when finished
        completionHandler();
    }
    
    
    
    @available(iOS 10.0, *)
    private func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        print("Notification being triggered")
        
        if notification.request.identifier == Node.chatList.rawValue{
            
            completionHandler( [.alert,.sound,.badge])
            
        } else if notification.request.identifier == Node.matchList.rawValue{
            
            completionHandler( [.alert,.sound,.badge])
            
        }
    }
}

extension UIApplication {
    class func openAppSettings() {
        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
    }
}


