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
    @IBOutlet weak var agoTime: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
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
        backgroundImage.rounded()
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
        self.backgroundImage.image = #imageLiteral(resourceName: "profileicon")
        if let url = user?.profile.images.first {
            self.senderImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "profileicon"), completionHandler: { (image, _, _, _) in
                self.backgroundImage.image = image
            })
        }else {
            self.senderImageView.image = #imageLiteral(resourceName: "profileicon")
        }
        let messageFont = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
        
        let message = NSMutableAttributedString(string: activity?.message ?? "", attributes: [NSFontAttributeName: messageFont])
        if let additionalMessage = activity?.additionalMessage, !additionalMessage.isEmpty {
            let additionalMessageFont = UIFont.systemFont(ofSize: 14)
            let attributedMessage = NSAttributedString(string: "\n\(additionalMessage)", attributes: [NSFontAttributeName: additionalMessageFont])
            message.append(attributedMessage)
        }
        
        self.messageLabel.attributedText = message
        
        if let timeInterval = activity?.time {
            let date = Date.init(timeIntervalSince1970: timeInterval)
            let ago = date.ago(from: Date())
            self.agoTime.text = ago
        }else {
            self.agoTime.text = "sometime ago."
        }
    }
}
