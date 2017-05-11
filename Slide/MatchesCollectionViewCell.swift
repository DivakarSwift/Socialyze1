//
//  MatchesCollectionViewCell.swift
//  Slide
//
//  Created by bibek timalsina on 3/19/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit

class MatchesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        self.imageView.rounded()
    }
}
