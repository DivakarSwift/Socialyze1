//
//  ActivityViewController.swift
//  Slide
//
//  Created by bibek timalsina on 10/17/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let refreshControl = UIRefreshControl()
    
    let authenticator = Authenticator.shared
    let activityService = ActivityService()
    let userService = UserService()
    
    var activities = [ActivityModel]() {
        didSet {
            self.tableView.reloadData()
            getUsers()
        }
    }
    
    var userModels = Set<LocalUser>() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    lazy internal var activityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = #imageLiteral(resourceName: "ladybird")
        let activityIndicator = CustomActivityIndicatorView(image: image)
        return activityIndicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator.startAnimating()
        setup()
        configureRefreshControl()
        getActivities()
    }
    
    func setup() {
        self.title = "Activities"
        tableView.tableFooterView = UIView()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func configureRefreshControl() {
        self.refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        self.refreshControl.attributedTitle = NSAttributedString(string: "pull to refresh")
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = refreshControl
        } else {
            self.tableView.addSubview(refreshControl)
        }
    }
    
    @objc private func refresh() {
        self.getActivities()
    }
    
    func getUsers() {
        let userFbIds = Set(activities.flatMap({$0.sender}))
        userFbIds.forEach { (userId) in
            self.userService.getUser(withFbId: userId, completion: { (user, error) in
                if let user = user {
                    self.userModels.insert(user)
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func getActivities() {
        let myId = self.authenticator.user?.profile.fbId ?? ""
        activityService.getActivities(myId: "12345r") { [weak self] (models) in
            self?.activities = models
        }
    }

}

extension ActivityViewController: UITableViewDelegate {
    
}

extension ActivityViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.activities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityListTableViewCell", for: indexPath) as! ActivityListTableViewCell
        let activity = self.activities[indexPath.row]
        cell.activity = activity
        cell.user = self.userModels.filter({$0.profile.fbId == activity.sender}).first
        cell.setup()
        return cell
    }
}
