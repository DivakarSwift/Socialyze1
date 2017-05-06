//
//  MatchesTableViewCell.swift
//  Slide
//
//  Created by bibek timalsina on 3/19/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit

class MatchesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noMatchesLabel: UILabel!
    
    var users = [User]() {
        didSet {
            self.noMatchesLabel.isHidden = users.count > 0
            self.collectionView.isHidden = users.count == 0
            self.collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
}

extension MatchesTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MatchesCollectionViewCell", for: indexPath) as! MatchesCollectionViewCell
        if let image = self.users[indexPath.row].profile.images.first {
            cell.imageView.kf.indicatorType = .activity
            cell.imageView.kf.setImage(with: image)
        }
        return cell
    }
}

extension MatchesTableViewCell: UICollectionViewDelegate {
    
}
