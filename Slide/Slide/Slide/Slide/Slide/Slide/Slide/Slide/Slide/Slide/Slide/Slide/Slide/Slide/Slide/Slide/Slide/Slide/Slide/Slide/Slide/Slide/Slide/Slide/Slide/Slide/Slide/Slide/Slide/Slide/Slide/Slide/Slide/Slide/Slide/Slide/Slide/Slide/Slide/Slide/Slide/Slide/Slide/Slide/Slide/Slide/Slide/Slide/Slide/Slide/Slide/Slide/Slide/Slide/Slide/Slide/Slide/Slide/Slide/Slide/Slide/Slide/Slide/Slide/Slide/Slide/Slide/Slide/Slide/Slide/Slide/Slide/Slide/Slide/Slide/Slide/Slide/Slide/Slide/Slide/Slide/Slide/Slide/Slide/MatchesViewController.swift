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
    
    let data = [
        ("Your Events", [#imageLiteral(resourceName: "coldcoffee.png"), #imageLiteral(resourceName: "fitness2.png"), #imageLiteral(resourceName: "Fitness.png")]),
        ("Coffee", [#imageLiteral(resourceName: "stockpicround.png"), #imageLiteral(resourceName: "stockpicround1.png")]),
        ("Fitness", [#imageLiteral(resourceName: "Fitness.png")]),
        ("Gaming", [])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}

extension MatchesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return data[indexPath.row].1.count > 0 ? 147 : 70
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return data[indexPath.row].1.count > 0 ? 147 : 70
    }
}

extension MatchesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchesTableViewCell", for: indexPath) as! MatchesTableViewCell
        cell.titleLabel.text = data[indexPath.row].0
        cell.images = data[indexPath.row].1
        return cell
    }
}
