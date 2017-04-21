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
import CoreData
import GooglePlaces
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
        GMSPlacesClient.provideAPIKey(GlobalConstants.APIKeys.API_KEY)
        GMSServices.provideAPIKey(GlobalConstants.APIKeys.API_KEY)
        SlydeLocationManager.shared.requestLocation()
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 18.0/255.0, green: 18.0/255.0, blue: 18.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        checkForLogin()
        
        return true
    }
    
    func checkForLogin() {
        
        let fbTokenNeedsRefrehsed = AccessToken.current?.expirationDate.timeIntervalSinceNow ?? 0 < 60*60*5
        
        
        if Authenticator.isUserLoggedIn, let loggedInAlready: Bool = GlobalConstants.UserDefaultKey.firstTimeLogin.value(), loggedInAlready && !fbTokenNeedsRefrehsed {
            let identifier = "mainNav"
            let userId = Authenticator.currentFIRUser?.uid
            
            UserService().getUser(withId: userId!, completion: { (user, error) in
                print(error)
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
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
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

    
}

