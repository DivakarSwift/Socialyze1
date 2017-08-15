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
    
    var parentViewController: UIViewController?
    
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
            
            self.useDealButton.isHidden = false
            // self.usedDealDateLabel.isHidden = true
            self.usedDealDateLabel.text = " "
            
            var iUsedDeal = false
            
            let userId = Auth.auth().currentUser!.uid
            for (key, value) in placeDeal?.users ?? [:] {
                if key == userId, let value = value as? [String: Double] {
                    
                    iUsedDeal = true
                    let dateInterval = value["time"]
                    let date = Date.init(timeIntervalSince1970: dateInterval ?? 0)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US")
                    dateFormatter.timeZone = TimeZone.current
                    dateFormatter.dateFormat = "M/d/yy h:mm a"
                    let string = dateFormatter.string(from: date)
                    self.usedDealDateLabel.text = string
                    
                   // self.usedDealDateLabel.isHidden = false
                    self.useDealButton.isHidden = true
                    
                    return
                }
            }
            self.useDealButton.isEnabled = !iUsedDeal && !self.isDealExpired
        }
    }
    
    var place: Place?
    
    var deal: Deal? {
        didSet {
            self.dealDetailLabel.text = deal?.detail
            self.checkedInCountLabel.text = "\(checkedInFriends.count) of \(deal?.minimumFriends ?? 0) required friends checked in"
            
            if let expiryDate = self.dateFormatter().date(from: (deal?.expiry ?? "") + "T" + (deal?.endTime ?? "")) {
                let form = DateComponentsFormatter()
                form.maximumUnitCount = 2
                form.unitsStyle = .abbreviated
                form.allowedUnits = [.year, .month, .day, .hour, .minute]
                let s = form.string(from: Date(), to: expiryDate)
                
                self.expiryDateTimeLabel.text = "Expires in \(s ?? "")"
                
                if expiryDate.timeIntervalSince(Date()) <= 0 {
                    self.useDealButton.isEnabled = false
                    self.expiryDateTimeLabel.text = "Deal Expired"
                    self.useDealButton.backgroundColor = UIColor.gray
                    self.isDealExpired = true
                }else {
                    self.isDealExpired = false
                    self.useDealButton.isEnabled = true
                    self.useDealButton.backgroundColor = UIColor.init(red: 74/255, green: 176/255, blue: 80/255, alpha: 1)
                }
            }
            let image = deal?.image ?? place?.mainImage ?? ""
            self.placeImage.kf.setImage(with: URL(string: image), placeholder: #imageLiteral(resourceName: "OriginalBug") )
            self.useDealButton.isEnabled = false
            self.getDeals()
        }
    }
    
   private var isDealExpired: Bool = false
    
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
        self.useDeal()
    }
    
    private func dateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter
    }
    
    private func useDeal() {
        guard let user = authenticator.user else { return }
        
        self.checkInn {
            let minimumFriends = self.deal?.minimumFriends ?? 0
            
            if self.checkedInFriends.filter({
                $0.id != user.id
            }).count < minimumFriends {
                var msg = GlobalConstants.Message.friendsNotSufficient
                msg.okAction = {
                    self.onInvite?()
                }
                self.parentViewController?.alert(message: msg)
                return
            }
            
            if self.deal?.isValid() == false {
                self.parentViewController?.alert(message: GlobalConstants.Message.invalidDeal)
                return
            }
            
            let fbIds = self.checkedInFriends.map({$0.id})
            
            let params = [
                "sound": "default",
                "place": self.place!.nameAddress!,
                "placeId": self.place!.nameAddress!.replacingOccurrences(of: " ", with: ""),
                "fbId": self.authenticator.user?.profile.fbId ?? "",
                "time": Date().timeIntervalSince1970,
                "userId": self.authenticator.user?.id ?? "",
                "notificationTitle": "\(self.authenticator.user?.profile.firstName ?? "") used the deal @ \(self.place?.nameAddress ?? "")",
                "notificationBody": "Meet your friend and get the exclusive deal @ \(self.place?.nameAddress ?? "").",
                "friendsFbId": fbIds,
                "dealUid": self.deal?.uid ?? "--1"
                ] as [String : Any]
            
            self.useDealButton.isEnabled = false
            
            Alamofire.request(GlobalConstants.urls.baseUrl + "useDeal", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { [weak self](data) in
                self?.useDealButton.isEnabled = true
                
                if data.response?.statusCode == 200 {
                    self?.useDealButton.isHidden = true
                    self?.getDeals()
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "h:mm a '\n' M.d.yy"
                    dateFormatter.timeZone = TimeZone.current
                    let string = dateFormatter.string(from: Date())
                    self?.usedDealDateLabel.text = string
                }else {
                    self?.parentViewController?.alert(message: "Something went wrong. Try again!")
                }
            }
        }
    }
    
    private func checkInn(action: @escaping ()->()) {
        
        if place?.size == 1 {
            thresholdRadius = smallRadius
        } else if place?.size == 2 {
            thresholdRadius = mediumRadius
        } else if place?.size == 3 {
            thresholdRadius = largeRadius
        } else if place?.size == 4 {
            thresholdRadius = hugeRadius
        } else if place?.size == 0 {
            thresholdRadius = 0
        }
        if let distance = self.getDistanceToUser(), distance <= thresholdRadius {
            action()
            
        } else if thresholdRadius == 0 && (SlydeLocationManager.shared.distanceFromUser(lat: SNlat1, long: SNlong1)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: SNlat2, long: SNlong2)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: SNlat3, long: SNlong3)! < hugeRadius){
            action()
            
        } else if (place?.nameAddress)! == "Columbus State" && (SlydeLocationManager.shared.distanceFromUser(lat: CSlat1, long: CSlong1)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: CSlat2, long: CSlong2)! < hugeRadius){
            action()
            
        } else if (place?.nameAddress)! == "Easton Town Center" && (SlydeLocationManager.shared.distanceFromUser(lat: Elat1, long: Elong1)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: Elat2, long: Elong2)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: Elat3, long: Elong3)! < hugeRadius ||  SlydeLocationManager.shared.distanceFromUser(lat: Elat4, long: Elong4)! < hugeRadius) {
            action()
            
        } else if (place?.nameAddress)! == "Pride Festival & Parade" && (SlydeLocationManager.shared.distanceFromUser(lat: PFPlat1, long: PFPlong1)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: PFPlat2, long: PFPlong2)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: PFPlat3, long: PFPlong3)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: PFPlat4, long: PFPlong4)! < hugeRadius) {
            action()
            
        }
        else {
            self.parentViewController?.alert(message: GlobalConstants.Message.userNotInPerimeterToUseDeal)
        }
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
