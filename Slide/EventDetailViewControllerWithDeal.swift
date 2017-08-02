//
//  EventDetailViewControllerWithDeal.swift
//  Slide
//
//  Created by bibek timalsina on 8/1/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit

class EventDetailViewControllerWithDeal: UIViewController {
    
    struct Constants {
        static let heightOfSectionHeader: CGFloat = 50
        static let heightOfCollapsedCell: CGFloat = 82
    }
    
    @IBOutlet weak var goingBottomConstraint: NSLayoutConstraint!
    // 10 looks better when there is deal and 25 when no deal
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var tableViewHeader: UIView!
    
    fileprivate var expandedCell: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // if hasDeal
        tableViewHeader.frame.size.height = self.view.frame.height - Constants.heightOfSectionHeader - Constants.heightOfCollapsedCell
        // if no deal height = view.frame.height
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.panGestureRecognizer.addTarget(self, action: #selector(self.swippedDown(_:)))
    }
    
    @objc private func swippedDown(_ sender: UIPanGestureRecognizer) {
        
        guard let originView = sender.view as? UITableView else { return }
        
        // Only let the table view dismiss if we're at the top.
        
        if originView.contentOffset.y <= 0 && sender.state == .began {
            dismiss(animated: true, completion: nil)
            print("Dismiss view now")
        }
    }
}

extension EventDetailViewControllerWithDeal: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.heightOfSectionHeader
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return Constants.heightOfSectionHeader
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == expandedCell {
            return self.view.frame.height - Constants.heightOfSectionHeader
        }
        return Constants.heightOfCollapsedCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        let oldCell = expandedCell
        let scrollPosition: UITableViewScrollPosition
        if self.expandedCell == indexPath {
            self.expandedCell = nil
            scrollPosition = .bottom
        }else {
            scrollPosition = .top
            self.expandedCell = indexPath
        }
        
        let reloadingCells = oldCell == nil ? [indexPath] : [indexPath, oldCell!]
        self.tableView.reloadRows(at: reloadingCells, with: .automatic)
        self.tableView.scrollToRow(at: indexPath, at: scrollPosition, animated: true)
    }
}

extension EventDetailViewControllerWithDeal: UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DealCell", for: indexPath)
        return cell
    }
}
