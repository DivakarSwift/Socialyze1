//
//  EventAdsViewController.swift
//  Slide
//
//  Created by Rajendra on 6/27/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit

class EventAdsViewController: UIViewController {
    
    var place:Place?
    var checkinData:[Checkin]?
    var facebookFriends:[FacebookFriend] = [FacebookFriend]()

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var checkedInLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var facebookLabel: UILabel!
    
    override func viewDidLoad() {
        self.addSwipeGesture(toView: self.view)
        self.setupView()
        self.addTapGesture(toView: self.view)
    }
    
   
    
    // MARK: - Gesture
    func addTapGesture(toView view: UIView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        view.addGestureRecognizer(tap)
    }
    func handleTap(_ gesture: UITapGestureRecognizer) {
        dismiss(animated: false, completion: nil)
        UIApplication.shared.isStatusBarHidden = false
    }
    
    func setupView() {
        if let place = self.place {
            self.descriptionLabel.text = place.bio
            
            let image = place.secondImage ?? place.mainImage ?? ""
            self.imageView.kf.setImage(with: URL(string: image), placeholder: #imageLiteral(resourceName: "OriginalBug") )
        }
        
        if let count = self.checkinData?.count {
            self.checkedInLabel.text = "\(count) Checked In"
        }
        
        if let data =  self.checkinData {
            if data.count > 0 {
                let fbIds = self.facebookFriends.map{ $0.id }
                let friendCheckins = data.filter({fbIds.contains($0.fbId!)})
                
                if friendCheckins.count > 0 {
                    self.facebookLabel.isHidden = false
                    let text = "including \(friendCheckins.count) Friend(s)"
                    self.facebookLabel.text = text
                } else {
                    self.facebookLabel.isHidden = true
                    self.facebookLabel.text = ""
                }
            } else {
                self.facebookLabel.isHidden = true
                self.facebookLabel.text = ""
            }
        }
        
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

}
