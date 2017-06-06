//
//  ViewController.swift
//  Slide
//
//  Created by Salem Khan on 3/3/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit
import UserNotifications
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
        
        
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.center = self.view.center
        
        SlydeLocationManager.shared.requestLocation()
        SlydeLocationManager.shared.delegate = self
        if SlydeLocationManager.shared.isAuthorized {
            if #available(iOS 10.0, *) {
                let center = UNUserNotificationCenter.current()
                center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                    // Enable or disable features based on authorization.
                    if !granted {
                        DispatchQueue.main.async {
                            self.alertWithOkCancel(message: "Notification not Allowed. Would you like to open Setting?", title: "Alert", okTitle: "Open Setting", cancelTitle: "Dismiss", okAction: {
                                UIApplication.openAppSettings()
                            }, cancelAction: nil)
                        }
                    }
                }
            }
        }
        
        let mosaicLayout = TRMosaicLayout()
        self.collectionView?.collectionViewLayout = mosaicLayout
        mosaicLayout.delegate = self
        
        self.collectionView.reloadData()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: #imageLiteral(resourceName: "profileicon"),
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(profileBtn)
        )
        
        //create a new button
        let leftButton = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))

        leftButton.kf.setImage(with: Authenticator.shared.user?.profile.images.first,  for: .normal, placeholder: #imageLiteral(resourceName: "profileicon"))
        leftButton.addTarget(self, action: #selector(profileBtn(_:)), for: .touchUpInside)
        leftButton.rounded()
        let leftBarButton = UIBarButtonItem(customView: leftButton)
        navigationItem.leftBarButtonItem = leftBarButton
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: #imageLiteral(resourceName: "chaticon"),
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(chatBtn)
        )
        
        getPlaces()
                
//        ChatService.shared.observeChatList(self)
//        ChatService.shared.observeMatchList(self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Socialyze"
        self.navigationController?.navigationBar.isHidden = false
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
        }, failure: { error in
            self.activityIndicator.stopAnimating()
            self.alert(message: error.localizedDescription)
        })
    }
    
    func profileBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! ProfileViewController
        controller.userId = Authenticator.currentFIRUser?.uid
        performSegue(withIdentifier: "swipeToProfile", sender: nil)
        
//        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func chatBtn(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "swipeToChat", sender: nil)
//        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
//        let controller = storyboard.instantiateViewController(withIdentifier: "ChatListViewController") as! ChatListViewController
//        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func settingsBtn(_ sender: UIBarButtonItem) {
        let settingsViewController = UIViewController()
        self.navigationController?.pushViewController(settingsViewController, animated: true)
    }
}


extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let place = places[indexPath.row]
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlaceDetailViewController") as! PlaceDetailViewController
        vc.place = place
        self.present(vc, animated: true, completion: nil)
//        self.navigationController?.pushViewController(vc, animated: true)
        // self.performSegue(withIdentifier: "categoryDetail", sender: self)
        
//        if let nav = self.navigationController {
//            nav.present(vc, animated: true, completion: nil)
//        }
//        vc.navigationController?.isNavigationBarHidden = true
//        let backItem = UIBarButtonItem()
//        backItem.title = "Back"
//        navigationItem.backBarButtonItem = backItem
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return places.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell
        let imageView:UIImageView = cell.viewWithTag(1) as! UIImageView
        imageView.kf.indicatorType = .activity
        let p = Bundle.main.path(forResource: "indicator_40", ofType: "gif")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: p))
        imageView.kf.indicatorType = .image(imageData: data)
        
        imageView.kf.setImage(with: URL(string: places[indexPath.row].mainImage ?? "" ))
        
        (cell.viewWithTag(2) as! UILabel).text = places[indexPath.row].nameAddress
        
        // the shadow does not seem to be working
//        let placeName = (cell.viewWithTag(2) as! UILabel)
//        placeName.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
//        placeName.layer.shadowRadius = 3
//        placeName.layer.shadowOpacity = 1
//        placeName.layer.masksToBounds = false
        
        let floatRatingView = cell.viewWithTag(3) as! FloatRatingView
        let starLabel = cell.viewWithTag(4) as! UILabel
        floatRatingView.isHidden = false
        starLabel.isHidden = false
        
        floatRatingView.rating = 0
        floatRatingView.floatRatings = true
        
        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height
        if screenHeight == 568{
            cell.widthLayout.constant = 70
        }else{
            cell.widthLayout.constant = 100
        }
        
        (cell.viewWithTag(4) as! UILabel).text = ""
        if(UserDefaults.standard.object(forKey: places[indexPath.row].placeId ?? "") != nil){
            let starData = UserDefaults.standard.object(forKey: places[indexPath.row].placeId ?? "") as! NSDictionary
            print(starData)
            floatRatingView.rating = Float(starData["rating"] as! String)!
            starLabel.text = starData["rating"] as? String
            
        } else {
            if places[indexPath.row].placeId != "" {
                self.placeId( nmbr: indexPath.row)
            } else {
                floatRatingView.isHidden = true
                starLabel.isHidden = true
            }
        }
        
        
        (cell.viewWithTag(4) as! UILabel).font = UIFont.systemFont(ofSize: 11)
        
        if(indexPath.item % 6 == 0){
            (cell.viewWithTag(2) as! UILabel).font = UIFont.systemFont(ofSize: 22)
        }else{
            (cell.viewWithTag(2) as! UILabel).font = UIFont.systemFont(ofSize: 18)
        }
        
        return cell
    }
}

extension ViewController : TRMosaicLayoutDelegate {
    
    func collectionView(_ collectionView:UICollectionView, mosaicCellSizeTypeAtIndexPath indexPath:IndexPath) -> TRMosaicCellType {
        
        // I recommend setting every third cell as .Big to get the best layout
        return indexPath.item % 3 == 0 ? TRMosaicCellType.big : TRMosaicCellType.small
    }
    
    func collectionView(_ collectionView:UICollectionView, layout collectionViewLayout: TRMosaicLayout, insetAtSection:Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.5, left: 0.5, bottom: 0.5, right: 0.5)
    }
    
    func heightForSmallMosaicCell() -> CGFloat {
        return 180
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


extension ViewController: SlydeLocationManagerDelegate {
    func locationObtained() {
        
        
    }
    
    func locationPermissionChanged() {
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                // Enable or disable features based on authorization.
                if !granted {
                    DispatchQueue.main.async {
                        self.alertWithOkCancel(message: "Notification not Allowed. Would you like to open Setting?", title: "Alert", okTitle: "Open Setting", cancelTitle: "Dismiss", okAction: {
                            UIApplication.openAppSettings()
                        }, cancelAction: nil)
                    }
                }
            }
        }

    }
    
    func locationObtainError() {
        
        
    }
}

extension ViewController {
    
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("Tapped in notification")
        let userInfo = response.notification.request.content.userInfo
        
        if let userData = userInfo["user"], let chatData = userInfo["chat"] {
            let userJson = JSON(userData)
            let chatJson = JSON(chatData)
            
            if let user: LocalUser = userJson.map(), let   chatItem:ChatItem = chatJson.map() {
                self.openChat(user: user, chatItem: chatItem)
            }
        }
    }
    
    //This is key callback to present notification while the app is in foreground
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        
        print(notification.request.content.userInfo)
        
        print("Notification being triggered")
        //You can either present alert ,sound or increase badge while the app is in foreground too with ios 10
        //to distinguish between notifications
        if notification.request.identifier == Node.chatList.rawValue {
            completionHandler( [.alert,.sound,.badge])
        }
        else if  notification.request.identifier ==  Node.matchList.rawValue {
            completionHandler( [.alert,.sound,.badge])
        }
    }
    
    func openChat(user: LocalUser, chatItem :ChatItem) {
        let accesstoken = AccessToken.current
        if let _ = accesstoken?.authenticationToken {
            print("Facebook Access-token available")
            // redirect to required location
            
            let vc = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            
            vc.fromMatch = true
            vc.chatItem = chatItem
            vc.chatUser = user
            vc.chatUserName = user.profile.firstName ?? ""
            vc.chatOppentId = user.id
            
            if let nav =  self.navigationController {
                nav.pushViewController(vc, animated: true)
            } else {
                self.present(vc, animated: true, completion: {
                    
                })
            }
            
        } else {
            print("Facebook Access-token not found")
            appDelegate.checkForLogin()
        }
    }
    
    func openMatch() {
        let vc = UIStoryboard(name: "Matches", bundle: nil).instantiateViewController(withIdentifier: "MatchesViewController") as! MatchesViewController
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }
}

