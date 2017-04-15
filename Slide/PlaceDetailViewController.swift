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
    
    let facebookService = FacebookService.shared
    private let authenticator = Authenticator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.observe(selector: #selector(self.locationUpdated), notification: GlobalConstants.Notification.newLocationObtained)
        self.placeImageView.image = place?.secondImage ?? place?.mainImage
        self.placeNameAddressLbl.text = place?.nameAddress
        self.locationUpdated()
        
        if facebookService.isUserFriendsPermissionGiven() {
            getUserFriends()
        }else {
            authenticator.delegate = self
            authenticator.authenticateWith(provider: .facebook)
        }
    }
    
    func locationUpdated() {
        if let distance = getDistanceToUser() {
            let text: String
            if distance <= thresholdRadius { // 100 ft
                text = "less than 100ft"
            }else {
                let ft = distance * 3.28084
                
                if ft >= 5280 {
                    text = "at \(Int(ft / 5280))mi"
                }else {
                    text = "at \(Int(distance * 3.28084))ft"
                }
            }
            self.placeNameAddressLbl.text = self.place!.nameAddress + " (\(text))"
        }
    }
    
    func getUserFriends() {
        facebookService.getUserFriends(failure: { [weak self] (error) in
            self?.alert(message: error)
        })
    }
    
    func getDistanceToUser() -> Double? {
        if let place = self.place, let distance = SlydeLocationManager.shared.distanceFromUser(lat: place.lat, long: place.long) {
            return distance
        }
        return nil
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "Categories" {
            if let distance = self.getDistanceToUser(), distance <= thresholdRadius {
                return true
            }else {
                self.alert(message: GlobalConstants.Message.userNotInPerimeter)
                return false
            }
        }
        return super.shouldPerformSegue(withIdentifier: identifier, sender: sender)
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
