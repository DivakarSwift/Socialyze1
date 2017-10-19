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
    
    let authenticator = Authenticator.shared
    
    var activities = [ActivityModel]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        getActivities()
    }
    
    func setup() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func getActivities() {
        let myId = self.authenticator.user?.profile.fbId ?? ""
        ActivityService().getActivities(myId: "12345r") { [weak self] (models) in
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
        cell.activity = self.activities[indexPath.row]
        return cell
    }
}
