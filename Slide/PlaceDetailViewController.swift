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
    
    var place: Places?
    
    let thresholdRadius = 30.48
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.observe(selector: #selector(self.locationUpdated), notification: GlobalConstants.Notification.newLocationObtained)
        self.placeImageView.image = place?.secondImage ?? place?.mainImage
        self.placeNameAddressLbl.text = place?.nameAddress
        self.locationUpdated()
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
