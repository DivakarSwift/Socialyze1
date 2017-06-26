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
    @IBOutlet weak var checkinMarkImageView: UIImageView!
    @IBOutlet weak var eventDateLabel:UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var eventPlaceLabel:UILabel!
    @IBOutlet weak var goingStatusLabel: UILabel!
    @IBOutlet weak var includingFriendsLabel: UILabel!
    @IBOutlet weak var friendsCollectionView: UICollectionView!
    @IBOutlet weak var checkInButton:UIButton!
    @IBOutlet weak var inviteButton:UIButton!
    @IBOutlet weak var eventImageView: UIImageView!
    
    let facebookService = FacebookService.shared
    let userService = UserService()
    private let authenticator = Authenticator.shared
    private let placeService = PlaceService()
    
    var place: Place?
    var thresholdRadius = 30.48 //100ft
    var adsIndex:Int = 0
    
    private var isCheckedIn = false
    private var isGoing = false
    
    fileprivate var eventAction:EventAction = .going {
        didSet {
            self.changeCheckInButton(action: self.eventAction)
        }
    }
    
    private var faceBookFriends = [FacebookFriend]() {
        didSet {
            self.changeGoingStatus()
        }
    }
    
    private var checkinData = [Checkin]()
    private var goingData = [Checkin]()
    private var exceptedUsers:[String] = []
    
    private var checkinWithExpectUser = [Checkin]() {
        didSet {
            self.activityIndicator.stopAnimating()
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
           self.getAllCheckedInUsers(data : checkinWithExpectUser)
        }
    }
    
    private var goingWithExpectUser = [Checkin]() {
        didSet {
            self.activityIndicator.stopAnimating()
            self.goingData = goingWithExpectUser.filter({(checkin) -> Bool in
                if let goingUserId = checkin.userId {
                    // return true
                    if exceptedUsers.contains(goingUserId) {
                        return false
                    }
                    return true
                }
                return false
            })
            self.goingData = self.goingWithExpectUser.filter({(checkin) -> Bool in
                if let checkInUserId = checkin.userId, let authUserId = self.authenticator.user?.id, let checkinTime = checkin.time {
                    // return true
                    
                    let checkTimeValid = checkInUserId != authUserId && (Date().timeIntervalSince1970 - checkinTime) < checkInThreshold
                    return checkTimeValid
                }
                return false
            })
            self.getAllGoingUsers(data : checkinWithExpectUser)
            self.changeGoingStatus()
        }
    }
    
    var checkinUsers: [LocalUser] = [] {
        didSet {
            self.activityIndicator.stopAnimating()
        }
    }
    
    var goingUsers: [LocalUser] = [] {
        didSet {
            self.activityIndicator.stopAnimating()
        }
    }
    
    private var checkInKey: String?
    lazy fileprivate var activityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = #imageLiteral(resourceName: "ladybird")
        let activityIndicator = CustomActivityIndicatorView(image: image)
        return activityIndicator
    }()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.checkinMarkImageView.isHidden = false
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
        
        self.eventAction = .going
        self.changeGoingStatus()
        
        getGoingUsers()
        self.setupCollectionView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        UIApplication.shared.isStatusBarHidden = true
        self.title = place?.nameAddress
        self.addSwipeGesture(toView: self.view)
//        self.addTapGesture(toView: self.view)
        
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
//        self.viewDetail()
    }
    
    func addSwipeGesture(toView view: UIView) {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(wasSwipped))
        gesture.direction = .down
        view.addGestureRecognizer(gesture)
    }
    func wasSwipped(_ gesture: UISwipeGestureRecognizer) {
                dismiss(animated: true, completion: nil)
        UIApplication.shared.isStatusBarHidden = false
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
//        _ = self.navigationController?.popViewController(animated: false)
    }
    
    // MARK: -
    
    func setupView() {
        if let place = self.place {
            self.isGoing = false
            self.eventNameLabel.text = place.nameAddress
            self.eventDateLabel.text = place.date
            self.eventTimeLabel.text = place.time
            if let hall = place.hall {
                self.eventPlaceLabel.text = "@ \(String(describing: hall))"
            }
            
            let image = place.secondImage ?? place.mainImage ?? ""
            self.eventImageView.kf.setImage(with: URL(string: image), placeholder: #imageLiteral(resourceName: "OriginalBug") )
        }
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
    
    
    @IBAction func next(_ sender: UIButton) {
        if let adsUrl = place?.ads?.first?.link {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: adsUrl)!, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(URL(string: adsUrl)!)
            }
        }
        
    }
        
    
    
    @IBAction func detail(_ sender: UIButton) {
        self.viewDetail()
    }
    
    func  viewDetail(){
        if let _ = self.place?.ads {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AdsViewController") as! AdsViewController
            vc.place = self.place
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func checkIn(_ sender: UIButton) {
        switch eventAction {
        case .going:
            self.going()
        case .goingSwipe:
            if self.goingData.count != 0 {
                self.alertWithOkCancel(message: "You are going, so wanna see who else are going?", title: "Hey, There", okTitle: "Yes", cancelTitle: "No", okAction: {
                    self.performSegue(withIdentifier: "Categories", sender: self)
                }, cancelAction: { _ in
                    self.eventAction = .checkIn
                })
            } else {
                self.alert(message: "No others going till this time. Check back later", title: "Oops", okAction: nil)
            }
            self.eventAction = .checkIn
            self.changeGoingStatus()
        case .checkIn:
            self.alertWithOkCancel(message: "Are you at this event place?", title: "Alert", okTitle: "Yes", cancelTitle: "No", okAction: {
                self.checkInn()
            }, cancelAction: { _ in
                
            })
        case .checkInSwipe:
            if self.checkinData.count != 0 {
                self.performSegue(withIdentifier: "Categories", sender: self)
            } else {
                self.alert(message: "No others going till this time. Check back later", title: "Oops", okAction: nil)
                self.changeGoingStatus()
            }
        }
    }
    
    private func going() {
        self.alertWithOkCancel(message: "Are you interested in going?", title: "Alert", okTitle: "Ok", cancelTitle: "Cancel", okAction: { 
            
            self.goingIn {[weak self] in
                    if self?.goingData.count != 0 {
                        
                    }else {
                        
                    }
                }
        }, cancelAction: { _ in
            self.eventAction = .checkIn
        })
    }
    
    private func checkInn() {
        if place?.size == 1 {
            thresholdRadius = smallRadius
        } else if place?.size == 2{
            thresholdRadius = mediumRadius
        } else if place?.size == 3 {
            thresholdRadius = largeRadius
        } else if place?.size == 4{
            thresholdRadius = hugeRadius
        } else if place?.size == 0 {
            thresholdRadius = 0
        }
        
        func check() {
            self.checkIn {[weak self] in
               self?.eventAction = .checkInSwipe
            }
        }
        
        if let distance = self.getDistanceToUser(), distance <= thresholdRadius {
            check()
            self.inviteButton.setImage(#imageLiteral(resourceName: "PlayButton"), for: .normal)
        } else if thresholdRadius == 0 && (SlydeLocationManager.shared.distanceFromUser(lat: SNlat1, long: SNlong1)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: SNlat2, long: SNlong2)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: SNlat3, long: SNlong3)! < hugeRadius){
            check()
            self.checkInButton.setImage(#imageLiteral(resourceName: "PlayButton"), for: .normal)
        } else if (place?.nameAddress)! == "Columbus State" && (SlydeLocationManager.shared.distanceFromUser(lat: CSlat1, long: CSlong1)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: CSlat2, long: CSlong2)! < hugeRadius){
            check()
            self.checkInButton.setImage(#imageLiteral(resourceName: "PlayButton"), for: .normal)
        } else if (place?.nameAddress)! == "Easton Town Center" && (SlydeLocationManager.shared.distanceFromUser(lat: Elat1, long: Elong1)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: Elat2, long: Elong2)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: Elat3, long: Elong3)! < hugeRadius ||  SlydeLocationManager.shared.distanceFromUser(lat: Elat4, long: Elong4)! < hugeRadius) {
            check()
            self.checkInButton.setImage(#imageLiteral(resourceName: "PlayButton"), for: .normal)
        } else if (place?.nameAddress)! == "Pride Festival & Parade" && (SlydeLocationManager.shared.distanceFromUser(lat: PFPlat1, long: PFPlong1)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: PFPlat2, long: PFPlong2)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: PFPlat3, long: PFPlong3)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: PFPlat4, long: PFPlong4)! < hugeRadius) {
            check()
            self.checkInButton.setImage(#imageLiteral(resourceName: "PlayButton"), for: .normal)
        } else if (place?.early)! > 0 {
            check()
            self.checkInButton.setImage(#imageLiteral(resourceName: "PlayButton"), for: .normal)
        } else {
            self.alert(message: GlobalConstants.Message.userNotInPerimeter.message, title: GlobalConstants.Message.userNotInPerimeter.title, okAction: {
                
                self.dismiss(animated: true, completion: nil)
                _ = self.navigationController?.popViewController(animated: false)
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
//        self.showMoreOption()
    }
    
    private func checkIn(onSuccess: @escaping () -> ()) {
        self.placeService.user(authenticator.user!, checkInAt: self.place!, completion: {[weak self] (success, error) in
            success ?
                onSuccess() :
                self?.alert(message: error?.localizedDescription)
            if let me = self {
                me.isCheckedIn = success
                
                if success {
                    SlydeLocationManager.shared.stopUpdatingLocation()
                    Timer.scheduledTimer(timeInterval: 20*60, target: me, selector: #selector(me.recheckin), userInfo: nil, repeats: false)
                }
            }
            
            print(error ?? "CHECKED IN")
        })
    }
    
    private func goingIn(onSuccess: @escaping () -> ()) {
        
        self.placeService.user(authenticator.user!, goingAt: self.place!) { [weak self] (success, error) in
            success ?
                onSuccess() :
                self?.alert(message: error?.localizedDescription)
            if let me = self {
                me.isGoing = success
                
                if success {
                    self?.eventAction = .goingSwipe
                }
            }
            
            print(error ?? "CHECKED IN")
        }
    }
    
    func recheckin() {
        SlydeLocationManager.shared.requestLocation()
    }
    
    func locationUpdated() {
        if let distance = getDistanceToUser(), let size = place?.size {
            let text: String
            if distance <= smallRadius {
                text = "less than 75ft"
                self.checkinMarkImageView.isHidden = false
                self.locationPinButton.setImage(#imageLiteral(resourceName: "location-pin"), for: .normal)
                if self.isCheckedIn {
                    self.isCheckedIn = false
                    self.checkIn {
                        
                    }
                }
            } else if distance <= mediumRadius && size == 2 {
                text = "less than 200ft"
                self.checkinMarkImageView.isHidden = false
                self.locationPinButton.setImage(#imageLiteral(resourceName: "location-pin"), for: .normal)
                if self.isCheckedIn {
                    self.isCheckedIn = false
                    self.checkIn {
                        
                    }
                }
            }  else if distance <= largeRadius  && size == 3 {
                text = "less than 500ft"
                self.checkinMarkImageView.isHidden = false
                self.locationPinButton.setImage(#imageLiteral(resourceName: "location-pin"), for: .normal)
                if self.isCheckedIn {
                    self.isCheckedIn = false
                    self.checkIn {
                        
                    }
                }
            } else if distance <= hugeRadius  && size == 4 {
                text = "less than 1000ft"
                self.checkinMarkImageView.isHidden = false
                self.locationPinButton.setImage(#imageLiteral(resourceName: "location-pin"), for: .normal)
                if self.isCheckedIn {
                    self.isCheckedIn = false
                    self.checkIn {
                        
                    }
                }
            } else {
                self.checkinMarkImageView.isHidden = true
                self.locationPinButton.setImage(#imageLiteral(resourceName: "location-pin"), for: .normal)
                let ft = distance * 3.28084
                
                if ft >= 5280 {
                    text = "\(Int(ft / 5280))mi."
                }else {
                    text = "\(Int(distance * 3.28084))ft."
                }
                
                if self.isCheckedIn {
                    self.checkout()
                }
            }
            
            self.placeDistanceLabel.text = text
            
            if (place?.early)! > 0 {
                self.checkinMarkImageView.isHidden = false
                self.locationPinButton.setImage(#imageLiteral(resourceName: "location-pin"), for: .normal)
            }
        }
    }
    
    func getUserFriends() {
        facebookService.getUserFriends(success: {[weak self] (friends: [FacebookFriend]) in
            self?.faceBookFriends = friends
            }, failure: { (error) in
//                self?.alert(message: error)
                print(error)
        })
    }
    
    func getCheckedInFriends() -> [FacebookFriend] {
        let fbIds = self.checkinWithExpectUser.flatMap({$0.fbId})
        let friendCheckins = self.faceBookFriends.filter({fbIds.contains($0.id)})
        return friendCheckins
    }
    
    func changeGoingStatus() {
        let text = "\(goingWithExpectUser.count) Going"
        self.goingStatusLabel.text = text
        
        if self.goingData.count > 0 && isGoing {
            self.eventAction = .goingSwipe
        }
        
        self.checkinMarkImageView.isHidden = !isGoing
        
        if self.goingData.count > 0 {
            let fbIds = self.faceBookFriends.map({$0.id})
            let friendCheckins = goingData.filter({fbIds.contains($0.fbId!)})
            
            if friendCheckins.count > 0 {
                let text = "including \(friendCheckins.count) FF's"
                self.includingFriendsLabel.text = text
            } else {
                self.includingFriendsLabel.text = ""
            }
        } else {
            self.includingFriendsLabel.text = ""
        }
        self.friendsCollectionView.reloadData()
    }
    
    func getCheckedinUsers() {
        self.activityIndicator.startAnimating()
        if let authUserId = self.authenticator.user?.id {
            UserService().expectUserIdsOfacceptList(userId: authUserId, completion: { [weak self] (userIds) in
                self?.exceptedUsers = userIds
                self?.placeService.getCheckInUsers(at: (self?.place)!, completion: {[weak self] (checkins) in
                    self?.activityIndicator.stopAnimating()
                    
                    self?.checkinWithExpectUser = checkins.filter({(checkin) -> Bool in
                        if let checkInUserId = checkin.userId, let authUserId = self?.authenticator.user?.id, let checkinTime = checkin.time {
                            // return true
                            
                            let checkTimeValid = checkInUserId != authUserId && (Date().timeIntervalSince1970 - checkinTime) < checkInThreshold
                            return checkTimeValid
                        }
                        return false
                    })
                    }, failure: {[weak self] error in
                        self?.activityIndicator.stopAnimating()
//                        self?.alert(message: error.localizedDescription)
                })
                
            })
        }
    }
    
    func getGoingUsers() {
        self.activityIndicator.startAnimating()
        if let authUserId = self.authenticator.user?.id {
            UserService().expectUserIdsOfacceptList(userId: authUserId, completion: { [weak self] (userIds) in
                self?.exceptedUsers = userIds
                self?.placeService.getGoingUsers(at: (self?.place)!, completion: {[weak self] (checkins) in
                    self?.activityIndicator.stopAnimating()
                    
                    self?.goingWithExpectUser = checkins
                    
                    }, failure: {[weak self] error in
                        self?.activityIndicator.stopAnimating()
                        //                        self?.alert(message: error.localizedDescription)
                })
                
            })
        }
    }
    
    func getAllCheckedInUsers(data : [Checkin]) {
        var acknowledgedCount = 0 {
            didSet {
                if acknowledgedCount == self.checkinData.count {
                    self.activityIndicator.stopAnimating()
                }
            }
        }
        acknowledgedCount = 0
        
        let userIdsSet = Set(data.flatMap({$0.userId}))
        userIdsSet.forEach { (userId) in
            
            UserService().getUser(withId: userId, completion: { [weak self] (user, error) in
                
                if let _ = error {
//                    self?.alert(message: error.localizedDescription)
                    return
                }
                
                if let user = user {
                    if let index = self?.checkinUsers.index(of: user) {
                        self?.checkinUsers[index] = user
                    }else {
                        self?.checkinUsers.append(user)
                    }
                }
            })
            acknowledgedCount += 1
        }
    }

    func getAllGoingUsers(data : [Checkin]) {
        var acknowledgedCount = 0 {
            didSet {
                if acknowledgedCount == self.goingData.count {
                    self.activityIndicator.stopAnimating()
                }
            }
        }
        acknowledgedCount = 0
        
        let userIdsSet = Set(data.flatMap({$0.userId}))
        userIdsSet.forEach { (userId) in
            
            UserService().getUser(withId: userId, completion: { [weak self] (user, error) in
                
                if let _ = error {
                    //                    self?.alert(message: error.localizedDescription)
                    return
                }
                
                if let user = user {
                    if let index = self?.checkinUsers.index(of: user) {
                        self?.goingUsers[index] = user
                    }else {
                        self?.goingUsers.append(user)
                    }
                }
            })
            acknowledgedCount += 1
        }
    }
    
    func getDistanceToUser() -> Double? {
        if let lat = self.place?.lat, let lon = place?.long, let distance = SlydeLocationManager.shared.distanceFromUser(lat: lat, long: lon) {
            return distance
        }
        return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openMap" {
            let destinationVC = segue.destination as! PlaceToUserMapViewController
            destinationVC.place = self.place
        }else if segue.identifier == "Categories" {
            let destinationVC = segue.destination as! CategoriesViewController
            
            destinationVC.place = self.place
            destinationVC.noUsers = {
                self.eventAction = .checkIn
                self.changeGoingStatus()
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
        let appLinkUrl:URL = URL(string: GlobalConstants.urls.itunesLink)!
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
        return  self.checkinUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let user = self.checkinUsers[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "friendsCell", for: indexPath)
        
        let label = cell.viewWithTag(2) as! UILabel
//        label.text = "Dari"
        label.text = user.profile.firstName
        label.layer.shadowOpacity = 1
        label.layer.shadowRadius = 3
        label.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.rounded()
//        imageView.image = UIImage(named: "profile.png")
        imageView.kf.setImage(with: user.profile.images.first)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "categoryDetailViewController") as! CategoriesViewController
        vc.fromFBFriends = self.checkinUsers[indexPath.row]
        vc.transitioningDelegate = self
        self.present(vc, animated: true, completion: nil)
//        if let nav = self.navigationController {
//            nav.present(vc, animated: true, completion: nil)
//        }
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

