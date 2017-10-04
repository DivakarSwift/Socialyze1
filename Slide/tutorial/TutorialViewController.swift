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
    
    fileprivate let images: [UIImage] = [#imageLiteral(resourceName: "Tutorial1"), #imageLiteral(resourceName: "Tutorial2"), #imageLiteral(resourceName: "Tutorial3")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension TutorialViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let imageView = cell.viewWithTag(1) as? UIImageView
        imageView?.image = self.images.elementAt(index: indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.pageControl.numberOfPages = self.images.count
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let visibleCellIndexPath = collectionView.indexPathsForVisibleItems.first {
            self.pageControl.currentPage = visibleCellIndexPath.row
        }
    }
}
