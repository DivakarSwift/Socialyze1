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
import MessageUI
import FacebookCore
import FacebookShare

class ViewController: UIViewController {
    
    @IBOutlet weak var leftBarCustomButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var friendCollectionView: UICollectionView!
    
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
    
    fileprivate let refeshControl = UIRefreshControl()
    
    fileprivate var me: LocalUser? { return Authenticator.shared.user}
    let facebookService = FacebookService.shared
    let userService = UserService()
    
    var places = [Place]() {
        didSet {
            Authenticator.shared.places = places
            self.sortChatUsers(users: self.chatUsers)
            self.collectionView.reloadData()
        }
    }
    
    private var faceBookFriends = [FacebookFriend]() {
        didSet {
            self.getAllUsers()
        }
    }
    
    var chatUsers = [LocalUser]() {
        didSet {
            self.friendCollectionView.reloadData()
        }
    }
    
    var blockedUserIds:[String]? {
        didSet {
            if let ids = blockedUserIds, ids.count > 0 {
                let chatUsers = self.chatUsers.filter({ (user) -> Bool in
                    return !ids.contains(user.id!)
                })
                self.sortChatUsers(users: chatUsers)
            }
        }
    }
    
    func sortChatUsers(users: [LocalUser]) {
        let (noPlaceUsers, placeUsers) = users
            .map({ (user) -> (Int?, LocalUser) in
                if let placeIndex = self.places.index(where: { (place) -> Bool in
                    return place.nameAddress == user.checkIn?.place
                }) {
                    return (placeIndex, user)
                }
                return (nil, user)
            })
            .reduce(([LocalUser](), [(Int, LocalUser)]())) { (result, element) in
                if element.0 == nil {
                    return ((result.0 + [element.1]), result.1)
                }else {
                    return (result.0, result.1 + [(element.0!, element.1)])
                }
        }
        let sortedPlaceUsers = placeUsers.sorted(by: {$0.0 < $1.0}).map({$0.1})
        
        self.chatUsers = sortedPlaceUsers + noPlaceUsers
        
            
//            .sorted { (user1, user2) -> Bool in
//                if let user1PlaceIndex = self.places.index(where: { (place) -> Bool in
//                    return place.nameAddress == user1.checkIn?.place
//                }),
//                    let user2PlaceIndex = self.places.index(where: { (place) -> Bool in
//                        return place.nameAddress == user2.checkIn?.place
//                    }) {
//                    return user1PlaceIndex < user2PlaceIndex
//                }
//                return true
//        }
    }
    
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
        
        self.friendCollectionView.delegate = self
        self.friendCollectionView.dataSource = self
        
        leftBarCustomButton.kf.setImage(with: Authenticator.shared.user?.profile.images.first,  for: .normal, placeholder: #imageLiteral(resourceName: "profileicon"))
        leftBarCustomButton.addTarget(self, action: #selector(profileBtn(_:)), for: .touchUpInside)
        leftBarCustomButton.rounded()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: #imageLiteral(resourceName: "friendsicon"),
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(chatBtn)
        )
        
        self.getPlaces()
        self.getUserFriends()
        
        self.configureRefreshControl()
        
    }
    
    func getUserFriends() {
        self.activityIndicator.startAnimating()
        facebookService.getUserFriends(success: {[weak self] (friends: [FacebookFriend]) in
            self?.activityIndicator.stopAnimating()
            self?.faceBookFriends = friends
            let friendsCount = self?.faceBookFriends.count
            print("Total number of facebook friends :\(String(describing: friendsCount))")
            }, failure: { (error) in
                self.activityIndicator.stopAnimating()
                self.alert(message: error)
                print(error)
        })
    }
    
    func getAllUsers() {
        self.activityIndicator.startAnimating()
        userService.getAllUser { (users) in
            self.activityIndicator.stopAnimating()
            print("Total number of user :\(users.count)")
            let fbIds = self.faceBookFriends.flatMap({$0.id})
            let chatuserss = users.filter({(user) -> Bool in
                if let fbId = user.profile.fbId {
                    return fbIds.contains(fbId)
                }
                return false
            })
            let chatUsers = chatuserss.filter({(user) -> Bool in
                if let userID = user.id, let blockedIds = self.blockedUserIds {
                    return !blockedIds.contains(userID)
                }
                return true
            })
            self.sortChatUsers(users: chatUsers)
            self.getBlockIds()
        }
    }
    
    func getBlockIds() {
        self.activityIndicator.startAnimating()
        userService.getBlockedIds(of: me!) { (ids, error) in
            self.activityIndicator.stopAnimating()
            self.blockedUserIds = ids
            if error != nil {
                self.alert(message: GlobalConstants.Message.oops)
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Socialyze"
        UIApplication.shared.isStatusBarHidden = false
        self.navigationController?.navigationBar.isHidden = false
        SlydeLocationManager.shared.requestLocation()
    }
    
    func getPlaces() {
        if !self.refeshControl.isRefreshing {
            self.activityIndicator.startAnimating()
        }
        PlaceService().getPlaces(completion: { (places) in
            if self.refeshControl.isRefreshing {
                self.refeshControl.endRefreshing()
            }else {
                self.activityIndicator.stopAnimating()
            }
            self.places = places
            self.locationUpdated()
        }, failure: { error in
            if self.activityIndicator.isAnimating {
                self.activityIndicator.stopAnimating()
            }
            self.alert(message: error.localizedDescription, okAction: {
                if self.refeshControl.isRefreshing {
                    self.refeshControl.endRefreshing()
                }
            })
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
        //        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        //        let controller = storyboard.instantiateInitialViewController() as! ProfileViewController
        //        controller.userId = Authenticator.currentFIRUser?.uid
        //        performSegue(withIdentifier: "swipeToProfile", sender: nil)
        NotificationCenter.default.post(name: GlobalConstants.Notification.changePage.notification, object: 0)
    }
    
    func chatBtn(_ sender: UIBarButtonItem) {
        let vc = UIStoryboard.init(name: "Activity", bundle: nil).instantiateViewController(withIdentifier: "ActivityViewController")
        if let nav = self.navigationController {
            nav.pushViewController(vc, animated: true)
        }else {
            self.present(vc, animated: true, completion: nil)
        }
//        NotificationCenter.default.post(name: GlobalConstants.Notification.changePage.notification, object: 2)
        //        performSegue(withIdentifier: "swipeToChat", sender: nil)
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
    
    private func configureRefreshControl() {
        self.refeshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        self.refeshControl.attributedTitle = NSAttributedString(string: "Pull to Update Places")
        if #available(iOS 10.0, *) {
            self.collectionView.refreshControl = refeshControl
        } else {
            self.collectionView.addSubview(refeshControl)
        }
    }
    
    @objc private func refresh() {
        self.getPlaces()
        self.getUserFriends()
    }
    
    fileprivate func showMoreOption() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let facebook = UIAlertAction(title: "Facebook", style: .default) { [weak self] (_) in
            self?.openFacebookInvite()
            self?.alert(message: "Coming Soon!")
        }
        alert.addAction(facebook)
        
        let textMessage = UIAlertAction(title: "Text Message", style: .default) { [weak self] (_) in
            self?.openMessage()
        }
        alert.addAction(textMessage)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func openMessage() {
        let text = "Hey! Meet me with https://itunes.apple.com/us/app/socialyze/id1239571430?mt=8 "
        
        
        if !MFMessageComposeViewController.canSendText() {
            // For simulator only.
            let messageURL = URL(string: "sms:body=\(text)")
            guard let url = messageURL else {
                return
            }
            
            if UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        } else {
            let controller = MFMessageComposeViewController()
            controller.messageComposeDelegate = self
            controller.body = text
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func openFacebookInvite() {
        
        
        // Please change this two urls accordingly
        //        let appLinkUrl:URL = URL(string: "https://itunes.apple.com/us/app/socialyze/id1239571430?mt=8")!
        let appLinkUrl:URL = URL(string: "https://fb.me/1351482471639007")!//GlobalConstants.urls.itunesLink)!
        
        let previewImageUrl:URL = URL(string: "http://socialyzeapp.com/wp-content/uploads/2017/03/logo-128p.png")!
        
        var inviteContent:AppInvite = AppInvite.init(appLink: appLinkUrl)
        inviteContent.previewImageURL = previewImageUrl
        
        let inviteDialog = AppInvite.Dialog(invite: inviteContent)
        do {
            try inviteDialog.show()
        } catch  (let error) {
            print(error.localizedDescription)
        }
    }
}


extension ViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView {
            let place = places[indexPath.row]
            let vc = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
            vc.place = place
            self.present(vc, animated: true, completion: nil)
        }else {
            if indexPath.row == 0 {
                self.showMoreOption()
            }else if indexPath.row == 1 && self.chatUsers.count == 0 {
                return
            }else {
                if let chatUser = self.chatUsers.elementAt(index: indexPath.row - 1), let friend = chatUser.id, let me = Authenticator.shared.user?.id {
                    
                    let vc = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                    
                    var val = ChatItem()
                    
                    let chatId =  friend > me ? friend+me : me+friend
                    val.chatId = chatId
                    val.userId = friend
                    
                    vc.fromSquad = true
                    vc.chatItem = val
                    vc.chatUser = chatUser
                    vc.chatUserName = chatUser.profile.firstName ?? ""
                    vc.chatOppentId = friend
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == friendCollectionView {
            if indexPath.row == 0 {
                return CGSize(width: 60, height: 80)
            }else if indexPath.row == 1 && self.chatUsers.count == 0 {
                return CGSize(width: 200, height: 80)
            }else {
                return CGSize(width: 70, height: 80)
            }
        }
        return .zero
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return places.count
        }
        return max(self.chatUsers.count, 1) + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
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
        }else {
            if indexPath.row == 0 {
                return collectionView.dequeueReusableCell(withReuseIdentifier: "InviteCell", for: indexPath)
            }else if indexPath.row == 1 && self.chatUsers.count == 0 {
                return collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath)
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendCheckinPlaceCollectionViewCell", for: indexPath) as! FriendCheckinPlaceCollectionViewCell
            let user = self.chatUsers.elementAt(index: indexPath.row - 1)
            cell.chatUser = user
            cell.setup()
            return cell
        }
    }
}


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

extension ViewController : MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        controller.dismiss(animated: true, completion: nil)
    }
}
