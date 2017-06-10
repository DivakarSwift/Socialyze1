//
//  ChatListViewController.swift
//  Slide
//
//  Created by bibek timalsina on 4/20/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit
import MessageUI
import FacebookCore
import FacebookShare

class ChatListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inviteButton: UIButton!
    
    @IBOutlet weak var squadfooterView: UIView!
    
    let userService = UserService()
    let facebookService = FacebookService.shared
    fileprivate var me = Authenticator.shared.user
    private var faceBookFriends = [FacebookFriend]() {
        didSet {
            self.getAllUsers()
        }
    }
    var blockedUserIds:[String]? {
        didSet {
            if let ids = blockedUserIds, ids.count > 0 {
                self.chatUsers = self.chatUsers.filter({ (user) -> Bool in
                    return !ids.contains(user.id!)
                })
            }
        }
    }
    
    var matchedUserIds:[String] = [] {
        didSet {
            self.getBlockIds()
        }
    }
    
    var chatUsers = [LocalUser]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    lazy fileprivate var activityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: "ladybird.png")!
        return CustomActivityIndicatorView(image: image)
    }()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.inviteButton.rounded()
        self.tableView.dataSource = self
        self.tableView.delegate = self
//        self.tableView.tableFooterView = squadfooterView
        self.activityIndicator.center = self.view.center
        self.view.addSubview(self.activityIndicator)
        getUserFriends()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "My Squad"
        self.navigationController?.navigationBar.isHidden = false
        self.fetchMatchIds()
    }
    
    // MARK: Methods
    
    func getAllUsers() {
        self.activityIndicator.startAnimating()
        userService.getAllUser { (users) in
            self.activityIndicator.stopAnimating()
            print("Total number of user :\(users.count)")
            let fbIds = self.faceBookFriends.flatMap({$0.id})
            let chatuserss = users.filter({(user) -> Bool in
                if let fbId = user.profile.fbId {
                    return fbIds.contains(fbId)
                }
                return false
            })
            self.chatUsers = chatuserss.filter({(user) -> Bool in
                if let userID = user.id, let blockedIds = self.blockedUserIds {
                    return !blockedIds.contains(userID)
                }
                return true
            })
            self.fetchMatchIds()
        }
    }
    
    func getBlockIds() {
        self.activityIndicator.startAnimating()
        userService.getBlockedIds(of: me!) { (ids, error) in
            self.activityIndicator.stopAnimating()
                self.blockedUserIds = ids
            if error != nil {
                self.alert(message: GlobalConstants.Message.oops)
            }
        }
    }
    
    func fetchMatchIds() {
        self.activityIndicator.startAnimating()
        userService.getMatchedIds(of: me!) { (ids, error) in
            self.activityIndicator.stopAnimating()
            self.matchedUserIds = ids
        }
    }
    
    func getUserFriends() {
        self.activityIndicator.startAnimating()
        facebookService.getUserFriends(success: {[weak self] (friends: [FacebookFriend]) in
            self?.activityIndicator.stopAnimating()
            self?.faceBookFriends = friends
            let friendsCount = self?.faceBookFriends.count
            print("Total number of facebook friends :\(String(describing: friendsCount))")
            }, failure: { (error) in
                self.activityIndicator.stopAnimating()
                self.alert(message: error)
                print(error)
        })
    }
    
    // MARK: - Invite Action
    @IBAction func inviteButton(_ sender: UIButton) {
        self.showMoreOption()
    }

    // More option
    private func showMoreOption() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let facebook = UIAlertAction(title: "Facebook", style: .default) { [weak self] (_) in
            self?.openFacebookInvite()
            self?.alert(message: "Coming Soon!")
        }
        alert.addAction(facebook)
        
        let textMessage = UIAlertAction(title: "Text Message", style: .default) { [weak self] (_) in
            self?.openMessage()
        }
        alert.addAction(textMessage)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func openMessage() {
        let text = "Hey! Meet me with https://itunes.apple.com/us/app/socialyze/id1239571430?mt=8 "
        
        
        if !MFMessageComposeViewController.canSendText() {
            // For simulator only.
            let messageURL = URL(string: "sms:body=\(text)")
            guard let url = messageURL else {
                return
            }
            
            if UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        } else {
            let controller = MFMessageComposeViewController()
            controller.messageComposeDelegate = self
            controller.body = text
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func openFacebookInvite() {
        
        
        // Please change this two urls accordingly
//        let appLinkUrl:URL = URL(string: "https://itunes.apple.com/us/app/socialyze/id1239571430?mt=8")!
        let appLinkUrl:URL = URL(string: GlobalConstants.urls.itunesLink)!
        
        let previewImageUrl:URL = URL(string: "http://socialyzeapp.com/wp-content/uploads/2017/03/logo-128p.png")!
        
        var inviteContent:AppInvite = AppInvite.init(appLink: appLinkUrl)
        inviteContent.previewImageURL = previewImageUrl
        
        
        let inviteDialog = AppInvite.Dialog(invite: inviteContent)
        do {
            try inviteDialog.show()
        } catch  (let error) {
            print(error.localizedDescription)
        }
    }
}

//extension ChatListViewController: FBSDKAppInviteDialogDelegate {
//    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [NSObject : AnyObject]!) {
//        
//        let resultObject = NSDictionary(dictionary: results)
//        
//        if let didCancel = resultObject.valueForKey("completionGesture")
//        {
//            if didCancel.caseInsensitiveCompare("Cancel") == NSComparisonResult.OrderedSame
//            {
//                print("User Canceled invitation dialog")
//            }
//        }
//        
//    }
//    
//    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError!) {
//        print("Error tool place in appInviteDialog \(error)")
//    }
//
//}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatUsers.count <= 0 ? 1 : chatUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if chatUsers.count <= 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatList", for: indexPath)
        
        let nameLabel = cell.viewWithTag(2) as! UILabel
        nameLabel.text = self.chatUsers[indexPath.row].profile.name ?? "Facebook User"
        
        let checkInLabel = cell.viewWithTag(3) as! UILabel
        if let time = self.chatUsers[indexPath.row].checkIn?.time, (Date().timeIntervalSince1970 - time) < checkInThreshold, let val = self.chatUsers[indexPath.row].checkIn?.place {
            
            // By palceID
            if let placeID = self.chatUsers[indexPath.row].checkIn?.placeID {
                let checkId = ((placeID == "ChIJ6_-8ziWPOIgRSQzt9UEhOmI") || (placeID == "ChIJnRvS7biOOIgR8WzprZwSklE") || (placeID == "ChIJCcOQ6COPOIgRcLEuZixc9Wk") || (placeID == "ChIJMQsDsZqOOIgReHL17_Uf2Hg") || (placeID == "ChIJVX_yAZSOOIgRpZhJFs2DSUs"))
                checkInLabel.text = checkId ? "Joined event @ \(val)" : "@ \(val)"
            }
            
            // By Name
            else {
                let check = ((val == "Nationwide Arena") || (val == "Newport Music Hall") || (val == "Express Live!") || (val == "Schottenstein Center") || (val == "Ohio Stadium"))
                checkInLabel.text = check ? "Joined event @ \(val)" : "@ \(val)"
            }
            
        } else {
            checkInLabel.text = ""
        }
        print("\(indexPath.count) and \(indexPath.row) and \(chatUsers.count)")
        
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.rounded()
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: self.chatUsers[indexPath.row].profile.images.first)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if chatUsers.count <= 0 || (indexPath.row >= chatUsers.count){
            return
        }
        let vc = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        
        var val = ChatItem()
        if let friend = self.chatUsers[indexPath.row].id, let me = self.me?.id {
            let chatId =  friend > me ? friend+me : me+friend
            val.chatId = chatId
            val.userId = friend
        }
        vc.fromSquad = true
        vc.chatItem = val
        vc.chatUser = self.chatUsers[indexPath.row]
        vc.chatUserName = self.chatUsers[indexPath.row].profile.firstName ?? ""
        vc.chatOppentId = self.chatUsers[indexPath.row].id
        
        if let nav =  self.navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            self.present(vc, animated: true, completion: {
                
            })
        }
    }
    
    // MARK: Remove cell option and action
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Unmatch"
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if chatUsers.count <= 0 || (indexPath.row >= chatUsers.count) {
            return false
        }
        else if let id = self.chatUsers[indexPath.row].id, (self.matchedUserIds.contains(id)) {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        self.alertWithOkCancel(message: "Are you Sure?", title: "Alert", okTitle: "Ok", cancelTitle: "Cancel", okAction: { _ in
            self.unMatch(user: self.chatUsers[indexPath.row])
        }, cancelAction: nil)
    }

    func unMatch(user: LocalUser) {
        self.activityIndicator.startAnimating()
        var val = ChatItem()
        if let friend = user.id, let me = Authenticator.shared.user?.id {
            let chatId =  friend > me ? friend+me : me+friend
            val.chatId = chatId
            val.userId = friend
        }
        
        guard let opponetId = val.userId, let myId = Authenticator.shared.user?.id, let chatId = val.chatId else {
            self.activityIndicator.stopAnimating()
            self.alert(message: "Something went wrong. Please try again later.", title: "Oops", okAction: nil)
            return
        }
        
        self.userService.unMatch(opponent: opponetId, withMe: myId, chatId: chatId, completion: { (success, error) in
            self.activityIndicator.stopAnimating()
            if success {
                var message = "Unmatched"
                if let name = user.profile.firstName {
                    message = message + " " + name
                }
                self.alert(message: message, title: "Success", okAction: {
                    _ = self.navigationController?.popViewController(animated: true)
                })
            } else {
                self.alert(message: GlobalConstants.Message.oops)
            }
        })
    }
}

extension ChatListViewController : MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        controller.dismiss(animated: true, completion: nil)
    }
}
