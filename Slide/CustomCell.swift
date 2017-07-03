//
//  CustomCell.swift
//  Slide
//
//  Created by bibek timalsina on 5/17/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit
import FloatRatingView

class CustomCell: UICollectionViewCell {
    
    @IBOutlet var widthLayout: NSLayoutConstraint!
    var imageView:UIImageView!
    var nameLabel:UILabel!
    var floatRatingView:FloatRatingView!
    var starLabel: UILabel!
    var bioNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView = self.viewWithTag(1) as! UIImageView
        nameLabel = self.viewWithTag(2) as! UILabel
        floatRatingView = self.viewWithTag(3) as! FloatRatingView
        starLabel = self.viewWithTag(4) as! UILabel
        bioNameLabel = self.viewWithTag(5) as! UILabel
        
        bioNameLabel.isHidden = true
        floatRatingView.isHidden = false
        starLabel.isHidden = false
    }
    
    func ConfigureCell(place: Place) {
        imageView.kf.indicatorType = .activity
        let p = Bundle.main.path(forResource: "indicator_40", ofType: "gif")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: p))
        imageView.kf.indicatorType = .image(imageData: data)
        
        imageView.kf.setImage(with: URL(string: place.mainImage ?? "" ))
        
        nameLabel.text = place.nameAddress
        
        // the shadow does not seem to be working
        //        let placeName = (view.viewWithTag(2) as! UILabel)
        //        placeName.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        //        placeName.layer.shadowRadius = 3
        //        placeName.layer.shadowOpacity = 1
        //        placeName.layer.masksToBounds = false
        
        floatRatingView.rating = 0
        floatRatingView.floatRatings = true
        
        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height
        if screenHeight == 568{
            self.widthLayout.constant = 70
        }else{
            self.widthLayout.constant = 100
        }
        
        if let nameBio = place.nameBio, let isEvent = place.isEvent, isEvent {
            self.bioNameLabel.text = nameBio
            self.bioNameLabel.isHidden = false
            self.floatRatingView.isHidden = true
            self.starLabel.isHidden = true
        } else {
            self.bioNameLabel.isHidden = true
        }
    }
}
