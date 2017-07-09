//
//  EventAdsViewController.swift
//  Slide
//
//  Created by Rajendra on 6/27/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit
import ObjectMapper
import FirebaseAuth
import MessageUI
import FacebookCore
import FacebookShare

class EventAdsViewController: UIViewController {
    
    var place:Place?
    var checkinData:[Checkin]?
    var facebookFriends:[FacebookFriend] = [FacebookFriend]()
    var eventUsers:[LocalUser] = []
    let authenticator = Authenticator.shared
    var placeService: PlaceService!
    let dealService = DealService()
    fileprivate var thresholdRadius = 30.48 //100ft
    var deal:Deal?
    var isCheckedIn = false
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var checkedInLabel: UILabel!
    @IBOutlet weak var friendsCollectionView: UICollectionView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var expiryLabel: UILabel!
    @IBOutlet weak var useDealBtn: UIButton!
    @IBOutlet weak var dealDoneView: UIView!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var usedDealTime: UILabel!
    
    override func viewDidLoad() {
        self.addSwipeGesture(toView: self.view)
        self.setupView()
        self.addTapGesture(toView: self.view)
        self.fetchUsers()
        friendsCollectionView.delegate = self
        friendsCollectionView.dataSource = self
        self.setupCollectionView()
        checkedInLabel.text = "\(self.eventUsers.count) Checked in"
        getDeals()
        useDealBtn.addTarget(self, action: #selector(useDeal), for: .touchUpInside)
        inviteButton.addTarget(self, action: #selector(invite), for: .touchUpInside)
    }
    
    func dateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)!
        return dateFormatter
    }
    
    func invite() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let facebook = UIAlertAction(title: "Facebook", style: .default) { [weak self] (_) in
            self?.openFacebookInvite()
            self?.alert(message: "Coming Soon!")
        }
        alert.addAction(facebook)
        
        let textMessage = UIAlertAction(title: "Text Message", style: .default) { [weak self] (_) in
            self?.openMessage()
        }
        alert.addAction(textMessage)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func openMessage() {
        let text = "Hey! Meet me with https://itunes.apple.com/us/app/socialyze/id1239571430?mt=8"
        
        
        if !MFMessageComposeViewController.canSendText() {
            // For simulator only.
            let messageURL = URL(string: "sms:body=\(text)")
            guard let url = messageURL else {
                return
            }
            
            if UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        } else {
            let controller = MFMessageComposeViewController()
            controller.messageComposeDelegate = self
            controller.body = text
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    private func openFacebookInvite() {
        
        
        // Please change this two urls accordingly
        let appLinkUrl:URL = URL(string: "https://fb.me/1351482471639007")!//GlobalConstants.urls.itunesLink)!
        let previewImageUrl:URL = URL(string: "http://socialyzeapp.com/wp-content/uploads/2017/03/logo-128p.png")!
        
        var inviteContent:AppInvite = AppInvite.init(appLink: appLinkUrl)
        inviteContent.appLink = appLinkUrl
        inviteContent.previewImageURL = previewImageUrl
        
        
        let inviteDialog = AppInvite.Dialog(invite: inviteContent)
        do {
            try inviteDialog.show()
        } catch  (let error) {
            print(error.localizedDescription)
        }
    }
    
    func useDeal(){
        if useDealBtn.titleLabel?.text == "Use Deal"{
            let user = Auth.auth().currentUser!
            self.checkInn {
                let time = self.dateFormatter().string(from: Date())
                self.dealService.useDeal(user: user, place: self.place!, time: time, completion: {
                    (result) in
                    if result == true{
                        self.useDealBtn.titleLabel?.text = "Used"
                        self.useDealBtn.backgroundColor = UIColor.gray
                        
                        self.dealService.fetchUser(place: self.place!, completion: {
                            (count,_) in
                            self.dealService.updateDeal(place: self.place!, count: count)
                            self.getDeals()
                            self.dealDoneView.isHidden = false
                            
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "h:m a '\n' d.M.yy"
                            dateFormatter.timeZone = TimeZone.current
                            let string = dateFormatter.string(from: Date())
                            self.usedDealTime.text = string
                        })
                        
                    }
                })
            }
        }
    }
    func fetchUsers(){
        self.dealService.fetchUser(place: self.place!, completion: {
            [weak self](_,dic) in
            for (key, value) in dic {
                let userId = Auth.auth().currentUser!.uid
                if key == userId {
                    self?.useDealBtn.setTitle("Used", for: .normal)
                    self?.useDealBtn.isEnabled = false
                    self?.useDealBtn.backgroundColor = UIColor.gray
                    
                    if let value = value as? [String: String], let time = value["time"], let date = self?.dateFormatter().date(from: time) {
                        // show time if needed
                    }
                }
            }
        })
    }
    
    
    
    func getDeals(){
        self.dealService.getDealInPlace(place: self.place!, completion: {[weak self]
            (dealDictionary) in
            guard let _ = self else {return}
            self!.deal = Mapper<Deal>().map(JSON: dealDictionary)
            self!.descriptionLabel.text = self!.deal!.detail
            self!.countLabel.text = "\(self!.deal!.count!) Used"
            
            if let expiryDate = self?.dateFormatter().date(from: self!.deal!.expiry!) {
                let form = DateComponentsFormatter()
                form.maximumUnitCount = 2
                form.unitsStyle = .full
                form.allowedUnits = [.year, .month, .day, .hour, .minute]
                let s = form.string(from: Date(), to: expiryDate)
                
                self!.expiryLabel.text = "Expires in \(s ?? "")"
                
                if expiryDate.timeIntervalSince(Date()) <= 0 {
                    self!.descriptionLabel.text = "Sorry the deal has been expired!"
                }
            }
        })
    }
    
    func getDistanceToUser() -> Double? {
        if let lat = self.place?.lat, let lon = place?.long, let distance = SlydeLocationManager.shared.distanceFromUser(lat: lat, long: lon) {
            return distance
        }
        return nil
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
        
        func check() {
            self.placeService.user(authenticator.user!, checkInAt: self.place!, completion: {[weak self] (success, error) in
                if !success {
                    self?.alert(message: error?.localizedDescription)
                }else {
                    action()
                    // do on success
                }
                if let me = self {
                    me.isCheckedIn = success
                    
                    if success {
                        SlydeLocationManager.shared.stopUpdatingLocation()
                    }
                }
                
                print(error ?? "CHECKED IN")
            })
        }
        
        if let distance = self.getDistanceToUser(), distance <= thresholdRadius {
            check()
            
        } else if thresholdRadius == 0 && (SlydeLocationManager.shared.distanceFromUser(lat: SNlat1, long: SNlong1)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: SNlat2, long: SNlong2)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: SNlat3, long: SNlong3)! < hugeRadius){
            check()
            
        } else if (place?.nameAddress)! == "Columbus State" && (SlydeLocationManager.shared.distanceFromUser(lat: CSlat1, long: CSlong1)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: CSlat2, long: CSlong2)! < hugeRadius){
            check()
            
        } else if (place?.nameAddress)! == "Easton Town Center" && (SlydeLocationManager.shared.distanceFromUser(lat: Elat1, long: Elong1)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: Elat2, long: Elong2)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: Elat3, long: Elong3)! < hugeRadius ||  SlydeLocationManager.shared.distanceFromUser(lat: Elat4, long: Elong4)! < hugeRadius) {
            check()
            
        } else if (place?.nameAddress)! == "Pride Festival & Parade" && (SlydeLocationManager.shared.distanceFromUser(lat: PFPlat1, long: PFPlong1)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: PFPlat2, long: PFPlong2)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: PFPlat3, long: PFPlong3)! < hugeRadius || SlydeLocationManager.shared.distanceFromUser(lat: PFPlat4, long: PFPlong4)! < hugeRadius) {
            check()
            
        }
        else {
            self.alert(message: GlobalConstants.Message.userNotInPerimeterToUseDeal)
        }
    }
    
    
    
    // MARK: - Gesture
    func addTapGesture(toView view: UIView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        view.addGestureRecognizer(tap)
    }
    func handleTap(_ gesture: UITapGestureRecognizer) {
        dismiss(animated: false, completion: nil)
        UIApplication.shared.isStatusBarHidden = false
    }
    
    func setupView() {
        if let place = self.place {
            self.descriptionLabel.text = place.bio
            
            let image = place.secondImage ?? place.mainImage ?? ""
            self.imageView.kf.setImage(with: URL(string: image), placeholder: #imageLiteral(resourceName: "OriginalBug") )
        }
    }
    
    func addSwipeGesture(toView view: UIView) {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(wasSwipped))
        gesture.direction = .down
        view.addGestureRecognizer(gesture)
    }
    
    func wasSwipped(_ gesture: UISwipeGestureRecognizer) {
        dismiss(animated: true, completion: nil)
        UIApplication.shared.isStatusBarHidden = false
    }
    
    
    
    
}

extension EventAdsViewController:UICollectionViewDelegate{
    
}

extension EventAdsViewController:UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.eventUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let user = self.eventUsers[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventUsersCell", for: indexPath)
        let label = cell.viewWithTag(2) as! UILabel
        //        label.text = "Dari"
        label.text = user.profile.firstName
        label.layer.shadowOpacity = 1
        label.layer.shadowRadius = 3
        label.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        
        let imageView = cell.viewWithTag(1) as! UIImageView
        //        imageView.rounded()
        //        imageView.image = UIImage(named: "profile.png")
        imageView.kf.setImage(with: user.profile.images.first)
        let checkButton = cell.viewWithTag(3) as! UIButton
        checkButton.isHidden = !user.isCheckedIn
        
        
        return cell
    }
    func setupCollectionView() {
        let numberOfColumn:CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 4 : 3
        let collectionViewCellSpacing:CGFloat = 10
        
        if let layout = friendsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout{
            let cellWidth:CGFloat = ( self.view.frame.size.width  - (numberOfColumn + 1)*collectionViewCellSpacing)/numberOfColumn
            let cellHeight:CGFloat = self.friendsCollectionView.frame.size.height - 2*collectionViewCellSpacing
            layout.itemSize = CGSize(width: cellWidth, height:cellHeight)
            layout.minimumLineSpacing = collectionViewCellSpacing
            layout.minimumInteritemSpacing = collectionViewCellSpacing
        }
    }
}

extension EventAdsViewController: MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        controller.dismiss(animated: true, completion: nil)
    }
}



