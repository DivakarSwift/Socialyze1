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
        setup()
        configureRefreshControl()
        self.activityIndicator.startAnimating()
        getActivities()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Activities"
    }
    
    func setup() {
        tableView.tableFooterView = UIView()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.view.addSubview(activityIndicator)
        self.activityIndicator.center = view.center
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
        activityService.getActivities(myId: myId) { [weak self] (models) in
            self?.activities = models
            self?.activityIndicator.stopAnimating()
            if self?.refreshControl.isRefreshing == true {
                self?.refreshControl.endRefreshing()
            }
        }
    }

    fileprivate func showUserDetail(user: LocalUser) {
        let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "categoryDetailViewController") as! CategoriesViewController
        vc.fromFBFriends = user
        vc.transitioningDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    fileprivate func openPlaceDetail(place: Place) {
        let vc = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
        vc.place = place
        self.present(vc, animated: true, completion: nil)
    }
}

extension ActivityViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let activity = self.activities[indexPath.row]
        if let place = authenticator.places?
            .filter({
                $0.nameAddress?.lowercased() == activity.place?.lowercased() //.map({activity.message?.lowercased().contains($0.lowercased()) == true}) == true
            })
            .sorted(by: {$0.nameAddress?.characters.count ?? 0 > $1.nameAddress?.characters.count ?? 0})
            .first {
            self.openPlaceDetail(place: place)
        }
    }
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
        cell.onImageTapped = { user in
            self.showUserDetail(user: user)
        }
        cell.setup()
        return cell
    }
}

extension ActivityViewController: UIViewControllerTransitioningDelegate {
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
}
