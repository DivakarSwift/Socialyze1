//
//  TutorialViewController.swift
//  Slide
//
//  Created by bibek timalsina on 10/4/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var startButtonBottomConstraint: NSLayoutConstraint! // 0
    @IBOutlet weak var startButton: UIButton!
    
    fileprivate var startButtonIsVisible: Bool {
        return self.startButtonBottomConstraint.constant == 0
    }
    
    fileprivate let images: [UIImage] = [#imageLiteral(resourceName: "Tutorial1"), #imageLiteral(resourceName: "Tutorial2"), #imageLiteral(resourceName: "Tutorial3")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startButtonBottomConstraint.constant = -startButton.frame.height
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    @IBAction func start(_ sender: Any) {
        GlobalConstants.UserDefaultKey.userSawTutorial.set(value: true)
        appDelegate.checkForLogin()
    }
}

extension TutorialViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let imageView = cell.viewWithTag(1) as? UIImageView
        imageView?.image = self.images.elementAt(index: indexPath.item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.pageControl.numberOfPages = self.images.count
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let visibleCellIndexPath = collectionView.indexPathsForVisibleItems.first {
            self.pageControl.currentPage = visibleCellIndexPath.item
            
            // if last cell
            if visibleCellIndexPath.item == self.images.count - 1 && !self.startButtonIsVisible {
                self.startButtonBottomConstraint.constant = 0
                UIView.animate(withDuration: 0.33, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }else if self.startButtonIsVisible && visibleCellIndexPath.item < self.images.count - 1 {
                self.startButtonBottomConstraint.constant = -self.startButton.frame.height
                UIView.animate(withDuration: 0.33, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
        }
    }
}
