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

class EventAdsViewController: UIViewController {
    
    var place:Place?
    var checkinData:[Checkin]?
    var facebookFriends:[FacebookFriend] = [FacebookFriend]()
    var eventUsers:[LocalUser] = []
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    var deal:Deal?
    @IBOutlet weak var checkedInLabel: UILabel!
    @IBOutlet weak var friendsCollectionView: UICollectionView!
    
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var expiryLabel: UILabel!
    
    
    @IBOutlet weak var useDealBtn: UIButton!

    var currentTime:String?
    override func viewDidLoad() {
        self.addSwipeGesture(toView: self.view)
        self.setupView()
        self.addTapGesture(toView: self.view)
        self.fetchUsers()
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")! as TimeZone
        currentTime = dateFormatter.string(from: date)
        friendsCollectionView.delegate = self
        friendsCollectionView.dataSource = self
        self.setupCollectionView()
        checkedInLabel.text = "\(self.eventUsers.count) Checked in"
        getDeals()
        useDealBtn.addTarget(self, action: #selector(useDeal), for: .touchUpInside)
    }
    
    func useDeal(){
        if useDealBtn.titleLabel?.text == "Use Deal"{
            let user = Auth.auth().currentUser!
            DealService().useDeal(user: user, place: self.place!, time: currentTime!, completion: {
                (result) in
                if result == true{
                    self.useDealBtn.titleLabel?.text = "Used"
                    self.useDealBtn.backgroundColor = UIColor.gray
                    
                    DealService().fetchUser(place: self.place!, completion: {
                        (count,_) in
                        DealService().updateDeal(place: self.place!, count: count)
                        self.getDeals()
                    })
                    
                }
            })
        }
    }
    func fetchUsers(){
        DealService().fetchUser(place: self.place!, completion: {
            (_,dic) in
            let userDic = dic as NSDictionary
            let keys = userDic.allKeys as! [String]
            for key in keys{
                let userId = Auth.auth().currentUser!.uid
                if key == userId{
                    self.useDealBtn.titleLabel?.text = "Used"
                    self.useDealBtn.backgroundColor = UIColor.gray
                }
            }
        })
    }
    
    
    
    func getDeals(){
        DealService().getDealInPlace(place: self.place!, completion: {
            (dealDictionary) in
            self.deal = Mapper<Deal>().map(JSON: dealDictionary)
            self.descriptionLabel.text = self.deal!.detail
            self.countLabel.text = "\(self.deal!.count!) Used"
            self.expiryLabel.text = "Expires in \(self.deal!.expiry!)"
            let expiryTime = self.deal!.expiry!
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            let time = formatter.date(from: expiryTime)
            
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
            dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")! as TimeZone
            let currentT = dateFormatter.string(from: date)
            let nowTime = formatter.date(from: currentT)
            if time! < nowTime! {
                self.descriptionLabel.text = "Sorry the deal has been expired!"
            }
        })
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
        imageView.rounded()
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




