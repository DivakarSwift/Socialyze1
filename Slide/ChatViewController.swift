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
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    var chatService = ChatService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = chatUserName
        self.tableView.dataSource = self
        self.tableView.delegate = self
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        fetchData()
    }
    
    func fetchData() {
        chatService.getDataAndObserve(of: self.chatItem!) {[weak self] (data, error) in
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
        if let lastChatData = self.chatData.last {
            self.tableView.tableHeaderView = activityIndicator
            chatService.loadMoreData(of: chatItem!, lastChatData: lastChatData, completion: { [weak self] (chatData, error) in
                self?.activityIndicator.stopAnimating()
                guard let me = self, let newChatData = chatData else {return}
                me.chatData = newChatData + me.chatData
                me.tableView.reloadData()
            })
        }
    }
    
    @IBAction func send(_ sender: Any) {
        
    }
}

extension ChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            loadMore()
        }
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = chatData[indexPath.row]
        
        let isFriend = data.toUser == chatItem?.userId
        
        let cell = tableView.dequeueReusableCell(withIdentifier: isFriend ? "friend": "me", for: indexPath)
        //        let userImage = cell.viewWithTag(1)
        let label = cell.viewWithTag(2) as! UILabel
        label.text = data.message
        return cell
    }
}
