//
//  UserListCollectionViewHandler.swift
//  Slide
//
//  Created by bibek timalsina on 8/2/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit

class UserListCollectionViewHandler: NSObject {
    var collectionView: UICollectionView!
    var users: [LocalUser] = []
    var onUserSelect: ((LocalUser) -> ())?
    
    class func initWith(collectionView: UICollectionView, users: [LocalUser], onUserSelect: ((LocalUser) -> ())?) -> UserListCollectionViewHandler {
        let obj = UserListCollectionViewHandler()
        obj.collectionView = collectionView
        obj.users = users
        collectionView.delegate = obj
        collectionView.dataSource = obj
        obj.setupCollectionView()
        obj.onUserSelect = onUserSelect
        return obj
    }
    
    private override init() {
        super.init()
    }
    
}

extension UserListCollectionViewHandler : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let user = users[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "friendsCell", for: indexPath)
        
        let label = cell.viewWithTag(2) as! UILabel
        
        label.text = user.profile.firstName
        label.layer.shadowOpacity = 1
        label.layer.shadowRadius = 3
        label.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.rounded()
        
        imageView.kf.setImage(with: user.profile.images.first)
        
        let checkButton = cell.viewWithTag(3) as! UIButton
        checkButton.isHidden = !user.isCheckedIn
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedUser = self.users[indexPath.row]
        self.onUserSelect?(selectedUser)
    }
    
    func setupCollectionView() {
        let numberOfColumn:CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 4 : 3
        let collectionViewCellSpacing:CGFloat = 10
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout{
            let cellWidth: CGFloat = (self.collectionView.frame.size.width  - (numberOfColumn + 1)*collectionViewCellSpacing)/numberOfColumn
            let cellHeight: CGFloat = self.collectionView.frame.size.height
            layout.itemSize = CGSize(width: cellWidth, height:cellHeight)
            layout.minimumLineSpacing = collectionViewCellSpacing
            layout.minimumInteritemSpacing = collectionViewCellSpacing
        }
    }
}
