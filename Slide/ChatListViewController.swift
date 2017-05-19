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
    
    var chatUsers = [User]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    let userService = UserService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        fetchMatchList()
        
        /*
         Fine part:
         here get matched list usersID
         
         Diffult part:
         then check get checkin places of every userId with time of checkin
         filter the most recent check in place and get checkin place name.
         popualte table view
         
         fine part:
         get chatId and populate table with info "fetching lastest check in place"
         select to chat with that user
 
         */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
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
}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatUsers.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatList", for: indexPath)
        
        let nameLabel = cell.viewWithTag(2) as! UILabel
        nameLabel.text = self.chatUsers[indexPath.row].profile.firstName ?? "somebody"
        
        let checkInLabel = cell.viewWithTag(3) as! UILabel
        let userlastPlace = self.chatUsers[indexPath.row].checkIn?.place ?? ""
            checkInLabel.text = "@ \(userlastPlace)"
        
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
        let vc = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        
        var val = ChatItem()
        if let friend = self.chatUsers[indexPath.row].id, let me = Authenticator.shared.user?.id {
            let chatId =  friend > me ? friend+me : me+friend
            val.chatId = chatId
            val.userId = friend
        }
        vc.chatItem = val
        
        vc.chatUserName = self.chatUsers[indexPath.row].profile.firstName ?? ""
        vc.chatOppentId = self.chatUsers[indexPath.row].id
        
        if let nav =  self.navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            self.present(vc, animated: true, completion: {
                
            })
        }
    }
    
}
