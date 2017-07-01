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
    @IBOutlet weak var descriptionLabel: UILabel!
    
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
