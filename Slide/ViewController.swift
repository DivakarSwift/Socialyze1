//
//  ViewController.swift
//  Slide
//
//  Created by Salem Khan on 3/3/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit
import GooglePlaces
import FloatRatingView
import FacebookCore
import ObjectMapper
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func didSwipe(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == UISwipeGestureRecognizerDirection.right {
            performSegue(withIdentifier: "swipeToProfile", sender: nil)
        }
        if sender.direction == UISwipeGestureRecognizerDirection.left {
            performSegue(withIdentifier: "swipeToChat", sender: nil)
        }
    }
    
    @IBAction func returnFromSegueActions(sender: UIStoryboardSegue) {
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    lazy fileprivate var activityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: "ladybird.png")!
        let activityIndicator = CustomActivityIndicatorView(image: image)
        return activityIndicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.isNotificationPermissionGranted { (status) in
            switch status {
            case .authorized: break
            case .denied:
                self.alertWithOkCancel(message: "Would you like to know where your friends are going/checked in?", title: "Friends Notification", okTitle: "Cancel", cancelTitle: "Settings", okAction: nil, cancelAction: {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
                    } else {
                        // Fallback on earlier versions
                        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                    }
                    
                })
            case .notDetermined:
                self.alertWithOkCancel(message: "Would you like to know where your friends are going/checked in?", title: "Friends Notification", okTitle: "No thanks", cancelTitle: "Okay", okAction: nil, cancelAction: {
                    appDelegate.registerForNotification()
                })
            }
        }
        
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.center = self.view.center
        
        self.observe(selector: #selector(self.locationUpdated), notification: GlobalConstants.Notification.newLocationObtained)
        self.observe(selector: #selector(self.locationPermissionChanged), notification: GlobalConstants.Notification.locationAuthorizationStatusChanged)
        
        SlydeLocationManager.shared.delegate = self
        
        let padding: CGFloat = 2
        let layout = SnapchatLikeFlowLayout(unitHeight: 180, padding: padding)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        self.collectionView.setCollectionViewLayout(layout, animated: false)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.reloadData()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: #imageLiteral(resourceName: "profileicon"),
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(profileBtn)
        )
        
        //create a new button
        let leftButton = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        
        leftButton.kf.setImage(with: Authenticator.shared.user?.profile.images.first,  for: .normal, placeholder: #imageLiteral(resourceName: "profileicon"))
        leftButton.addTarget(self, action: #selector(profileBtn(_:)), for: .touchUpInside)
        leftButton.rounded()
        let leftBarButton = UIBarButtonItem(customView: leftButton)
        navigationItem.leftBarButtonItem = leftBarButton
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: #imageLiteral(resourceName: "friendsicon"),
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(chatBtn)
        )
        
        getPlaces()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Socialyze"
        UIApplication.shared.isStatusBarHidden = false
        self.navigationController?.navigationBar.isHidden = false
        SlydeLocationManager.shared.requestLocation()
    }
    
    var places = [Place]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    func getPlaces() {
        self.activityIndicator.startAnimating()
        PlaceService().getPlaces(completion: { (places) in
            self.activityIndicator.stopAnimating()
            self.places = places
            self.locationUpdated()
        }, failure: { error in
            self.activityIndicator.stopAnimating()
            self.alert(message: error.localizedDescription)
        })
    }
    
    func locationUpdated() {
        self.places = self.places.sorted(by: { (place1, place2) -> Bool in
            let place1Distance = SlydeLocationManager.shared.distanceFromUser(lat: place1.lat ?? 0, long: place1.long ?? 0) ?? 0
            let place2Distance = SlydeLocationManager.shared.distanceFromUser(lat: place2.lat ?? 0, long: place2.long ?? 0) ?? 0
            return place1Distance < place2Distance
        })
    }
    
    func profileBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! ProfileViewController
        controller.userId = Authenticator.currentFIRUser?.uid
        performSegue(withIdentifier: "swipeToProfile", sender: nil)
    }
    
    func chatBtn(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "swipeToChat", sender: nil)
    }
    
    func settingsBtn(_ sender: UIBarButtonItem) {
        let settingsViewController = UIViewController()
        self.navigationController?.pushViewController(settingsViewController, animated: true)
    }
    
    func placeId( nmbr:Int)  {
        let placeID = places[nmbr].placeId ?? ""
        let placesClinet = GMSPlacesClient()
        placesClinet.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            guard let place = place else {
                print("No place details for \(placeID)")
                return
            }
            
            print("Place name \(place.name)")
            print("Place address \(place.formattedAddress)")
            print("Place placeID \(place.placeID)")
            print("Place attributions \(place.rating)")
            let Str = String(place.rating)
            var userDefaultDict = [String: String]()
            userDefaultDict["rating"] = Str
            userDefaultDict["placeID"] = place.placeID
            userDefaultDict["address"] = place.formattedAddress
            UserDefaults.standard.set(userDefaultDict, forKey:place.placeID )
            UserDefaults.standard.synchronize()
            self.collectionView.reloadData()
        })
    }
}


extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let place = places[indexPath.row]
        let vc = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
        vc.place = place
        self.present(vc, animated: true, completion: nil)
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return places.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell
        
        
        cell.starLabel.text = ""
        if(UserDefaults.standard.object(forKey: places[indexPath.row].placeId ?? "") != nil){
            let starData = UserDefaults.standard.object(forKey: places[indexPath.row].placeId ?? "") as! NSDictionary
            print(starData)
            cell.floatRatingView.rating = Float(starData["rating"] as! String)!
            cell.starLabel.text = starData["rating"] as? String
            
        } else {
            if places[indexPath.row].placeId != "" {
                self.placeId( nmbr: indexPath.row)
            } else {
                cell.floatRatingView.isHidden = true
                cell.starLabel.isHidden = true
            }
        }
        
        switch indexPath.item % 10 {
        case 0,6: // large cells
            cell.nameLabel.font = UIFont.init(name: "Futura-Bold", size: 24)
            cell.bioNameLabel.font = UIFont.init(name: "Menlo-Bold", size: 23)
            
        case 1,2,5,7: // small cells
            cell.nameLabel.font = UIFont.init(name: "Verdana-Bold", size: 16)
            cell.bioNameLabel.font = UIFont.init(name: "ChalkboardSE-Bold", size: 15)
            
        default: // equal sized cells
            cell.nameLabel.font = UIFont.init(name: "Kailasa-Bold", size: 20)
            cell.bioNameLabel.font = UIFont.init(name: "Verdana-Bold", size: 19)
        }
        
        cell.starLabel.font = UIFont.systemFont(ofSize: 11)
        
        cell.ConfigureCell(place: places[indexPath.row])
        
        return cell
    }
}

//extension ViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
//        let spacing = layout.minimumInteritemSpacing
//        let width = collectionView.frame.width - spacing
//
//        let heightForSmallCell: CGFloat = 180
//
//        switch indexPath.item % 5 {
//        case 0,2: return CGSize(width: width/2, height: heightForSmallCell - spacing)
//        default: return CGSize(width: width/2, height: heightForSmallCell * 2)
//        }
//    }
//}

//extension ViewController : TRMosaicLayoutDelegate {
//
//    func collectionView(_ collectionView:UICollectionView, mosaicCellSizeTypeAtIndexPath indexPath:IndexPath) -> TRMosaicCellType {
//        switch indexPath.item % 5 {
//        case 0,1: return .small
//        default: return .big
//        }
//
//        // I recommend setting every third cell as .Big to get the best layout
//        // return indexPath.item % 3 == 0 ? TRMosaicCellType.big : TRMosaicCellType.small
//    }
//
//    func collectionView(_ collectionView:UICollectionView, layout collectionViewLayout: TRMosaicLayout, insetAtSection:Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 4, left: 1, bottom: 4, right: 2)
//    }
//
//    func heightForSmallMosaicCell() -> CGFloat {
//        return 180
//    }
//

//}


extension ViewController: SlydeLocationManagerDelegate {
    func locationObtained() {
        
        
    }
    
    func locationPermissionChanged() {
        
        if SlydeLocationManager.shared.isDenied {
            self.alert(message: GlobalConstants.Message.locationDenied)
        }
    }
    
    func locationObtainError() {
        
        
    }
}

//extension ViewController {
//
//    @available(iOS 10.0, *)
//    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//
//        print("Tapped in notification")
//        let userInfo = response.notification.request.content.userInfo
//
//        if let userData = userInfo["user"], let chatData = userInfo["chat"] {
//            let userJson = JSON(userData)
//            let chatJson = JSON(chatData)
//
//            if let user: LocalUser = userJson.map(), let   chatItem:ChatItem = chatJson.map() {
//                Utilities.openChat(user: user, chatItem: chatItem)
//            }
//        }
//    }
//
//    //This is key callback to present notification while the app is in foreground
//    @available(iOS 10.0, *)
//    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//
//
//        print(notification.request.content.userInfo)
//
//        print("Notification being triggered")
//        //You can either present alert ,sound or increase badge while the app is in foreground too with ios 10
//        //to distinguish between notifications
//        if notification.request.identifier == Node.chatList.rawValue {
//            completionHandler( [.alert,.sound,.badge])
//        }
//        else if  notification.request.identifier ==  Node.matchList.rawValue {
//            completionHandler( [.alert,.sound,.badge])
//        }
//    }

//}

