//
//  ChatListViewController.swift
//  Slide
//
//  Created by bibek timalsina on 4/20/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit

class ChatListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
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
    
    var chatUsers = [User]() {
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
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        self.activityIndicator.center = self.view.center
        self.view.addSubview(self.activityIndicator)
        getUserFriends()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Chat"
        self.navigationController?.navigationBar.isHidden = false
        self.getBlockIds()
    }
    
    // MARK: Methods
    func fetchMatchList() {
        if let user = Authenticator.shared.user {
            userService.getMatchListUsers(of: user, completion: { (users, error) in
                if let users = users {
                    self.chatUsers = users
                } else {
                    self.fetchMatchList()
                }
                if error != nil {
                    self.alert(message: "Unable to fetch data.", title: "Error", okAction: {
                        _ = self.navigationController?.popViewController(animated: true)
                    })
                }
            })
        }
    }
    
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
            self.getBlockIds()
        }
    }
    
    func getBlockIds() {
        userService.getBlockedIds(of: me!) { (ids, error) in
                self.blockedUserIds = ids
            if error != nil {
                self.alert(message: GlobalConstants.Message.oops)
            }
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
    
}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatUsers.count <= 0 ? 1 :chatUsers.count
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
            checkInLabel.text = "@ \(val)"
        } else {
            checkInLabel.text = ""
        }
        
        
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
        if chatUsers.count <= 0 {
            return
        }
        let vc = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        
        var val = ChatItem()
        if let friend = self.chatUsers[indexPath.row].id, let me = self.me?.id {
            let chatId =  friend > me ? friend+me : me+friend
            val.chatId = chatId
            val.userId = friend
        }
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
//    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
//        return "Unmatch"
//    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if chatUsers.count <= 0 {
            return false
        }
        if let time = self.chatUsers[indexPath.row].checkIn?.time {
            let check = (Date().timeIntervalSince1970 - time) > checkInThreshold
            return check
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        unMatch(user: self.chatUsers[indexPath.row])
    }
    
    func unMatch(user: User) {
        self.activityIndicator.startAnimating()
        var val = ChatItem()
        if let friend = user.id, let me = self.me?.id {
            let chatId =  friend > me ? friend+me : me+friend
            val.chatId = chatId
            val.userId = friend
        }
        
        guard let opponetId = val.userId, let myId = self.me?.id, let chatId = val.chatId else {
            self.activityIndicator.stopAnimating()
            self.alert(message: "Something went wrong. Please try again later.", title: "Oops", okAction: nil)
            return
        }
        
        userService.unMatch(opponent: opponetId, withMe: myId, chatId: chatId, completion: { (success, error) in
            if success {
                self.userService.block(user: user, myId: myId, completion: { (success, error) in
                    if success {
                        self.userService.getBlockedIds(of: self.me!, completion: { (ids, error) in
                            self.activityIndicator.stopAnimating()
                            if error != nil {
                                self.alert(message: GlobalConstants.Message.oops)
                            } else {
                                self.blockedUserIds = ids
                            }
                        })
                        var message = "Successfully removed user"
                        if let name = user.profile.firstName {
                            message = message + " " + name
                         }
                        self.alert(message: message, title: "Success", okAction: {
                            self.tableView.reloadData()
                        })
                        
                    } else {
                        self.activityIndicator.stopAnimating()
                        self.alert(message: GlobalConstants.Message.oops)
                    }
                    
                })
                
            } else {
                self.activityIndicator.stopAnimating()
                self.alert(message: GlobalConstants.Message.oops)
            }
        })
    }
    
}
