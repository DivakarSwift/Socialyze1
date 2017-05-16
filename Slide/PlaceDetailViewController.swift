//
//  PlaceDetailViewController.swift
//  Slide
//
//  Created by bibek timalsina on 4/8/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

let checkInThreshold: TimeInterval = 3*60*60 //3hr

class PlaceDetailViewController: UIViewController {
    
    @IBOutlet weak var placeNameAddressLbl: UILabel!
    @IBOutlet weak var placeDetailLbl: UILabel!
    @IBOutlet weak var checkInStatusLabel: UILabel!
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var checkInButton: UIButton!
    
    //    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var friendsCollectionView: UICollectionView!
    
    var place: Place?
    
    let smallRadius = 15.24 // 50ft, probably
    let mediumRadius = 30.48 // 100ft
    let largeRadius = 152.4 // 500ft, probably
    let hugeRadius = 304.8 // 1000ft, probably
    var thresholdRadius = 30.48 //100ft
    
    let SNlat1 = 39.984467
    let SNlong1 = -83.004969
    let SNlat2 = 39.979144
    let SNlong2 = -83.003942
    let SNlat3 = 39.973620
    let SNlong3 = -83.003916
    
    private var isCheckedIn = false
    
    let facebookService = FacebookService.shared
    private let authenticator = Authenticator.shared
    private let placeService = PlaceService()
    private var faceBookFriends = [FacebookFriend]() {
        didSet {
            self.changeStatus()
        }
    }
    private var checkinData = [Checkin]() {
        didSet {
            self.activityIndicator.stopAnimating()
            self.changeStatus()
        }
    }
    
    var checkinUsers: [User] = [] {
        didSet {
            self.activityIndicator.stopAnimating()
            self.changeStatus()
        }
    }
    
    private var checkInKey: String?
    lazy fileprivate var activityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: "ladybird.png")!
        let activityIndicator = CustomActivityIndicatorView(image: image)
        return activityIndicator
    }()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.observe(selector: #selector(self.locationUpdated), notification: GlobalConstants.Notification.newLocationObtained)
        self.view.addSubview(activityIndicator)
        self.activityIndicator.center = view.center
        self.placeImageView.image = place?.secondImage ?? place?.mainImage
        self.placeNameAddressLbl.text = place?.nameAddress
        self.locationUpdated()
        
        SlydeLocationManager.shared.startUpdatingLocation()
        
        if facebookService.isUserFriendsPermissionGiven() {
            getUserFriends()
        }else {
            authenticator.delegate = self
            authenticator.authenticateWith(provider: .facebook)
        }
        
        getCheckedinUsers()
        //        friendsTableView.tableFooterView = UIView()
        self.setupCollectionView()
        
        //
        if (place?.early)! > 0 {
            checkInButton.setTitle("Join", for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.title = place?.nameAddress
    }
    
    deinit {
        SlydeLocationManager.shared.stopUpdatingLocation()
    }
    
    @IBAction func checkIn(_ sender: UIButton) {
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
        
        if let distance = self.getDistanceToUser(), distance <= thresholdRadius {
            self.checkIn {[weak self] in
                if self?.checkinData.count != 0 {
                    self?.performSegue(withIdentifier: "Categories", sender: self)
                }else {
                    self?.alert(message: "No new users at this time. Check back later")
                }
            }
        } else if thresholdRadius == 0 && (SlydeLocationManager.shared.distanceFromUser(lat: SNlat1, long: SNlong1)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: SNlat2, long: SNlong2)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: SNlat3, long: SNlong3)! < hugeRadius){
            self.checkIn {[weak self] in
                if self?.checkinData.count != 0 {
                    self?.performSegue(withIdentifier: "Categories", sender: self)
                }else {
                    self?.alert(message: "No new users at this time. Check back later")
                }
            }
        } else if (place?.early)! > 0 {
            self.checkIn {[weak self] in
                if self?.checkinData.count != 0 {
                    self?.performSegue(withIdentifier: "Categories", sender: self)
                }else {
                    self?.alert(message: "No new users at this time. Check back later")
                }
            }
        } else {
            self.alert(message: GlobalConstants.Message.userNotInPerimeter)
        }
        
        // REMOVE on deployment
        //        self.checkIn {[weak self] in
        //            self?.performSegue(withIdentifier: "Categories", sender: self)
        //        }
    }
    
    @IBAction func checkOut(_ sender: Any) {
        // IF user is checked in
        self.checkout()
    }
    
    private func checkout() {
        self.placeService.user(authenticator.user!, checkOutFrom: self.place!) {[weak self] (success, error) in
            self?.isCheckedIn = !success
            print(error ?? "Success user authenticator places")
            print("CHECKED OUT")
        }
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
    
    func recheckin() {
        SlydeLocationManager.shared.requestLocation()
    }
    
    func locationUpdated() {
        if let distance = getDistanceToUser() {
            let text: String
            if distance <= thresholdRadius { // 100 ft
                text = "less than 100ft"
                if self.isCheckedIn {
                    self.isCheckedIn = false
                    self.checkIn {
                        
                    }
                }
            }else {
                let ft = distance * 3.28084
                
                if ft >= 5280 {
                    text = "\(Int(ft / 5280))mi away."
                }else {
                    text = "\(Int(distance * 3.28084))ft away."
                }
                
                if self.isCheckedIn {
                    self.checkout()
                }
            }
            self.placeNameAddressLbl.text = /*self.place!.nameAddress + */" \(text)"
            self.placeNameAddressLbl.layer.shadowOpacity = 1.0
            self.placeNameAddressLbl.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            self.placeNameAddressLbl.layer.shadowRadius = 3.0
        }
    }
    
    func getUserFriends() {
        facebookService.getUserFriends(success: {[weak self] (friends: [FacebookFriend]) in
            self?.faceBookFriends = friends
            }, failure: { [weak self] (error) in
                self?.alert(message: error)
        })
    }
    
    func getCheckedInFriends() -> [FacebookFriend] {
        let fbIds = self.checkinData.flatMap({$0.fbId})
        let friendCheckins = self.faceBookFriends.filter({fbIds.contains($0.id)})
        return friendCheckins
    }
    
    func changeStatus() {
        if self.checkinData.count > 0 {
            let fbIds = self.faceBookFriends.map({$0.id})
            let friendCheckins = checkinData.filter({fbIds.contains($0.fbId!)})
            var text = "\(checkinData.count) checked in "
            if friendCheckins.count > 1 {
                text = text + (friendCheckins.count > 1 ? "including your \(friendCheckins.count) friends. " : "")
            } else {
                text = text + (friendCheckins.count > 0 ? "including your /(friendCheckins.count) friend. " : "")
            }
            self.checkInStatusLabel.text = text
        }else {
            self.checkInStatusLabel.text = ""
        }
        self.friendsCollectionView.reloadData()
    }
    
    func getCheckedinUsers() {
        self.activityIndicator.startAnimating()
        if let authUserId = self.authenticator.user?.id {
            UserService().expectUserIdsOfacceptList(userId: authUserId, completion: { [weak self] (userIds) in
                
                self?.placeService.getCheckInUsers(at: (self?.place)!, completion: {[weak self] (checkin) in
                    
                    self?.checkinData = checkin.filter({(checkin) -> Bool in
                        if let checkInUserId = checkin.userId, let authUserId = self?.authenticator.user?.id, let checkinTime = checkin.time {
                            // return true
                            if userIds.contains(checkInUserId) {
                                return false
                            }
                            let checkTimeValid = checkInUserId != authUserId && (Date().timeIntervalSince1970 - checkinTime) < checkInThreshold
                            return checkTimeValid
                        }
                        return false
                    })
                    
                    if let data = self?.checkinData {
                        self?.getAllCheckedInUsers(data : data)
                    }
                    
                    }, failure: {[weak self] error in
                        self?.activityIndicator.stopAnimating()
                        self?.alert(message: error.localizedDescription)
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
                
                if let error = error {
                    self?.alert(message: error.localizedDescription)
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

    
    func getDistanceToUser() -> Double? {
        if let place = self.place, let distance = SlydeLocationManager.shared.distanceFromUser(lat: place.lat, long: place.long) {
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
            let userIdsSet = Set(self.checkinData.flatMap({$0.userId}))
            destinationVC.place = self.place
            destinationVC.checkinUserIds = userIdsSet
        }
        return super.prepare(for: segue, sender: sender)
    }
}

extension PlaceDetailViewController: AuthenticatorDelegate {
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

extension PlaceDetailViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  self.checkinUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let user = self.checkinUsers[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "friendsCell", for: indexPath)
        
        let label = cell.viewWithTag(2) as! UILabel
//        label.text = "Dari"
        label.text = user.profile.firstName
        
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.rounded()
//        imageView.image = UIImage(named: "profile.png")
        imageView.kf.setImage(with: user.profile.images.first)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "categoryDetailViewController") as! CategoriesViewController
        vc.fromFBFriends = self.checkinUsers[indexPath.row]
        if let nav = self.navigationController {
            nav.pushViewController(vc, animated: true)
        }
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
