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
import Alamofire

class EventAdsViewController: UIViewController {
    
    var place:Place?
    var facebookFriends:[FacebookFriend] = [FacebookFriend]()
    var eventUsers:[LocalUser] = []
    let authenticator = Authenticator.shared
    var placeService: PlaceService!
    let dealService = DealService()
    fileprivate var thresholdRadius = 30.48 //100ft
    //    var deal:Deal?
    var isCheckedIn = false
    
    var isDealExpired = false
    
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
        self.setup()
        self.setupView()
        self.useDealBtn.layer.cornerRadius = 5
        self.countLabel.layer.shadowOpacity = 1.0
        self.countLabel.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.countLabel.layer.shadowRadius = 3.0
        self.checkedInLabel.layer.shadowOpacity = 1.0
        self.checkedInLabel.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.checkedInLabel.layer.shadowRadius = 3.0
        self.expiryLabel.layer.shadowOpacity = 1.0
        self.expiryLabel.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.expiryLabel.layer.shadowRadius = 3.0
        
        friendsCollectionView.delegate = self
        friendsCollectionView.dataSource = self
        self.setupCollectionView()
        //checkedInLabel.text = "\(self.eventUsers.count) friend checked in"
        if eventUsers.count > 1 {
            checkedInLabel.text = "\(self.eventUsers.count) of 2 required friends checked in"
        } else if eventUsers.count > 0 {
            checkedInLabel.text = "\(self.eventUsers.count) of 2 required friends checked in"
        }
        getDeals()
        useDealBtn.addTarget(self, action: #selector(useDeal), for: .touchUpInside)
        inviteButton.addTarget(self, action: #selector(invite), for: .touchUpInside)
        useDealBtn.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.addSwipeGesture(toView: self.view)
        self.addTapGesture(toView: self.view)
    }
    
    private func setup() {
        self.descriptionLabel.text = self.place?.deal?.detail
        
        if let expiryDate = self.dateFormatter().date(from: self.place?.deal?.expiry ?? " ") {
            let form = DateComponentsFormatter()
            form.maximumUnitCount = 2
            form.unitsStyle = .abbreviated
            form.allowedUnits = [.year, .month, .day, .hour, .minute]
            let s = form.string(from: Date(), to: expiryDate)
            
            self.expiryLabel.text = "Expires in \(s ?? "")"
            
            if expiryDate.timeIntervalSince(Date()) <= 0 {
                self.useDealBtn.isEnabled = false
                self.expiryLabel.text = "Deal Expired"
                self.isDealExpired = true
                self.useDealBtn.backgroundColor = UIColor.gray
            }else {
                self.isDealExpired = false
                self.useDealBtn.isEnabled = true
                self.useDealBtn.backgroundColor = UIColor.init(red: 74/255, green: 176/255, blue: 80/255, alpha: 1)
            }
        }
    }
    
    func dateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.timeZone = TimeZone.current
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
        let text = "Hey! Meet me with this app https://itunes.apple.com/us/app/socialyze/id1239571430?mt=8"
        
        
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
    
    func useDeal() {
        guard let user = authenticator.user else { return }
        func callNetwork() {
        let minimumFriends = self.place?.deal?.minimumFriends ?? 0
        
        if self.eventUsers.filter({
            $0.id != user.id
        }).count < minimumFriends {
            var msg = GlobalConstants.Message.friendsNotSufficient
            msg.okAction = {
                self.openMessage()
            }
            self.alert(message: msg)
            return
        }
        
            let fbIds = self.facebookFriends.map({$0.id}) // + ["101281293814104"];
            
            let params = [
                "sound": "default",
                "place": self.place!.nameAddress!,
                "placeId": self.place!.nameAddress!.replacingOccurrences(of: " ", with: ""),
                "fbId": authenticator.user?.profile.fbId ?? "",
                "time": Date().timeIntervalSince1970,
                "userId": authenticator.user?.id ?? "",
                "notificationTitle": "\(authenticator.user?.profile.firstName ?? "") used the deal @ \(self.place?.nameAddress ?? "")",
                "notificationBody": "Meet your friend and get the exclusive deal @ \(self.place?.nameAddress ?? "").",
                "friendsFbId": fbIds,
                "dealUid": self.place?.deal?.uid ?? "--1"
                ] as [String : Any]
            
            self.useDealBtn.isEnabled = false
            
            Alamofire.request(GlobalConstants.urls.baseUrl + "useDeal", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { [weak self](data) in
                self?.useDealBtn.isEnabled = true
                
                if data.response?.statusCode == 200 {
                    self?.useDealBtn.titleLabel?.text = "Used"
                    self?.useDealBtn.backgroundColor = UIColor.gray
                    self?.getDeals()
                    self?.dealDoneView.isHidden = false
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "h:mm a '\n' d.M.yy"
                    dateFormatter.timeZone = TimeZone.current
                    let string = dateFormatter.string(from: Date())
                    self?.usedDealTime.text = string
                }else {
                    self?.alert(message: "Something went wrong. Try again!")
                }
            }
        }
        
        self.checkInn {
            callNetwork()
        }
    }
    
    func getDeals(){
        self.dealService.getPlaceDeal(place: self.place!) { (place) in
            self.place = place
            self.setup()
            self.dealService.getPlaceDealInPlace(place: self.place!, completion: {[weak self]
                (placeDeal) in
                guard let _ = self else {return}
                self!.countLabel.text = "\(placeDeal.count ?? 0) Used"
                var iUsedTheDeal = false
                for (key, value) in placeDeal.users ?? [:] {
                    let userId = Auth.auth().currentUser!.uid
                    if key == userId, let value = value as? [String: Double] {
                        iUsedTheDeal = true
                        self?.dealDoneView.isHidden = false
                        
                        let dateInterval = value["time"]
                        let date = Date.init(timeIntervalSince1970: dateInterval ?? 0)
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.locale = Locale(identifier: "en_US")
                        dateFormatter.timeZone = TimeZone.current
                        dateFormatter.dateFormat = "h:mm a '\n' d.M.yy"
                        let string = dateFormatter.string(from: date)
                        self?.usedDealTime.text = string
                        
                        self?.useDealBtn.isHidden = true
                        self?.useDealBtn.isEnabled = false
                    }
                }
                
                self?.useDealBtn.isEnabled = !iUsedTheDeal && !self.isDealExpired
            })
        }
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
            self.alert(message: GlobalConstants.Message.userNotInPerimeterToUseDeal)
        }
    }
    
    
    
    // MARK: - Gesture
    func addTapGesture(toView view: UIView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        view.addGestureRecognizer(tap)
        tap.delegate = self
    }
    
    @IBAction func handleTap(_ gesture: UITapGestureRecognizer) {
        let event = UIEvent()
        let location = gesture.location(in: self.view)
        
        //check actually view you hit via hitTest
        let view = self.view.hitTest(location, with: event)
        
        if view?.gestureRecognizers?.contains(gesture) ?? false {
            dismiss(animated: false, completion: nil)
            UIApplication.shared.isStatusBarHidden = false
        }
    }
    
    func setupView() {
        if let place = self.place {
            // self.descriptionLabel.text = place.bio
            
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

extension EventAdsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "categoryDetailViewController") as! CategoriesViewController
        vc.fromFBFriends = self.eventUsers[indexPath.row]
        vc.transitioningDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
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
        // let checkButton = cell.viewWithTag(3) as! UIButton
        // checkButton.isHidden = !user.isCheckedIn
        
        
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

extension EventAdsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let event = UIEvent()
        let location = gestureRecognizer.location(in: self.view)
        
        //check actually view you hit via hitTest
        let view = self.view.hitTest(location, with: event)
        
        if view?.gestureRecognizers?.contains(gestureRecognizer) ?? false {
            return true
        }
        return false
    }
}

extension EventAdsViewController: UIViewControllerTransitioningDelegate {
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
}

