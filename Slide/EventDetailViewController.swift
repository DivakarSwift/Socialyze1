//
//  EventDetailViewController.swift
//  Slide
//
//  Created by Rajendra Karki on 6/23/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookShare
import FirebaseDatabase
import FirebaseAuth
import MessageUI


enum EventAction {
    case going
    case checkIn
    case goingSwipe
    case checkInSwipe
}

class EventDetailViewController: UIViewController {
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var placeDistanceLabel: UILabel!
    @IBOutlet weak var locationPinButton: UIButton!
    @IBOutlet weak var eventDateLabel:UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var eventPlaceLabel:UILabel!
    
    @IBOutlet weak var goingView: UIView!
    @IBOutlet weak var checkInView: UIView!
    
    @IBOutlet weak var goingStatusLabel: UILabel!
    @IBOutlet weak var checkInStatusLabel: UILabel!
    @IBOutlet weak var friendsCollectionView: UICollectionView!
    @IBOutlet weak var checkInButton:UIButton!
    @IBOutlet weak var inviteButton:UIButton!
    @IBOutlet weak var eventImageView: UIImageView!
    
    internal let facebookService = FacebookService.shared
    internal let userService = UserService()
    internal let authenticator = Authenticator.shared
    internal let placeService = PlaceService()
    
    var place: Place?
    var isEvent:Bool?
    
    fileprivate var thresholdRadius = 30.48 //100ft
    fileprivate var adsIndex:Int = 0
    
    fileprivate weak var adDetailVC: EventAdsViewController?
    
    internal var isCheckedIn = false
    internal var isGoing = false
    
    internal var eventAction:EventAction = .going {
        didSet {
            self.changeCheckInButton(action: self.eventAction)
        }
    }
    
    internal var obtainedFacebookFriends = false {
        didSet {
            self.friendsCollectionView.reloadData()
            checkInn(silence: true)
            adDetailVC?.facebookFriends = self.faceBookFriends
        }
    }
    
    internal var faceBookFriends = [FacebookFriend]() {
        didSet {
            self.obtainedFacebookFriends = true
            self.changeGoingStatus()
        }
    }
    
    internal var checkinData = [Checkin]()
    internal var goingData = [Checkin]()
    internal var exceptedUsers:[String] = []
    
    internal var obtainedCheckInWithExpectUser = false{
        didSet {
            checkInn(silence: true)
        }
    }
    internal var checkinWithExpectUser = [Checkin]() {
        didSet {
            self.obtainedCheckInWithExpectUser = true
            self.activityIndicator.stopAnimating()
            
            // Removing already swipped user
            self.checkinData = checkinWithExpectUser.filter({(checkin) -> Bool in
                if let checkInUserId = checkin.userId {
                    // return true
                    if exceptedUsers.contains(checkInUserId) {
                        return false
                    }
                    return true
                }
                return false
            })
            
            self.getAllGoingUsers()
        }
    }
    
    internal var goingWithExpectUser = [Checkin]() {
        didSet {
            self.activityIndicator.stopAnimating()
            
            // Removing already swipped user
            self.goingData = goingWithExpectUser.filter({(checkin) -> Bool in
                if let goingUserId = checkin.userId {
                    // return true
                    if Authenticator.shared.user?.id == goingUserId {
                        self.isGoing = true
                        self.changeGoingStatus()
                    }
                    if exceptedUsers.contains(goingUserId) {
                        return false
                    }
                    return true
                }
                return false
            })
            
            self.getAllGoingUsers()
            self.changeGoingStatus()
        }
    }
    
    var eventUsers: [LocalUser] = [] {
        didSet {
            self.activityIndicator.stopAnimating()
        }
    }
    
    lazy internal var activityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = #imageLiteral(resourceName: "ladybird")
        let activityIndicator = CustomActivityIndicatorView(image: image)
        return activityIndicator
    }()
    
    
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.observe(selector: #selector(self.locationUpdated), notification: GlobalConstants.Notification.newLocationObtained)
        
        self.view.addSubview(activityIndicator)
        self.activityIndicator.center = view.center
        setupView()
        
        self.locationUpdated()
        SlydeLocationManager.shared.startUpdatingLocation()
        
        if facebookService.isUserFriendsPermissionGiven() {
            getUserFriends()
        } else {
            authenticator.delegate = self
            authenticator.authenticateWith(provider: .facebook)
        }
        
        self.changeGoingStatus()
        self.setupCollectionView()
        self.checkInButton.layer.cornerRadius = 5
        self.eventPlaceLabel.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.locationUpdated()
        self.navigationController?.isNavigationBarHidden = true
        UIApplication.shared.isStatusBarHidden = true
        self.title = place?.nameAddress
        self.addSwipeGesture(toView: self.view)
        self.addTapGesture(toView: self.eventImageView)
    }
    
    deinit {
        SlydeLocationManager.shared.stopUpdatingLocation()
    }
    
    // MARK: - Gesture
    func addTapGesture(toView view: UIView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        view.addGestureRecognizer(tap)
    }
    
    func handleTap(_ gesture: UITapGestureRecognizer) {
        self.viewDetail()
    }
    
    func addSwipeGesture(toView view: UIView) {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(wasSwipped))
        gesture.direction = .down
        view.addGestureRecognizer(gesture)
    }
    
    func wasSwipped(_ gesture: UISwipeGestureRecognizer) {
        dismiss(animated: true, completion: nil)
        UIApplication.shared.isStatusBarHidden = false
    }
    
    // MARK: -
    
    func setupView() {
        if let place = self.place {
            self.isGoing = false
            
            if let event = place.isEvent, event {
                self.eventNameLabel.text = place.event?.title
                self.eventDateLabel.text = place.event?.date
                self.eventTimeLabel.text = place.event?.time
                self.eventPlaceLabel.text = place.event?.detail
                
                let image = place.event?.image ?? place.mainImage ?? ""
                self.eventImageView.kf.setImage(with: URL(string: image), placeholder: #imageLiteral(resourceName: "OriginalBug") )
                getGoingUsers()
            } else {
                self.eventNameLabel.text = place.nameAddress
                self.eventDateLabel.text = place.date
                self.eventTimeLabel.text = place.time
                if let hall = place.hall {
                    self.eventPlaceLabel.text = "\(String(describing: hall))"
                } else {
                    self.eventPlaceLabel.text = place.bio
                }
                
                let image = place.secondImage ?? place.mainImage ?? ""
                self.eventImageView.kf.setImage(with: URL(string: image), placeholder: #imageLiteral(resourceName: "OriginalBug") )
                self.eventAction = .checkIn
                self.changeCheckInButton(action: .checkIn)
                getCheckedinUsers()
            }
        }
        
        self.placeDistanceLabel.layer.shadowOpacity = 1.0
        self.placeDistanceLabel.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.placeDistanceLabel.layer.shadowRadius = 3.0
        self.eventNameLabel.layer.shadowOpacity = 1.0
        self.eventNameLabel.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.eventNameLabel.layer.shadowRadius = 3.0
        self.eventTimeLabel.layer.shadowOpacity = 1.0
        self.eventTimeLabel.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.eventTimeLabel.layer.shadowRadius = 3.0
        self.eventPlaceLabel.layer.shadowOpacity = 1.0
        self.eventPlaceLabel.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.eventPlaceLabel.layer.shadowRadius = 3.0
        self.eventDateLabel.layer.shadowOpacity = 1.0
        self.eventDateLabel.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.eventDateLabel.layer.shadowRadius = 3.0
    }
    
    func hideControls() {
        view.layoutIfNeeded()
    }
    
    // MARK: -
    
    func changeCheckInButton(action: EventAction) {
        switch action {
        case .going:
            self.checkInButton.setTitle("Going", for: .normal)
            self.checkInButton.setImage(nil, for: .normal)
            self.checkInButton.setTitleColor(UIColor.white, for: .normal)
            self.checkInButton.backgroundColor = UIColor.appGreen
        case .checkIn:
            self.checkInButton.setTitle("Check In", for: .normal)
            self.checkInButton.setImage(#imageLiteral(resourceName: "checkinbutton32x32"), for: .normal)
            self.checkInButton.setTitleColor(UIColor.appPurple, for: .normal)
            self.checkInButton.backgroundColor = UIColor.white
        case .goingSwipe, .checkInSwipe:
            self.checkInButton.setTitle("Swipe", for: .normal)
            self.checkInButton.setImage(nil, for: .normal)
            self.checkInButton.setTitleColor(UIColor.white, for: .normal)
            self.checkInButton.backgroundColor = UIColor.appPurple
        }
    }
    
    func  viewDetail() {
        if self.place?.hasDeal ?? false {
            openEventAd()
        }
    }
    
    @IBAction func dealBtnTapped(_ sender: Any) {
        self.viewDetail()
    }
    
    private func openEventAd() {
        let sb = self.storyboard
        let adDeatilVc = sb?.instantiateViewController(withIdentifier: "EventAdsViewController") as! EventAdsViewController
        adDeatilVc.facebookFriends = self.faceBookFriends
        adDeatilVc.eventUsers = getCheckedInFbFriends()
        adDeatilVc.place = self.place!
        adDeatilVc.placeService = self.placeService
        self.adDetailVC = adDeatilVc
        self.present(adDeatilVc, animated: false, completion: nil)
    }
    
    private func getCheckedInFbFriends() -> [LocalUser] {
        return self.eventUsers.filter({(user) -> Bool in
            let isCheckedIn: () -> (Bool) = {
                for checkin in self.checkinData {
                    if checkin.userId == user.id {
                        return true
                    }
                }
                return false
            }
            
            let isFbFriend: () -> (Bool) = {
                for faceBookFriend in self.faceBookFriends {
                    if user.profile.fbId == faceBookFriend.id {
                        return true
                    }
                }
                return false
            }
            return isCheckedIn() && isFbFriend()
        })
    }
    
    fileprivate func getFacebookFriendEventUsers() -> [LocalUser] {
        return self.eventUsers.filter({(user) -> Bool in
            for faceBookFriend in self.faceBookFriends {
                if user.profile.fbId == faceBookFriend.id {
                    return true
                }
            }
            return false
        })
    }
    
    
    @IBAction func checkIn(_ sender: UIButton?) {
        switch eventAction {
        case .going:
            self.going()
        case .goingSwipe:
            if self.goingData.count != 0 {
                self.openCategories()
            } else {
                self.alert(message: "No others going at this time. Check back later", title: "Oops", okAction: {
                    
                })
            }
        case .checkIn:
            self.checkInn()
        case .checkInSwipe:
            if self.checkinData.count != 0 {
                self.openCategories()
            } else {
                self.alert(message: "No others going at this time. Check back later", title: "Oops", okAction: {
                    
                })
                self.changeGoingStatus()
            }
        }
    }
    
    fileprivate func openCategories() {
        let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "categoryDetailViewController") as! CategoriesViewController
        
        vc.place = self.place
        vc.noUsers = {
            self.dismiss(animated: true, completion: nil)
            _ = self.navigationController?.popViewController(animated: false)
        }
        if self.eventAction == .goingSwipe {
            vc.isGoing = true
            let userIdsSet = Set(self.goingData.flatMap({$0.userId}))
            vc.checkinUserIds = userIdsSet
        } else if self.eventAction == .checkInSwipe {
            vc.isCheckedIn = true
            let userIdsSet = Set(self.checkinData.flatMap({$0.userId}))
            vc.checkinUserIds = userIdsSet
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    private func fireGoingPushNotificationToFriends(users: [LocalUser], counter: Int, message: String) {
        var parameters:[String:Any] = [:]
        var userInfo:[String:Any] = [:]
        userInfo["user"] = Authenticator.shared.user?.toJSON()
        
        var header:[String:Any] = [:]
        header["Authorization"] = GlobalConstants.APIKeys.googleLegacyServerKey
        
        parameters["notification"] = ["title": "Going",
                                      "body": message,
                                      "sound":"default"]
        parameters["to"] = users[counter].fcmToken
        parameters["collapse_key"] = "GOING"
        parameters["data"] = userInfo
        parameters["priority"] = "high"
        
        Utilities.firePushNotification(with: parameters) {
            if counter + 1 < users.count {
                self.fireGoingPushNotificationToFriends(users: users, counter: counter + 1, message: message)
            }
        }
    }
    
    private func checkInn(silence: Bool = false) {
        guard self.obtainedFacebookFriends && self.obtainedCheckInWithExpectUser else {return}
        if place?.size == 1 {
            thresholdRadius = smallRadius
        } else if place?.size == 2 {
            thresholdRadius = mediumRadius
        } else if place?.size == 3 {
            thresholdRadius = largeRadius
        } else if place?.size == 4 {
            thresholdRadius = hugeRadius
        } else if place?.size == 0 {
            thresholdRadius = 0
        }
        
        func check() {
            self.checkIn()
        }
        
        if let distance = self.getDistanceToUser(), distance <= thresholdRadius {
            check()
            
        } else if thresholdRadius == 0 && (SlydeLocationManager.shared.distanceFromUser(lat: SNlat1, long: SNlong1)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: SNlat2, long: SNlong2)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: SNlat3, long: SNlong3)! < hugeRadius){
            check()
            
        } else if (place?.nameAddress)! == "Columbus State" && (SlydeLocationManager.shared.distanceFromUser(lat: CSlat1, long: CSlong1)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: CSlat2, long: CSlong2)! < hugeRadius){
            check()
            
        } else if (place?.nameAddress)! == "Easton Town Center" && (SlydeLocationManager.shared.distanceFromUser(lat: Elat1, long: Elong1)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: Elat2, long: Elong2)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: Elat3, long: Elong3)! < hugeRadius ||  SlydeLocationManager.shared.distanceFromUser(lat: Elat4, long: Elong4)! < hugeRadius) {
            check()
            
        } else if (place?.nameAddress)! == "Pride Festival & Parade" && (SlydeLocationManager.shared.distanceFromUser(lat: PFPlat1, long: PFPlong1)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: PFPlat2, long: PFPlong2)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: PFPlat3, long: PFPlong3)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: PFPlat4, long: PFPlong4)! < hugeRadius) {
            check()
            
        } else if (place?.early)! > 0 {
            check()
            
        } else {
            if silence {return}
            self.alert(message: GlobalConstants.Message.userNotInPerimeter.message, title: GlobalConstants.Message.userNotInPerimeter.title, okAction: {
                
            })
        }
        
        // REMOVE on deployment
        //        self.checkIn {[weak self] in
        //            self?.performSegue(withIdentifier: "Categories", sender: self)
        //        }
    }
    
    private func checkout() {
        self.placeService.user(authenticator.user!, checkOutFrom: self.place!) {[weak self] (success, error) in
            if success {
                _ = self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    
    @IBAction func invite(_ sender: UIButton) {
        self.showMoreOption()
    }
    
    func recheckin() {
        SlydeLocationManager.shared.requestLocation()
    }
    
    func locationUpdated() {
        if let distance = getDistanceToUser(), let size = place?.size {
            
            let check1 = distance <= smallRadius
            let check2 = distance <= mediumRadius && size == 2
            let check3 = distance <= largeRadius  && size == 3
            let check4 = distance <= hugeRadius  && size == 4
            
            if check1 || check2 || check3 || check4 {
                self.placeDistanceLabel.isHidden = true
                self.locationPinButton.setImage(#imageLiteral(resourceName: "checkinbutton32x32"), for: .normal)
                if self.isCheckedIn {
                    self.eventAction = .checkInSwipe
                } else {
                    self.eventAction = .checkIn
                    self.checkIn(nil)
                }
                self.changeGoingStatus()
            }
            else {
                self.placeDistanceLabel.isHidden = false
                
                if let isEvent = self.place?.isEvent, isEvent {
                    if self.isGoing {
                        self.eventAction = .goingSwipe
                    } else {
                        self.eventAction = .going
                    }
                } else {
                    if self.isCheckedIn {
                        self.eventAction = .checkInSwipe
                    } else {
                        self.eventAction = .checkIn
                    }
                }
                self.changeGoingStatus()
                
                let ft = distance * 3.28084
                
                if ft >= 5280 {
                    self.placeDistanceLabel.text = "\(Int(ft / 5280))mi."
                } else {
                    self.placeDistanceLabel.text = "\(Int(distance * 3.28084))ft."
                }
            }
        }
    }
    
    func changeGoingStatus() {
        
        if let isEvent = self.place?.isEvent, isEvent,
            self.goingWithExpectUser.count > 0 {
            self.goingView.isHidden = false
            var goignText = "\(goingWithExpectUser.count) going"
            self.goingStatusLabel.text = goignText
            
            if isGoing && self.eventAction == .going {
                self.eventAction = .goingSwipe
            }
            let fbIds = self.faceBookFriends.map({$0.id})
            let friendCheckins = goingWithExpectUser.filter({fbIds.contains($0.fbId!)})
            
            if friendCheckins.count > 1 {
                goignText = goignText + " including \(friendCheckins.count) friends"
            } else if friendCheckins.count > 0 {
                goignText = goignText + " including \(friendCheckins.count) friend"
            }
            self.goingStatusLabel.text = goignText
            
        } else {
            self.goingView.isHidden = true
        }
        
        if self.checkinData.count > 0 {
            self.checkInView.isHidden = false
            var checkinText = "\(checkinData.count) checked in"
            self.checkInStatusLabel.text = checkinText
            
            if self.checkinData.count > 0 {
                let fbIds = self.faceBookFriends.map({$0.id})
                let friendCheckins = checkinData.filter({fbIds.contains($0.fbId!)})
                
                if friendCheckins.count > 1 {
                    checkinText =  checkinText + " including \(friendCheckins.count) friends"
                } else if friendCheckins.count > 0 {
                    checkinText = checkinText + " including \(friendCheckins.count) friend"
                }
                self.checkInStatusLabel.text = checkinText
            }
        } else {
            self.checkInView.isHidden = true
        }
        self.friendsCollectionView.reloadData()
    }
    
    func getDistanceToUser() -> Double? {
        if let lat = self.place?.lat, let lon = place?.long, let distance = SlydeLocationManager.shared.distanceFromUser(lat: lat, long: lon) {
            return distance
        }
        return nil
    }
    
    @IBAction func map(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Maps", bundle: nil).instantiateViewController(withIdentifier: "PlaceToUserMapViewController") as! PlaceToUserMapViewController
        vc.place = self.place
        self.present(vc, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openMap" {
            let destinationVC = segue.destination as! PlaceToUserMapViewController
            destinationVC.place = self.place
        }else if segue.identifier == "Categories" {
            let destinationVC = segue.destination as! CategoriesViewController
            
            destinationVC.place = self.place
            destinationVC.noUsers = {
                self.dismiss(animated: true, completion: nil)
                _ = self.navigationController?.popViewController(animated: false)
                
            }
            if eventAction == .goingSwipe {
                destinationVC.isGoing = true
                let userIdsSet = Set(self.goingData.flatMap({$0.userId}))
                destinationVC.checkinUserIds = userIdsSet
            } else if eventAction == .checkInSwipe {
                destinationVC.isCheckedIn = true
                let userIdsSet = Set(self.checkinData.flatMap({$0.userId}))
                destinationVC.checkinUserIds = userIdsSet
            }
        }
        return super.prepare(for: segue, sender: sender)
    }
    
}


// MARK: - INVITE ACTION
extension EventDetailViewController : MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate {
    
    // More option
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
        let text = "Hey! Meet me with https://itunes.apple.com/us/app/socialyze/id1239571430?mt=8"
        
        
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
    
    private func openFacebookInvite() {
        
        
        // Please change this two urls accordingly
        let appLinkUrl:URL = URL(string: "https://fb.me/1351482471639007")!//GlobalConstants.urls.itunesLink)!
        let previewImageUrl:URL = URL(string: "http://socialyzeapp.com/wp-content/uploads/2017/03/logo-128p.png")!
        
        var inviteContent:AppInvite = AppInvite.init(appLink: appLinkUrl)
        inviteContent.appLink = appLinkUrl
        inviteContent.previewImageURL = previewImageUrl
        
        
        let inviteDialog = AppInvite.Dialog(invite: inviteContent)
        do {
            try inviteDialog.show()
        } catch  (let error) {
            print(error.localizedDescription)
        }
    }
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        controller.dismiss(animated: true, completion: nil)
    }
}

extension EventDetailViewController: AuthenticatorDelegate {
    func didOccurAuthentication(error: AuthenticationError) {
        self.alert(message: error.localizedDescription)
    }
    
    func didSignInUser() {
        
    }
    
    func didLogoutUser() {
        
    }
    
    func shouldUserSignInIntoFirebase() -> Bool {
        if facebookService.isPhotoPermissionGiven() {
            getUserFriends()
        }else {
            self.alert(message: "Facebook user friends permission is not granted.", okAction: {
                self.dismiss(animated: true, completion: nil)
            })
        }
        return false
    }
}

extension EventDetailViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  self.getFacebookFriendEventUsers().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let user = self.getFacebookFriendEventUsers().elementAt(index: indexPath.row)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "friendsCell", for: indexPath)
        
        let label = cell.viewWithTag(2) as! UILabel
        //        label.text = "Dari"
        label.text = user?.profile.firstName
        label.layer.shadowOpacity = 1
        label.layer.shadowRadius = 3
        label.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        
        let imageView = cell.viewWithTag(1) as! UIImageView
        //imageView.rounded()
        //        imageView.image = UIImage(named: "profile.png")
        if let user = user {
            imageView.kf.setImage(with: user.profile.images.first)
        }else {
            imageView.image = nil
        }
        
        let checkButton = cell.viewWithTag(3) as! UIButton
        checkButton.isHidden = !(user?.isCheckedIn ?? true)
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "categoryDetailViewController") as! CategoriesViewController
        vc.fromFBFriends = self.eventUsers[indexPath.row]
        vc.transitioningDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    func setupCollectionView() {
        let numberOfColumn:CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 4 : 3
        let collectionViewCellSpacing:CGFloat = 10
        
        if let layout = friendsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout{
            let cellWidth:CGFloat = ( self.view.frame.size.width  - (numberOfColumn + 1)*collectionViewCellSpacing)/numberOfColumn
            let cellHeight:CGFloat = self.friendsCollectionView.frame.size.height - 2*collectionViewCellSpacing
            layout.itemSize = CGSize(width: cellWidth, height:cellHeight)
            layout.minimumLineSpacing = collectionViewCellSpacing
            layout.minimumInteritemSpacing = collectionViewCellSpacing
        }
    }
}

extension EventDetailViewController: UIViewControllerTransitioningDelegate {
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
}


