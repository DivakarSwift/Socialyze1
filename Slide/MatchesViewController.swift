//
//  MatchesViewController.swift
//  Slide
//
//  Created by Salem Khan on 3/8/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit

class MatchesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    var chatItems:[ChatItem] =  [ChatItem]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    var acceptList:[User] =  [User]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    let chatService = ChatService.shared
    let userService = UserService()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchAcceptList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func fetchChatList() {
        if let user = Authenticator.shared.user {
            userService.getChatListAndObserve(of: user, completion: {[weak self] (chatItems, error) in
                if error == nil {
                    self?.chatItems = []
                    if let item = chatItems {
                        self?.chatItems = item
                    }
                } else {
                    print(error?.localizedDescription ?? "Firebase Fetch error")
                    
                }
            })
        }
    }
    
    func fetchUserForChatSelected(chatItem : ChatItem) -> User?{
        var chatUser:User?
        for data in self.acceptList {
            if chatItem.userId == data.id {
                chatUser = data
            }
        }
        if chatUser == nil {
            if let chatUserId = chatItem.userId {
                self.userService.getUser(withId: chatUserId, completion: { (user, error) in
                    if let val = user {
                        chatUser = val
                    }
                })
            }
        }
        return chatUser
    }
    
    func fetchAcceptList() {
        if let user = Authenticator.shared.user {
            userService.getAcceptListUsers(of: user, completion: {[weak self] (user, error) in
                if error == nil {
                    self?.acceptList = user!
                    self?.fetchChatList()
                } else {
                    print(error?.localizedDescription ?? "Firebase Fetch error")
                    
                }
            })
        }
    }
    
}

extension MatchesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return acceptList.count > 0 ? 147 : 70
        } else {
            return 60
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return acceptList.count > 0 ? 147 : 70
        } else {
            return 60
        }
    }
}

extension MatchesViewController: UITableViewDataSource {

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Connections"
        } else {
            return "Conversations"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return chatItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MatchesTableViewCell", for: indexPath) as! MatchesTableViewCell
            cell.users = acceptList
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "chatList", for: indexPath)
            
            let currentUser = self.fetchUserForChatSelected(chatItem: chatItems[indexPath.row])
            
            let label = cell.viewWithTag(2) as! UILabel
            label.text = currentUser?.profile.name ?? "somebody"
            
            let imageView = cell.viewWithTag(1) as! UIImageView
            imageView.rounded()
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: currentUser?.profile.images.first)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let vc = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            vc.chatItem = self.chatItems[indexPath.row]
            let currentUser = self.fetchUserForChatSelected(chatItem: chatItems[indexPath.row])
            vc.chatUserName = currentUser?.profile.name ?? ""
            vc.chatOppentId = currentUser?.id
            
            if let nav =  self.navigationController {
                nav.pushViewController(vc, animated: true)
            } else {
                self.present(vc, animated: true, completion: {
                    
                })
            }
        }
    }
}
