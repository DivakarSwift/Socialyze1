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
    
    func setup() {
        senderImageView.rounded()
        if let url = user?.profile.images.first {
            self.senderImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "profileicon"))
        }else {
            self.senderImageView.image = #imageLiteral(resourceName: "profileicon")
        }
        self.messageLabel.text = activity?.message
    }
}
