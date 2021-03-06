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
import SwiftyJSON
import FacebookCore
import GoogleMaps
import GooglePlaces
import CoreData
import UserNotifications

func doLog(_ items: Any...) {
    print(items)
}

var currentUser: User?

let appDelegate = UIApplication.shared.delegate as! AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        //        IQKeyboardManager.sharedManager().shouldShowTextFieldPlaceholder = false
        //        IQKeyboardManager.sharedManager().shouldHidePreviousNext = false
        
        GMSServices.provideAPIKey(GlobalConstants.APIKeys.googleMap)
        GMSPlacesClient.provideAPIKey(GlobalConstants.APIKeys.googlePlace)
        GMSServices.provideAPIKey(GlobalConstants.APIKeys.googlePlace)
        
        //SlydeLocationManager.shared.requestLocation()
        
        //UINavigationBar.appearance().barTintColor = UIColor(red: 18.0/255.0, green: 18.0/255.0, blue: 18.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().barTintColor = UIColor(red: 162.0/255.0, green: 11.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        application.isStatusBarHidden = false
        
        //        let vc = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "EventDetailViewControllerWithDeal")
        //        self.window?.rootViewController = vc
        checkForLogin()
        
        return true
    }
    
    func registerForNotification() {
        UserDefaults.standard.set(true, forKey: "NOTIFICATION_AUTHORIZATION_ASKED")
        let application = UIApplication.shared
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let setting = UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil)
            application.registerUserNotificationSettings(setting)
        }
        application.registerForRemoteNotifications()
    }
    
    enum NotificationStatus {
        case denied, notDetermined, authorized
    }
    
    func isNotificationPermissionGranted(completion: @escaping (NotificationStatus)->()) {
        if #available(iOS 10.0, *) {
            let current = UNUserNotificationCenter.current()
            current.getNotificationSettings(completionHandler: { (settings) in
                if settings.authorizationStatus == .notDetermined {
                    completion(.notDetermined)
                    // Notification permission has not been asked yet, go for it!
                }
                
                if settings.authorizationStatus == .denied {
                    // Notification permission was previously denied, go to settings & privacy to re-enable
                    completion(.denied)
                }
                
                if settings.authorizationStatus == .authorized {
                    // Notification permission was already granted
                    completion(.authorized)
                }
            })
        } else {
            // Fallback on earlier versions
            if UIApplication.shared.isRegisteredForRemoteNotifications {
                completion(.authorized)
            }else {
                if UserDefaults.standard.bool(forKey: "NOTIFICATION_AUTHORIZATION_ASKED") {
                    completion(.denied)
                }else {
                    completion(.notDetermined)
                }
            }
        }
    }
    
    
    func checkForLogin() {
        
        GlobalConstants.UserDefaultKey.loggedInForCurrentSession.set(value: false)
        
        AccessToken.current = FacebookService.shared.getAccessToken()
        let expiryTime = AccessToken.current?.expirationDate.timeIntervalSinceNow
        let fbTokenNeedsRefrehsed =  (expiryTime ?? 0) < 60*60*5
        
        if Authenticator.isUserLoggedIn, let loggedInAlready: Bool = GlobalConstants.UserDefaultKey.firstTimeLogin.value(), loggedInAlready && !fbTokenNeedsRefrehsed {
            if let userSawTutorial: Bool = GlobalConstants.UserDefaultKey.userSawTutorial.value(), userSawTutorial {
                
                self.showLoading()
                
                let userId = Authenticator.currentFIRUser?.uid
                
                UserService().getMe(withId: userId!, completion: { (user, error) in
                    print(error ?? "Success get user detail")
                    if !(user?.isCreatedAfterFbImageDownloadToStorage ?? false) {
                        Authenticator.shared.logout()
                        return
                    }
                    Authenticator.shared.user = user
                    if let user = Authenticator.shared.user, let fcmToken = Messaging.messaging().fcmToken {
                        UserService().addGoogleToken(user: user, fcmToken: fcmToken)
                    }
                    GlobalConstants.UserDefaultKey.loggedInForCurrentSession.set(value: true)
                    self.showMain()
                })
            }else {
                self.showTutorial()
            }
        } else {
            self.showLogin()
        }
    }
    
    func showMain() {
//        let identifier = "mainNav"
//        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
        let mainPage = MainPageViewController()
        self.window?.rootViewController = mainPage
    }
    
    func showLogin() {
        let identifier = "LoginViewController"
        Authenticator.shared.logout()
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
        self.window?.rootViewController = vc
    }
    
    func showTutorial() {
        let identifier = "TutorialViewController"
        let vc = UIStoryboard(name: "Tutorial", bundle: nil).instantiateViewController(withIdentifier: identifier)
        self.window?.rootViewController = vc
    }
    
    func showLoading() {
        let identifier = "LoadingViewController"
        let vc = UIStoryboard(name: "Loading", bundle: nil).instantiateViewController(withIdentifier: identifier)
        self.window?.rootViewController = vc
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppEventsLogger.activate(application)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return SDKApplicationDelegate.shared.application(app, open: url, options: options)
    }
    
    
    // MARK: - Core Data stack
    
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Places")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if #available(iOS 10.0, *) {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        //         Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        if let userData = userInfo["user"], let chatData = userInfo["chat"] {
            let userJson = JSON(userData)
            print(userJson)
            let chatJson = JSON(chatData)
            print(chatJson)
            
            if let user: LocalUser = userJson.map(), let   chatItem:ChatItem = chatJson.map() {
                Utilities.openChat(user: user, chatItem: chatItem)
            }
        } else {
            Utilities.openMatch()
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        //         Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        guard let isLoggedInSession: Bool = GlobalConstants.UserDefaultKey.loggedInForCurrentSession.value(), isLoggedInSession  else {
            Utilities.openLogin()
            return
        }
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        // Print full message.
        if let userData = userInfo["user"] {
            if let chatData = userInfo["chat"] {
                let userJson = JSON(userData)
                print(userJson)
                let chatJson = JSON(chatData)
                print(chatJson)
                
                if let user: LocalUser = userJson.map(), let   chatItem:ChatItem = chatJson.map() {
                    Utilities.openChat(user: user, chatItem: chatItem)
                }
            }else {
                Utilities.openMatch()
            }
        } else {
            Utilities.openMain()
        }
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        Messaging.messaging().apnsToken = deviceToken
        
        let token = Messaging.messaging().fcmToken
        print("FCM token: \(token ?? "")")
        if let user = Authenticator.shared.user, let token = token {
            UserService().addGoogleToken(user: user, fcmToken: token)
        }
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
        
    }
    
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        //        if let userData = userInfo["user"], let chatData = userInfo["chat"] {
        //            let userJson = JSON(userData)
        //            let chatJson = JSON(chatData)
        //
        //            if let user: LocalUser = userJson.map(), let   chatItem:ChatItem = chatJson.map() {
        //                Utilities.openChat(user: user, chatItem: chatItem)
        //            } else {
        //                Utilities.openMatch()
        //            }
        //        }
        
        // Change this to your preferred presentation option
        completionHandler([.alert,.badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        guard let isLoggedInSession: Bool = GlobalConstants.UserDefaultKey.loggedInForCurrentSession.value(), isLoggedInSession  else {
            Utilities.openLogin()
            return
        }
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        // Print full message.
        if let userData = userInfo["user"] {
            if let chatData = userInfo["chat"] {
                let userJson = JSON(userData)
                print(userJson)
                let chatJson = JSON(chatData)
                print(chatJson)
                
                if let user: LocalUser = userJson.map(), let   chatItem:ChatItem = chatJson.map() {
                    Utilities.openChat(user: user, chatItem: chatItem)
                }
            }else {
                Utilities.openMatch()
            }
        } else {
            Utilities.openMain()
        }
        
        completionHandler()
    }
    
    
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        if let user = Authenticator.shared.user {
            UserService().addGoogleToken(user: user, fcmToken: fcmToken)
        }
    }
    // [END refresh_token]
    
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
    
    
}

extension UIApplication {
    class func openAppSettings() {
        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
    }
}
