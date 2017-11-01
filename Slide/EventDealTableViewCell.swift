//
//  EventDealTableViewCell.swift
//  Slide
//
//  Created by bibek timalsina on 8/2/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit
import FirebaseAuth
import Alamofire

class EventDealTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dealDetailLabel: UILabel!
    @IBOutlet weak var usedCountLabel: UILabel!
    @IBOutlet weak var expiryDateTimeLabel: UILabel!
    @IBOutlet weak var checkedInCountLabel: UILabel!
    @IBOutlet weak var usedDealDateLabel: UILabel!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var useDealButton: UIButton!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var checkedInUserList: UICollectionView!
    @IBOutlet weak var collectionViewStack: UIStackView!
    @IBOutlet weak var collectionViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var socialyzedView: UIView!
    
    var parentViewController: EventDetailViewController?
    
    var onUserSelected: ((LocalUser) -> ())?
    var onInvite: (()->())?
    
    private let authenticator = Authenticator.shared
    private var thresholdRadius = 30.48 //100ft
    private let dealService = DealService()
    
    var isCollapsed: Bool = true {
        didSet {
            // detailTextLabel?.numberOfLines = isCollapsed ? 2 : 0
        }
    }
    
    var checkedInFriends = [LocalUser]() {
        didSet {
            let isFriendsCheckedIn = checkedInFriends.count > 0
            self.collectionViewStack.isHidden = !isFriendsCheckedIn
            //            self.checkedInCountLabel.isHidden = !isFriendsCheckedIn
            self.checkedInCountLabel.text = "\(checkedInFriends.count) friends checked in"
            checkedInUserList.reloadData()
        }
    }
    
    var placeDeal: PlaceDeal? {
        didSet {
            self.usedCountLabel.text = "\(placeDeal?.count ?? 0) Used"
        }
    }
    
    var place: Place?
    
    var deal: Deal? {
        didSet {
            setupUseDeal()
            self.dealDetailLabel.text = deal?.detail
            
            if deal?.minimumFriends ?? 0 == 0 {
                self.checkedInCountLabel.text = "No Friends Required"
                }
            else if deal?.minimumFriends ?? 0 == 1 {
                self.checkedInCountLabel.text = "\(checkedInFriends.count) of \(deal?.minimumFriends ?? 0) required friend checked in"
                }
            else {
                 self.checkedInCountLabel.text = "\(checkedInFriends.count) of \(deal?.minimumFriends ?? 0) required friends checked in"
            }
            
            if let expiryDate = self.dateFormatter().date(from: (deal?.expiry ?? "") + "T" + (deal?.endTime ?? "")) {
                let form = DateComponentsFormatter()
                form.maximumUnitCount = 2
                form.unitsStyle = .abbreviated
                form.allowedUnits = [.year, .month, .day, .hour, .minute]
                let s = form.string(from: Date(), to: expiryDate)
                
                self.expiryDateTimeLabel.text = "Expires in \(s ?? "")"
                
                if expiryDate.timeIntervalSince(Date()) <= 0 {
//                    self.useDealButton.isEnabled = false
                    self.expiryDateTimeLabel.text = "Deal Expired"
                    self.useDealButton.backgroundColor = UIColor.gray
                    self.isDealExpired = true
                }else {
                    self.isDealExpired = false
//                    self.useDealButton.isEnabled = true
                    self.useDealButton.backgroundColor = UIColor.init(red: 74/255, green: 176/255, blue: 80/255, alpha: 1)
                }
            }
            let image = deal?.image ?? place?.mainImage ?? ""
            self.placeImage.kf.setImage(with: URL(string: image), placeholder: #imageLiteral(resourceName: "OriginalBug") )
//            self.useDealButton.isEnabled = false
            self.getDeals()
        }
    }
    
    private var isDealExpired: Bool = false{
        didSet {
            setupUseDeal()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
        self.useDealButton.set(cornerRadius: 5)
        self.socialyzedView.set(cornerRadius:5)
        self.inviteButton.set(cornerRadius: 5)
    }
    
    
    @IBAction func invite(_ sender: Any) {
        self.onInvite?()
    }
    
    @IBAction func useDeal(_ sender: Any) {
        if let deal = deal {
            if deal.isActive().0 {
                self.parentViewController?.useDeal(deal: deal)
            }else {
                let alert = UIAlertController(title: deal.isActive().1?.capitalized, message: "Please, come back later.", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(action)
                self.parentViewController?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func dateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter
    }
    
    private func getDistanceToUser() -> Double? {
        if let lat = self.place?.lat, let lon = place?.long, let distance = SlydeLocationManager.shared.distanceFromUser(lat: lat, long: lon) {
            return distance
        }
        return nil
    }
    
    private func getDeals(){
        self.dealService.getPlaceDealInPlace(place: self.place!, deal: self.deal!, completion: {[weak self]
            (placeDeal) in
            self?.placeDeal = placeDeal
        })
    }
    
    private func setupUseDeal() {
        
        let iUsedDeal = !(self.parentViewController?.userCanUseDealForToday ?? true)
        let date = self.parentViewController?.lastDealUsedDate ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "M/d/yy h:mm a"
        let string = dateFormatter.string(from: date)
        self.usedDealDateLabel.text = string
//        self.useDealButton.isHidden = iUsedDeal
        if let isActive = self.deal?.isActive() {
            if !isActive.0 {
//                iUsedDeal = true
                useDealButton.setTitle(isActive.1, for: .normal)
            }
        }
        self.useDealButton.isEnabled = !iUsedDeal && !self.isDealExpired
    }
}

extension EventDealTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count =  self.checkedInFriends.count
        let width = (65 * count) + (10 * (count - 1))
        self.collectionViewWidthConstraint.constant = min(CGFloat(width), self.frame.width - 40)
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let user = checkedInFriends[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "friendsCell", for: indexPath)
        
        let label = cell.viewWithTag(2) as! UILabel
        
        label.text = user.profile.firstName
        label.layer.shadowOpacity = 1
        label.layer.shadowRadius = 3
        label.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.rounded()
        
        imageView.kf.setImage(with: user.profile.images.first)
        
        let checkButton = cell.viewWithTag(3) as! UIImageView
        checkButton.isHidden = !user.isCheckedIn
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedUser = self.checkedInFriends[indexPath.row]
        self.onUserSelected?(selectedUser)
    }
    
    func setupCollectionView() {
        checkedInUserList.delegate = self
        checkedInUserList.dataSource = self
    }
}
