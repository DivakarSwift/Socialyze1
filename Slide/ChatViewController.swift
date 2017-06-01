//
//  ChatViewController.swift
//  Slide
//
//  Created by bibek timalsina on 4/20/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextView: UITextView!
    
    var chatItem: ChatItem?
    var chatData = [ChatData]()
    var chatUserName: String = ""
    var chatOppentId:String?
    var chatUser:User?
    var fromSquad:Bool?
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    var chatService = ChatService.shared
    var userService = UserService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.hideKeyboardWhenTappedAround()
        self.tableView.delegate = self
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        fetchData()
        let rightButton: UIBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonClicked))
        self.navigationItem.leftBarButtonItem = rightButton
    }
    
    func backButtonClicked(_ button:UIBarButtonItem!){
//        self.dismiss(animated: true, completion: nil)
        _ = self.navigationController?.popViewController(animated: true)
//        performSegue(withIdentifier: "unwindFromMatch", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        
        let titleButton = UIButton(type: .custom)
        titleButton.setTitle(chatUserName, for: .normal)
        titleButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        titleButton.backgroundColor = UIColor.clear
        titleButton.tintColor = UIColor.white
        titleButton.addTarget(self, action:#selector(titleTouched), for: .touchUpInside)
        self.navigationItem.titleView = titleButton
    }
    
    @IBAction func moreButton(_ sender: UIBarButtonItem) {
        print("more button Touched")
        showMoreOption()
    }
    
    func titleTouched() {
        if let user = self.chatUser {
            let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "categoryDetailViewController") as! CategoriesViewController
            vc.fromFBFriends = user
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true, completion: nil)
//            _ = self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func fetchData() {
        guard let item = self.chatItem  else {
            return
        }
        
        chatService.getDataAndObserve(of: item) {[weak self] (data, error) in
            guard let me = self else {
                return
            }
            
            if let data = data {
                let lastIndexRow = me.chatData.count - 1
                me.chatData.append(data)
                me.tableView.reloadData()
                if let row = me.tableView.indexPathsForVisibleRows?.last?.row, [lastIndexRow, lastIndexRow - 1].contains(row) {
                    
                    let lastIndexPath = IndexPath(row: me.chatData.count - 1, section: 0)
                    
                    me.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
                }
            }
        }
    }
    
    func loadMore() {
        if var lastChatData = self.chatData.last {
            lastChatData.id = lastChatData.id ?? "\(self.chatData.count - 1)"
            self.tableView.tableHeaderView = activityIndicator
            if let item = self.chatItem {
                chatService.loadMoreData(of: item, lastChatData: lastChatData, completion: { [weak self] (chatData, error) in
                    self?.activityIndicator.stopAnimating()
                    guard let me = self, let newChatData = chatData else {return}
                    me.chatData = newChatData + me.chatData
                    me.tableView.reloadData()
                })
            }
        }
    }
    
    @IBAction func send(_ sender: Any) {
        if messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            guard let opponetId = chatOppentId, let myId = Authenticator.shared.user?.id else {
                return
            }
            
            // Create chatlist or update chatlist
            self.chatService.addChatList(for: opponetId, withMe: myId, message: messageTextView.text, completion: { chatId, error in
                if error == nil {
                    var chatData = ChatData()
                    chatData.fromUser = myId
                    chatData.toUser = opponetId
                    chatData.time = Date().timeIntervalSince1970
                    chatData.message = self.messageTextView.text
                    chatData.id = chatId
                    
                    // Send Message
                    self.sendChatData(message: chatData, chatId: chatId)
                }
            })
        }
    }
    
    private func sendChatData(message:ChatData, chatId: String){
        self.chatService.send(message: message, chatId: chatId, completion: { (success, error) in
            
            if error == nil {
                self.messageTextView.text = ""
                self.tableView.reloadData()
                
                let lastIndexPath = IndexPath(row: self.chatData.count - 1, section: 0)
                self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
            }
            
        })
    }
    
    func updateTableContentInset() {
        let numRows = tableView(tableView, numberOfRowsInSection: 0)
        var contentInsetTop = self.tableView.bounds.size.height
        for i in 0..<numRows {
            contentInsetTop -= tableView(tableView, heightForRowAt: IndexPath(item: i, section: 0))
            if contentInsetTop <= 0 {
                contentInsetTop = 0
            }
        }
        tableView.contentInset = UIEdgeInsetsMake(contentInsetTop, 0, 0, 0)
    }
    
    // MARK: - More Options
    private func showMoreOption() {
        if let user = self.chatUser {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let block = UIAlertAction(title: "Block", style: .default) { [weak self] (_) in
                self?.block(forUser: user)
            }
            alert.addAction(block)
            
            let report = UIAlertAction(title: "Report", style: .default) { [weak self] (_) in
                self?.report(forUser: user)
            }
            alert.addAction(report)
            
            if let _ = fromSquad {
                let delete = UIAlertAction(title: "Remove Friend", style: .default) { [weak self] (_) in
                    if let _ = user.profile.firstName {
                        self?.alertWithOkCancel(message: "Are you Sure?", title: "Alert", okTitle: "Ok", cancelTitle: "Cancel", okAction: { _ in
                            self?.delete(user: user)
                        }, cancelAction: nil)
                    }
                }
                alert.addAction(delete)
            } else {
                
                let unmatch = UIAlertAction(title: "Unmatch", style: .default) { [weak self] (_) in
                    if let name = user.profile.firstName {
                        self?.alert(message: "Are you sure?", title: "Alert", okAction: {
                            self?.unMatch(name : name)
                        })
                    }
                }
                
                alert.addAction(unmatch)
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func block(forUser opponent:User) {
        guard let myId = Authenticator.shared.user?.id else {
            self.alert(message: GlobalConstants.Message.oops)
            return
        }
        self.activityIndicator.startAnimating()
        self.userService.block(user: opponent, myId: myId, completion: { [weak self] (success, error) in
            self?.activityIndicator.stopAnimating()
            if success {
                var message = "Successfully blocked user"
                if let name = opponent.profile.firstName {
                    message = message + " " + name
                }
                self?.alert(message: message, title: "Success", okAction: {
                    _ = self?.navigationController?.popViewController(animated: true)
                })
            }else {
                self?.alert(message: "Can't report the user. Try again!")
            }
        })
    }
    
    private func report(forUser opponent: User) {
            let reportAlert = UIAlertController(title: "Report Remarks", message: "", preferredStyle: .alert)
            reportAlert.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "Remarks"
            })
            
            let ok = UIAlertAction(title: "Report", style: .default, handler: { (_) in
                self.activityIndicator.startAnimating()
                self.userService.report(user: opponent, remark: reportAlert.textFields?.first?.text ?? "", completion: { [weak self] (success, error) in
                    self?.activityIndicator.stopAnimating()
                    if success {
                        self?.alert(message: "Reported on user.")
                    }else {
                        self?.alert(message: "Can't report the user. Try again!")
                    }
                })
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            reportAlert.addAction(ok)
            reportAlert.addAction(cancel)
            
            self.present(reportAlert, animated: true, completion: nil)
    }
    
    private func unMatch(name: String) {
        
        self.activityIndicator.startAnimating()
        guard let opponetId = chatOppentId, let myId = Authenticator.shared.user?.id, let chatId = self.chatItem?.chatId else {
            self.activityIndicator.stopAnimating()
            self.alert(message: "Something went wrong. Please try again later.", title: "Oops", okAction: nil)
            return
        }
        UserService().unMatch(opponent: opponetId, withMe: myId, chatId: chatId, completion: { (success, error) in
            self.activityIndicator.stopAnimating()
            if success {
                self.alert(message: "You successfully unmatched with \(name).", title: "Success", okAction: {
                    _ = self.navigationController?.popViewController(animated: true)
                })
            } else {
                
            }
        })
    }
    
    private func delete(user: User) {
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
            if success {
                self.userService.block(user: user, myId: myId, completion: { (success, error) in
                    self.activityIndicator.stopAnimating()
                    if success {
                        var message = "Successfully removed user"
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
                
            } else {
                self.activityIndicator.stopAnimating()
                self.alert(message: GlobalConstants.Message.oops)
            }
        })
    }
}

extension ChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            loadMore()
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = chatData[indexPath.row]
        
        let isMe = data.fromUser == Authenticator.shared.user?.id
        let cell = tableView.dequeueReusableCell(withIdentifier: isMe ? "friend" : "me", for: indexPath)
        //        let userImage = cell.viewWithTag(1)
        let messageLabel = cell.viewWithTag(2) as! UILabel
        messageLabel.text = data.message
        
        let messageView = cell.viewWithTag(100)
        messageView?.layer.cornerRadius = 5.0
        messageView?.layer.masksToBounds = true
        
        let timeLabel = cell.viewWithTag(3) as! UILabel
        if let timeStamp = data.time {
            timeLabel.isHidden = false
            let date = Date(timeIntervalSince1970: timeStamp)
            timeLabel.text = Utilities.timeAgoSince(date)
        } else {
            timeLabel.isHidden = true
        }
        return cell
    }
}

extension ChatViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.updateTableContentInset()
    }
}
