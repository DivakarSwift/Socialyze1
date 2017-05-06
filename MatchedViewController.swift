//
//  MatchedViewController.swift
//  Slide
//
//  Created by rajendra karki on 5/4/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit
import Foundation


class MatchedViewController : UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    var friend: User?
    var chatItem :ChatItem? {
        didSet {
            if let user = self.friend {
                self.profileImageView.kf.setImage(with: user.profile.images.first)
            }
        }
    }
    
    let chatService = ChatService.shared
    
    var backToCheckIn:((ChatItem?) -> ())?
    
    override func viewDidLoad() {
        
        self.profileImageView.rounded()
        if let user = self.friend {self.profileImageView.kf.setImage(with: user.profile.images.first)
        }
        self.fetchChatItem()
    }
        
    func fetchChatItem() {
        if let user = Authenticator.shared.user {
            chatService.getLastMessage(of: user, forUserId: (self.friend?.id)!, completion: { (chatItem, error) in
                if error == nil {
                    self.chatItem = chatItem
                } else {
                    print(error?.localizedDescription ?? "Firebase Authentication error!")
                }
            })
        }
    }
    
    @IBAction func resumeSwiping(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.backToCheckIn?(nil)
        })
    }
    
    
    @IBAction func startChat(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.backToCheckIn?(self.chatItem)
        })
    }
    
}
