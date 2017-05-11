//
//  ViewController.swift
//  Slide
//
//  Created by Salem Khan on 3/3/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit
import UserNotifications

struct Place {
    let nameAddress: String
    let mainImage: UIImage
    let secondImage: UIImage?
    let lat: Double
    let long: Double
    let size: Int // custom = 0, small = 1, medium = 2, large = 3
    let early: Int // early check-in, 0 for no, 1 for yes
}

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        SlydeLocationManager.shared.requestLocation()
        
        let mosaicLayout = TRMosaicLayout()
        self.collectionView?.collectionViewLayout = mosaicLayout
        mosaicLayout.delegate = self
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Profile",
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(profileBtn)
            
        )
        
        setupPlaces()
                
        ChatService.shared.observeChatList(completion: { chatItem, error in
            if let data = chatItem {
                self.fireChatNotification(chatItem: data)
            } else {
                
            }
        })
        ChatService.shared.observeMatchList(completion: { userId, error in
            if let data = userId {
                self.fireMatchedNotification(userId: data)
            } else {
                
            }
        })
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Explore Columbus"
        self.navigationController?.navigationBar.isHidden = false
    }
    
    var places = [Place]()
    
    func setupPlaces() {
        
        // Ohio State University
        
        places.append(Place.init(nameAddress: "RPAC, Ohio State", mainImage: #imageLiteral(resourceName: "RPAC1-yelp"), secondImage: nil, lat: 39.999643, long: -83.018489, size: 3, early: 0))
        
        places.append(Place.init(nameAddress: "The Union, Ohio State", mainImage: #imageLiteral(resourceName: "Union"), secondImage: nil, lat: 39.997957, long: -83.0085650, size: 3, early: 0))
        
        //places.append(Place.init(nameAddress: "18th Ave Library, Ohio State", mainImage: #imageLiteral(resourceName: "18thAvelibrary"), secondImage: nil, lat: 0, long: 0, size: 2, early: 0))
        
        places.append(Place.init(nameAddress: "Thompson Library, Ohio State", mainImage: #imageLiteral(resourceName: "ThompsonLibrary"), secondImage: #imageLiteral(resourceName: "ThompsonLibrary1"), lat: 39.999346, long: -83.014863, size: 2, early: 0))
        
        // Other Universities
        
        places.append(Place.init(nameAddress: "Columbus State CC ", mainImage: #imageLiteral(resourceName: "ColumbusStateCC"), secondImage: nil, lat:39.969207, long: -82.987190, size: 0, early: 0))//polygon
        
        //places.append(Place.init(nameAddress: "Capital University", mainImage: #imageLiteral(resourceName: "CapitalUni"), secondImage: nil, lat: 39.955322, long: -82.938515, size: 0, early: 0)) // polygon

        // Towns and Large Areas
        
        //places.append(Place.init(nameAddress: "Downtown, Columbus", mainImage: #imageLiteral(resourceName: "DowntownColumbus "), secondImage: nil, lat: 0, long: 0, size: 2, early: 0)) // polygon
        
        places.append(Place.init(nameAddress: "Short North", mainImage: #imageLiteral(resourceName: "ShortNorth"), secondImage: nil, lat: 39.987237, long: -83.008599, size: 0, early: 0)) // polygon
        
        places.append(Place.init(nameAddress: "German Village", mainImage: #imageLiteral(resourceName: "germanvillage"), secondImage: nil, lat: 39.952666, long: -82.997876, size: 0, early: 0)) // polygon
        
        // Centers and Arenas
        
        //places.append(Place.init(nameAddress: "Ohio Expo Center", mainImage: #imageLiteral(resourceName: "ohioexpocenter"), secondImage: nil, lat: 40.002574, long: -82.990648 ,size: 4, early: 0))
        
        places.append(Place.init(nameAddress: "Mapfre stadium", mainImage: #imageLiteral(resourceName: "mapfre-stadium"), secondImage: nil, lat: 40.009521, long: -82.991087, size: 4, early: 0))
        
        places.append(Place.init(nameAddress: "Nationwide Arena", mainImage: #imageLiteral(resourceName: "NationwideArena"), secondImage: #imageLiteral(resourceName: "NationWideArena1"), lat: 39.969274, long: -83.005992, size: 4, early: 1))
        
        //places.append(Place.init(nameAddress: "Columbus Convention Center", mainImage: #imageLiteral(resourceName: "GreaterConventionCenter"), secondImage: nil, lat: 39.970323, long: -83.000803, size: 4, early: 0))
        
        places.append(Place.init(nameAddress: "Newport Music", mainImage: #imageLiteral(resourceName: "NewportMusicHall-yelp"), secondImage: nil, lat: 39.997719, long: -83.007267, size: 1, early: 1))
        
        places.append(Place.init(nameAddress: "Express Live!", mainImage: #imageLiteral(resourceName: "OriginalBug"), secondImage: nil, lat: 39.969865, long: -83.009947, size: 2, early: 1))
        
        places.append(Place.init(nameAddress: "Schottenstein Music Center", mainImage: #imageLiteral(resourceName: "OriginalBug"), secondImage: nil, lat: 40.007549, long: -83.025020, size: 4, early: 1))
        
        places.append(Place.init(nameAddress: "Huntington Park", mainImage: #imageLiteral(resourceName: "OriginalBug"), secondImage: nil, lat: 39.968675, long: -83.010920, size: 4, early: 1))
        
        // Bars & Clubs
        
        places.append(Place.init(nameAddress: "Ugly Tuna", mainImage: #imageLiteral(resourceName: "UglyTuna "), secondImage: nil, lat: 39.993811, long: -83.006448, size: 2, early: 0))
        
        places.append(Place.init(nameAddress: "Short North Pint House", mainImage: #imageLiteral(resourceName: "Pinthouse"), secondImage: nil, lat: 39.978301, long: -83.003153, size: 2, early: 0))
        
        places.append(Place.init(nameAddress: "Axis Nightclub", mainImage: #imageLiteral(resourceName: "Axisnightclub"), secondImage: nil, lat: 39.978057, long: -83.004419, size: 2, early: 0))
        
        //places.append(Place.init(nameAddress: "World of Beer", mainImage: #imageLiteral(resourceName: "WorldofBeer3"), secondImage: #imageLiteral(resourceName: "WorldofBeer1"), lat: 0, long: 0, size: 1, early: 0))
        
        places.append(Place.init(nameAddress: "Park Street Cantina", mainImage: #imageLiteral(resourceName: "ParkStreetCantina"), secondImage: #imageLiteral(resourceName: "ParkStreetCantina1"), lat: 39.972233, long: -83.005100, size: 1, early: 0))
        
        //places.append(Place.init(nameAddress: "Char Bar", mainImage: #imageLiteral(resourceName: "Charbar"), secondImage: nil, lat: 39.971304, long: -83.002569, size: 2, early: 0))
        
        places.append(Place.init(nameAddress: "Out R Inn", mainImage: #imageLiteral(resourceName: "OutRInn"), secondImage: nil, lat: 40.005088, long: -83.008432, size: 2, early: 0))
        
        places.append(Place.init(nameAddress: "Midway on High", mainImage: #imageLiteral(resourceName: "MidwayonHigh-Yelp"), secondImage: nil, lat: 39.997669, long: -83.007395, size: 2, early: 0))
        
        places.append(Place.init(nameAddress: "Bakersfield Short North", mainImage: #imageLiteral(resourceName: "Starbucks1"), secondImage: nil, lat: 39.977321, long: -83.003828, size: 1, early: 0))
        
        //places.append(Place.init(nameAddress: "Chumley's", mainImage: #imageLiteral(resourceName: "OriginalBug"), secondImage: nil, lat: <#T##Double#>, long: <#T##Double#>, size: <#T##Int#>, early: <#T##Int#>))
        
        places.append(Place.init(nameAddress: "Ethyl & Tank", mainImage: #imageLiteral(resourceName: "OriginalBug"), secondImage: nil, lat: 39.997661, long: -83.006919, size: 1, early: 0))
        
        places.append(Place.init(nameAddress: "The Big Bar & Grill", mainImage: #imageLiteral(resourceName: "OriginalBug"), secondImage: nil, lat: 39.997343, long: -83.007020, size: 2, early: 0))
        
        places.append(Place.init(nameAddress: "The O Patio & Pub", mainImage: #imageLiteral(resourceName: "OriginalBug"), secondImage: nil, lat: 40.000295, long: -83.007737, size: 2, early: 0))
        
        places.append(Place.init(nameAddress: "The Library", mainImage: #imageLiteral(resourceName: "OriginalBug"), secondImage: nil, lat: 40.006640, long: -83.009561, size: 1, early: 0))
        
        places.append(Place.init(nameAddress: "Little Bar", mainImage: #imageLiteral(resourceName: "OriginalBug"), secondImage: nil, lat: 40.006840, long: -83.009729, size: 2, early: 0))
        
        //places.append(Place.init(nameAddress: "Cazuelas Grill", mainImage: #imageLiteral(resourceName: "OriginalBug"), secondImage: nil, lat: 40.009699, long: -83.010323, size: 2, early: 0))
        
        places.append(Place.init(nameAddress: "Bullwinkles", mainImage: #imageLiteral(resourceName: "OriginalBug"), secondImage: nil, lat: 39.998463, long: -83.007246, size: 2, early: 0))
        
        places.append(Place.init(nameAddress: "Fourth Street Bar & Grill", mainImage: #imageLiteral(resourceName: "OriginalBug"), secondImage: nil, lat: 40.000335, long: -82.998396, size: 1, early: 0))
        
        places.append(Place.init(nameAddress: "Lucky's Stout House", mainImage: #imageLiteral(resourceName: "OriginalBug"), secondImage: nil, lat: 39.992392, long: -83.006889, size: 1, early: 0))
        
        // Coffee Shops
        
        //places.append(Place.init(nameAddress: "Starbucks Coffee (across Union)", mainImage: #imageLiteral(resourceName: "Starbucks1"), secondImage: nil, lat: 39.999009, long: -83.007331, size: 1, early: 0))
        
        places.append(Place.init(nameAddress: "Fox in the Snow Cafe", mainImage: #imageLiteral(resourceName: "FoxandSnowCafe"), secondImage: nil, lat: 39.984228, long: -82.999388, size: 2, early: 0))
        
        // Shopping Malls
        
        //places.append(Place.init(nameAddress: "Polaris Fashion Place", mainImage: #imageLiteral(resourceName: "PolarisFashionPlace"), secondImage: #imageLiteral(resourceName: "PolarisFashionPlace1-yelp"), lat: 40.145472, long: -82.981640, size: 0, early: 0))
        
        places.append(Place.init(nameAddress: "Easton Town Center", mainImage: #imageLiteral(resourceName: "EastonTownCenter"), secondImage: nil, lat: 40.050716, long: -82.915363, size: 0, early: 0)) // polygon
        
        // Restaurants
        
        //places.append(Place.init(nameAddress: "Chipotle (across Union)", mainImage: #imageLiteral(resourceName: "Chipotle"), secondImage: nil, lat: 0, long: 0, size: 1, early: 0))
        
        places.append(Place.init(nameAddress: "Condado Tacos", mainImage: #imageLiteral(resourceName: "OriginalBug"), secondImage: nil, lat: 39.987486, long: -83.005805, size: 2, early: 0))
        
        self.collectionView.reloadData()
    
    }
    
    func profileBtn(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! ProfileViewController
        controller.userId = Authenticator.currentFIRUser?.uid
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func settingsBtn(_ sender: UIBarButtonItem) {
        let settingsViewController = UIViewController()
        self.navigationController?.pushViewController(settingsViewController, animated: true)
        
    }
    
}

extension ViewController:UNUserNotificationCenterDelegate{
    
    
    
    func fireChatNotification(chatItem :ChatItem) {
        
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
    
    func fireMatchedNotification(userId :String) {
        
        UserService().getMe(withId: userId, completion: { user, error in
            
            if #available(iOS 10.0, *) {
                let content = UNMutableNotificationContent()
                content.title = "New match"
                content.body = "New Match for \(user?.profile.firstName)"
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
    
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("Tapped in notification")
    }
    
    //This is key callback to present notification while the app is in foreground
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("Notification being triggered")
        //You can either present alert ,sound or increase badge while the app is in foreground too with ios 10
        //to distinguish between notifications
        if notification.request.identifier == Node.chatList.rawValue{
            
            completionHandler( [.alert,.sound,.badge])
            
        } else if notification.request.identifier == Node.matchList.rawValue{
            
            completionHandler( [.alert,.sound,.badge])
            
        }
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let place = places[indexPath.row]
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlaceDetailViewController") as! PlaceDetailViewController
        vc.place = place
        self.navigationController?.pushViewController(vc, animated: true)
       // self.performSegue(withIdentifier: "categoryDetail", sender: self)
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return places.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        (cell.viewWithTag(1) as! UIImageView).image = places[indexPath.row].mainImage
        (cell.viewWithTag(2) as! UILabel).text = places[indexPath.row].nameAddress
        return cell
    }
}

extension ViewController : TRMosaicLayoutDelegate {
    
    func collectionView(_ collectionView:UICollectionView, mosaicCellSizeTypeAtIndexPath indexPath:IndexPath) -> TRMosaicCellType {
//        if indexPath.item != 0 {
//            if (indexPath.item + 1 - 0) / 3 == 0 {
//                return .small
//            }else if (indexPath.item + 1 - 1) / 3 == 0  {
//                return .small
//            }else if (indexPath.item + 1 - 2) / 3 == 0  {
//                return .small
//            }
//        }
        return indexPath.item % 3 == 0 ? TRMosaicCellType.big : TRMosaicCellType.small
    }
    
    func collectionView(_ collectionView:UICollectionView, layout collectionViewLayout: TRMosaicLayout, insetAtSection:Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.5, left: 0.5, bottom: 0.5, right: 0.5)
    }
    
    func heightForSmallMosaicCell() -> CGFloat {
        return 200
    }
}
