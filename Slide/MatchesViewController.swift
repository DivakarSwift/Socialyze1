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

    var chatItems:[ChatItem] =  [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    var matchList:[LocalUser] =  [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var matchListUserIds:[String] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    let chatService = ChatService.shared
    let userService = UserService()
    lazy fileprivate var activityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: "ladybird.png")!
        let activityIndicator = CustomActivityIndicatorView(image: image)
        return activityIndicator
    }()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.center = view.center
        self.fetchMatchUserIds()
        self.navigationItem.setHidesBackButton(false, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.fetchMatchUserIds()
        
        let rightButton: UIBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonClicked))
        self.navigationItem.leftBarButtonItem = rightButton
    }
    
    func backButtonClicked(_ button:UIBarButtonItem!){
        self.dismiss(animated: true, completion: {
            
        })
//        performSegue(withIdentifier: "unwindFromMatch", sender: nil)
    }
    
    func addSwipeGesture(toView view: UIView) {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe))
        gesture.direction = .left
        view.addGestureRecognizer(gesture)
    }
    
    @IBAction func didSwipe(_ sender: UISwipeGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    func fetchChatList() {
        if let user = Authenticator.shared.user {
            self.activityIndicator.startAnimating()
            userService.getChatListAndObserve(of: user, completion: {[weak self] (chatItems, error) in
                self?.activityIndicator.stopAnimating()
                if error == nil {
                    self?.chatItems = []
                    if let item = chatItems {
                        let x = item.filter({ (item) -> Bool in
                            return self?.matchListUserIds.contains(item.inUser!) ?? false
                        })
                        self?.chatItems = x
                    }
                } else {
                    print(error?.localizedDescription ?? "Firebase Fetch error")
                }
            })
        }
    }
    
    func fetchUserForChatSelected(chatItem : ChatItem) -> LocalUser?{
        var chatUser:LocalUser?
        for data in self.matchList {
            if chatItem.inUser == data.id {
                chatUser = data
            }
        }
        if chatUser == nil {
            if let chatUserId = chatItem.inUser {
                self.userService.getUser(withId: chatUserId, completion: { (user, error) in
                    if let val = user {
                        chatUser = val
                        self.tableView.reloadData()
                    }
                })
            }
        }
        return chatUser
    }
    
    func fetchMatchUserIds() {
        if let user = Authenticator.shared.user {
            self.activityIndicator.startAnimating()
            userService.getMatchedIds(of: user, completion: { [weak self] (ids, error) in
                
                self?.activityIndicator.stopAnimating()
                self?.matchListUserIds = ids
                self?.fetchMatchList()
            })
        }
    }
    
    func fetchMatchList() {
        if let user = Authenticator.shared.user {
            self.activityIndicator.startAnimating()
            userService.getMatchListUsers(of: user, completion: {[weak self] (user, error) in
                self?.activityIndicator.stopAnimating()
                if error == nil {
                    self?.matchList = user!
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
            return matchList.count > 0 ? 147 : 70
        } else {
            return 60
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return matchList.count > 0 ? 147 : 70
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
            return ""
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
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.black
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        //header.textLabel?.textColor = UIColor(red: 162.0/255.0, green: 11.0/255.0, blue: 35.0/255.0, alpha: 1.0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MatchesTableViewCell", for: indexPath) as! MatchesTableViewCell
            cell.users = matchList
            cell.itemSelected = { user in
                self.openChat(forUser: user)
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "chatList", for: indexPath)
            
            let currentUser = self.fetchUserForChatSelected(chatItem: chatItems[indexPath.row])
            
            let label = cell.viewWithTag(2) as! UILabel
            label.text = currentUser?.profile.firstName ?? "somebody"
            
            let messageLabel = cell.viewWithTag(3) as! UILabel
            if let message = self.chatItems[indexPath.row].lastMessage {
                messageLabel.text = message
            }
            
            let imageView = cell.viewWithTag(1) as! UIImageView
            imageView.rounded()
            imageView.kf.indicatorType = .activity
            let p = Bundle.main.path(forResource: "indicator_20", ofType: "gif")!
            let data = try! Data(contentsOf: URL(fileURLWithPath: p))
            imageView.kf.indicatorType = .image(imageData: data)
            imageView.kf.setImage(with: currentUser?.profile.images.first)
            
            let replyImageView = cell.viewWithTag(4) as! UIImageView
            replyImageView.isHidden = true
            if let user1 = chatItems[indexPath.row].userId, let user2 = chatItems[indexPath.row].inUser {
                if user1 != user2 {
                    replyImageView.isHidden = false
                }
            }
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let currentUser = self.fetchUserForChatSelected(chatItem: chatItems[indexPath.row])
            let chatItem = self.chatItems[indexPath.row]
            if let user = currentUser {
                self.openChat(forUser: user, chatItem: chatItem )
            }
        }
    }
    
    func openChat(forUser user: LocalUser, chatItem: ChatItem? = nil) {
        let vc = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        vc.chatItem = chatItem
        vc.chatUser = user
        
        if chatItem == nil {
            var val = ChatItem()
            if let friend = user.id, let me = Authenticator.shared.user?.id {
                let chatId =  friend > me ? friend+me : me+friend
                val.chatId = chatId
                val.userId = friend
            }
            vc.chatItem = val
        }
        
        vc.chatUserName = user.profile.firstName ?? ""
        vc.chatOppentId = user.id
        
        if let nav =  self.navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            self.present(vc, animated: true, completion: {
                
            })
        }
    }
}
