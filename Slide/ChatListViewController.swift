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
    
    var chatList = [ChatItem]()
    
    var chatUsers = [User]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    let chatService = ChatService.shared
    let userService = UserService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        fetchChatList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func fetchChatList() {
        if let user = Authenticator.shared.user {
            chatService.getChatListAndObserve(of: user, completion: {[weak self] (chatItem, error) in
                if error == nil {
                    if let item = chatItem {
                        self?.chatList.append(item)
                    }
                    if let chatUserId = chatItem?.userId {
                        self?.userService.getUser(withId: chatUserId, completion: { [weak self](user, error) in
                            if let user = user {
                                if let index = self?.chatUsers.index(of: user) {
                                    self?.chatUsers[index] = user
                                }else {
                                    self?.chatUsers.append(user)
                                }
                            }
                        })
                    }
                } else {
                    print(error?.localizedDescription ?? "Firebase Fetch error")
                    
                }
            })
        }
    }
}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatList.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatList", for: indexPath)
        
        let label = cell.viewWithTag(2) as! UILabel
        label.text = chatUsers[indexPath.row].profile.name ?? "somebody"
        
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.rounded()
        imageView.kf.setImage(with: chatUsers[indexPath.row].profile.images.first, placeholder: #imageLiteral(resourceName: "profile.png"), options: nil, progressBlock: nil, completionHandler: nil)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        vc.chatItem = self.chatList[indexPath.row]
        vc.chatUserName = self.chatUsers[indexPath.row].profile.name ?? ""
        vc.chatOppentId = self.chatUsers[indexPath.row].id
        vc.chatUser = self.chatUsers[indexPath.row]
        if let nav =  self.navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            self.present(vc, animated: true, completion: {
                
            })
        }
    }
    
}
