//
//  PlaceDetailViewController.swift
//  Slide
//
//  Created by bibek timalsina on 4/8/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit

class PlaceDetailViewController: UIViewController {
    
    @IBOutlet weak var placeNameAddressLbl: UILabel!
    @IBOutlet weak var placeDetailLbl: UILabel!
    @IBOutlet weak var checkInStatusLabel: UILabel!
    @IBOutlet weak var placeImageView: UIImageView!
    
    var place: Place?
    
    let thresholdRadius = 30.48 //100ft
    let checkInThreshold: TimeInterval = 5*60 //min
    
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
            self.changeStatus()
        }
    }
    
    private var checkInKey: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.observe(selector: #selector(self.locationUpdated), notification: GlobalConstants.Notification.newLocationObtained)
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
    }
    
    deinit {
        SlydeLocationManager.shared.stopUpdatingLocation()
    }
    
    @IBAction func checkIn(_ sender: UIButton) {
        if let distance = self.getDistanceToUser(), distance <= thresholdRadius {
            self.checkIn {[weak self] in
                self?.performSegue(withIdentifier: "Categories", sender: self)
            }
        }else {
            self.alert(message: GlobalConstants.Message.userNotInPerimeter)
        }
        
        // REMOVE on deployment
        //        self.checkIn {[weak self] in
        //            self?.performSegue(withIdentifier: "Categories", sender: self)
        //        }
    }
    
    private func checkout() {
        self.placeService.user(authenticator.user!, checkOutFrom: self.place!) {[weak self] (success, error) in
            self?.isCheckedIn = !success
            print(error)
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
                    Timer.scheduledTimer(timeInterval: 120, target: me, selector: #selector(me.recheckin), userInfo: nil, repeats: false)
                }
            }
            
            print(error)
            print("CHECKED IN")
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
                    text = "at \(Int(ft / 5280))mi"
                }else {
                    text = "at \(Int(distance * 3.28084))ft"
                }
                
                if self.isCheckedIn {
                    self.checkout()
                }
            }
            self.placeNameAddressLbl.text = self.place!.nameAddress + " (\(text))"
        }
    }
    
    func getUserFriends() {
        facebookService.getUserFriends(success: {[weak self] (friends: [FacebookFriend]) in
            self?.faceBookFriends = friends
            }, failure: { [weak self] (error) in
                self?.alert(message: error)
        })
    }
    
    func changeStatus() {
        if self.checkinData.count > 0 {
            let fbIds = self.faceBookFriends.map({$0.id})
            let friendCheckins = checkinData.filter({fbIds.contains($0.fbId!)})
            var text = "\(checkinData.count) people are checked in"
            text = text + (friendCheckins.count > 0 ? "including your \(friendCheckins.count) friends " : "")
            self.checkInStatusLabel.text = text
        }else {
            self.checkInStatusLabel.text = ""
        }
    }
    
    func getCheckedinUsers() {
        placeService.getCheckInUsers(at: self.place!, completion: {[weak self] (checkin) in
            self?.checkinData = checkin.filter({(checkin) -> Bool in
                if let checkInUserId = checkin.userId, let authUserId = self?.authenticator.user?.id, let checkinTime = checkin.time, let checkInThreshold = self?.checkInThreshold {
                    // return true
                    return checkInUserId != authUserId && (Date().timeIntervalSince1970 - checkinTime) < checkInThreshold
                }
                return false
            })
            }, failure: {[weak self] error in
                
        })
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
