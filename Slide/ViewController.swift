//
//  ViewController.swift
//  Slide
//
//  Created by Salem Khan on 3/3/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let data: [String] = ["Playing football", "Going for coffee", "Watching Movies", "Singing in Concert", "Playing football", "Going for coffee", "Watching Movies", "Singing in Concert", "Playing football", "Going for coffee", "Watching Movies", "Singing in Concert", "Playing football", "Going for coffee", "Watching Movies", "Singing in Concert", "Playing football", "Going for coffee", "Watching Movies", "Singing in Concert","Playing football", "Going for coffee", "Watching Movies", "Singing in Concert","Playing football", "Going for coffee", "Watching Movies", "Singing in Concert","Playing football", "Going for coffee", "Watching Movies", "Singing in Concert","Playing football", "Going for coffee", "Watching Movies", "Singing in Concert","Playing football", "Going for coffee", "Watching Movies", "Singing in Concert","Playing football", "Going for coffee", "Watching Movies", "Singing in Concert","Playing football", "Going for coffee", "Watching Movies", "Singing in Concert","Playing football", "Going for coffee", "Watching Movies", "Singing in Concert","Playing football", "Going for coffee", "Watching Movies", "Singing in Concert","Playing football", "Going for coffee", "Watching Movies", "Singing in Concert","Playing football", "Going for coffee", "Watching Movies", "Singing in Concert"]
    let images: [UIImage] = [#imageLiteral(resourceName: "lake"), #imageLiteral(resourceName: "i200"), #imageLiteral(resourceName: "i200-2"), #imageLiteral(resourceName: "i200-3"), #imageLiteral(resourceName: "i200-4"), #imageLiteral(resourceName: "i200-5"), #imageLiteral(resourceName: "i200-6"), #imageLiteral(resourceName: "lake"), #imageLiteral(resourceName: "i200"), #imageLiteral(resourceName: "i200-2"), #imageLiteral(resourceName: "i200-3"), #imageLiteral(resourceName: "i200-4"), #imageLiteral(resourceName: "i200-5"), #imageLiteral(resourceName: "i200-6"),#imageLiteral(resourceName: "lake"), #imageLiteral(resourceName: "i200"), #imageLiteral(resourceName: "i200-2"), #imageLiteral(resourceName: "i200-3"), #imageLiteral(resourceName: "i200-4"), #imageLiteral(resourceName: "i200-5"), #imageLiteral(resourceName: "i200-6"),#imageLiteral(resourceName: "lake"), #imageLiteral(resourceName: "i200"), #imageLiteral(resourceName: "i200-2"), #imageLiteral(resourceName: "i200-3"), #imageLiteral(resourceName: "i200-4"), #imageLiteral(resourceName: "i200-5"), #imageLiteral(resourceName: "i200-6"),#imageLiteral(resourceName: "lake"), #imageLiteral(resourceName: "i200"), #imageLiteral(resourceName: "i200-2"), #imageLiteral(resourceName: "i200-3"), #imageLiteral(resourceName: "i200-4"), #imageLiteral(resourceName: "i200-5"), #imageLiteral(resourceName: "i200-6"),#imageLiteral(resourceName: "lake"), #imageLiteral(resourceName: "i200"), #imageLiteral(resourceName: "i200-2"), #imageLiteral(resourceName: "i200-3"), #imageLiteral(resourceName: "i200-4"), #imageLiteral(resourceName: "i200-5"), #imageLiteral(resourceName: "i200-6"),#imageLiteral(resourceName: "lake"), #imageLiteral(resourceName: "i200"), #imageLiteral(resourceName: "i200-2"), #imageLiteral(resourceName: "i200-3"), #imageLiteral(resourceName: "i200-4"), #imageLiteral(resourceName: "i200-5"), #imageLiteral(resourceName: "i200-6"),#imageLiteral(resourceName: "lake"), #imageLiteral(resourceName: "i200"), #imageLiteral(resourceName: "i200-2"), #imageLiteral(resourceName: "i200-3"), #imageLiteral(resourceName: "i200-4"), #imageLiteral(resourceName: "i200-5"), #imageLiteral(resourceName: "i200-6"),#imageLiteral(resourceName: "lake"), #imageLiteral(resourceName: "i200"), #imageLiteral(resourceName: "i200-2"), #imageLiteral(resourceName: "i200-3"), #imageLiteral(resourceName: "i200-4"), #imageLiteral(resourceName: "i200-5"), #imageLiteral(resourceName: "i200-6")]
    //http://lorempixel.com/400/200/
    @IBAction func switchToCategoryFromButton(_ sender: Any) {
        let categoryDefaults = UserDefaults.standard
        switch (sender as AnyObject).tag {
        case 0:
            categoryDefaults.set("Coffee", forKey: "Category")
            break
        case 1:
            categoryDefaults.set("Dining", forKey: "Category")
            break
        case 2:
            categoryDefaults.set("Nightlife", forKey: "Category")
            break
        case 3:
            categoryDefaults.set("Party", forKey: "Category")
            break
        case 4:
            categoryDefaults.set("Fitness", forKey: "Category")
            break
        case 5:
            categoryDefaults.set("Gaming", forKey: "Category")
            break
        case 6:
            categoryDefaults.set("Study Group", forKey: "Category")
            break
        case 7:
            categoryDefaults.set("Causes", forKey: "Category")
            break
        case 8:
            categoryDefaults.set("Chill", forKey: "Category")
            break
        case 9:
            categoryDefaults.set("Others", forKey: "Category")
            break
        default:
            break
        }
        
        print("button press \(categoryDefaults.value(forKey: "Category") as! String)")
        
        performSegue(withIdentifier: "categoryDetail", sender: self)
    }
    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        let mosaicLayout = TRMosaicLayout()
        self.collectionView?.collectionViewLayout = mosaicLayout
        mosaicLayout.delegate = self
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Create Event",
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(eventBtn)
        )
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Profile",
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(profileBtn)
            
            
        )
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Home"
    }
    
    
    func eventBtn(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Events", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SelectionViewController") as UIViewController
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    func profileBtn(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! ProfileViewController
        controller.userId = Authenticator.currentFIRUser?.uid
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "categoryDetail", sender: self)
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 18
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        (cell.viewWithTag(1) as! UIImageView).image = images[indexPath.row]
        (cell.viewWithTag(2) as! UILabel).text = data[indexPath.row]
        return cell
    }
}

extension ViewController : TRMosaicLayoutDelegate {
    
    func collectionView(_ collectionView:UICollectionView, mosaicCellSizeTypeAtIndexPath indexPath:IndexPath) -> TRMosaicCellType {
        return indexPath.item % 3 == 0 ? TRMosaicCellType.big : TRMosaicCellType.small
    }
    
    func collectionView(_ collectionView:UICollectionView, layout collectionViewLayout: TRMosaicLayout, insetAtSection:Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.5, left: 0.5, bottom: 0.5, right: 0.5)
    }
    
    func heightForSmallMosaicCell() -> CGFloat {
        return 200
    }
}
