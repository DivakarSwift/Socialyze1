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
        fetchChatList()
    }
    
    func fetchChatList() {
        if let user = Authenticator.shared.user {
            chatService.getChatListAndObserve(of: user, completion: {[weak self] (chatItem, error) in
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
            })
        }
    }
}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chatItem = chatList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatList", for: indexPath)
        
        let label = cell.viewWithTag(2)
        let imageView = cell.viewWithTag(1)
        return cell
    }
}
