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
    
    var images = [UIImage]() {
        didSet {
            self.noMatchesLabel.isHidden = images.count > 0
            self.collectionView.isHidden = images.count == 0
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
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MatchesCollectionViewCell", for: indexPath) as! MatchesCollectionViewCell
        cell.imageView.image = images[indexPath.row]
        return cell
    }
}

extension MatchesTableViewCell: UICollectionViewDelegate {
    
}
