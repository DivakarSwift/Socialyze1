//
//  FriendCheckinPlaceCollectionViewCell.swift
//  Slide
//
//  Created by bibek timalsina on 10/13/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit

class FriendCheckinPlaceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var backgroundProfileImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastCheckinPlaceLabel: UILabel!
    
    var chatUser: LocalUser?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profileImageView.rounded()
        self.backgroundProfileImageView.rounded()
        self.profileImageView.set(borderWidth: 2, of: UIColor.white)
    }
    
    func setup() {
        self.profileImageView.image = #imageLiteral(resourceName: "profileicon")
        self.backgroundProfileImageView.image = #imageLiteral(resourceName: "profileicon")
        if let url = self.chatUser?.profile.images.first {
            self.profileImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "profileicon"), completionHandler: { (image, error, _, _) in
                if let image = image {
                    self.backgroundProfileImageView.image = image
                }
            })
        }else {
            self.profileImageView.image = #imageLiteral(resourceName: "profileicon")
            self.backgroundProfileImageView.image = #imageLiteral(resourceName: "profileicon")
        }
        
        self.nameLabel.text = self.chatUser?.profile.name
        self.lastCheckinPlaceLabel.text = self.chatUser?.checkIn?.place
    }
    
}
