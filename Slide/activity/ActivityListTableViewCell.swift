//
//  ActivityListTableViewCell.swift
//  Slide
//
//  Created by bibek timalsina on 10/19/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit

class ActivityListTableViewCell: UITableViewCell {
    @IBOutlet weak var senderImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    var activity: ActivityModel? {
        didSet {
            setup()
        }
    }
    
    var user: LocalUser?
    
    var onImageTapped: ((LocalUser)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        senderImageView.rounded()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnImage))
        senderImageView.addGestureRecognizer(gesture)
        senderImageView.isUserInteractionEnabled = true
    }
    
    func tappedOnImage() {
        if let user = self.user {
            onImageTapped?(user)
        }
    }
    
    func setup() {
        
        if let url = user?.profile.images.first {
            self.senderImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "profileicon"))
        }else {
            self.senderImageView.image = #imageLiteral(resourceName: "profileicon")
        }
        self.messageLabel.text = activity?.message
    }
}
