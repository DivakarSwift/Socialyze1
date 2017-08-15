//
//  SnapchatLikeFlowLayout.swift
//  Slide
//
//  Created by bibek timalsina on 8/15/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit

class SnapchatLikeFlowLayout: UICollectionViewFlowLayout {

    private var cellLayouts: [IndexPath: UICollectionViewLayoutAttributes]
    private let unitHeight: CGFloat
    private let padding: CGFloat
    
    required init(unitHeight: CGFloat, padding: CGFloat) {
        self.unitHeight = unitHeight
        self.padding = padding
        self.cellLayouts = [:]
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        let max = self.collectionView?.numberOfItems(inSection: 0) ?? 0
        var startOrigin: CGPoint = .zero
        
        let availableWidth = (self.collectionView?.frame.width ?? padding) - padding
        let unitSize = CGSize(width: availableWidth/2, height: unitHeight)
        
        stride(from: 0, to: max, by: 10).forEach { (index) in
            
            func setAttribute(frame: CGRect, index: Int) {
                let indexPath = IndexPath(item: index, section: 0)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                if index < max {
                    self.cellLayouts[indexPath] = attributes
                }
            }
            
            let largeCellHeight = (unitSize.height * 2) + padding
            let semiLargeCellHeight = largeCellHeight * 0.8
            
            
            let first = CGRect(x: startOrigin.x, y: startOrigin.y + padding, width: unitSize.width*1.25, height: largeCellHeight)
            setAttribute(frame: first, index: index)
            
            let second = CGRect(x: first.maxX + padding, y: first.minY, width: unitSize.width*0.75, height: unitSize.height)
            setAttribute(frame: second, index: index + 1)
            
            let third = CGRect(x: second.minX, y: second.maxY + padding, width: unitSize.width*0.75, height: unitSize.height)
            setAttribute(frame: third, index: index + 2)
            
            // Equal width
            let fourth = CGRect(x: first.minX, y: first.maxY + padding, width: unitSize.width, height: semiLargeCellHeight)
            setAttribute(frame: fourth, index: index + 3)
            
            let fifth = CGRect(x: fourth.maxX + padding, y:fourth.minY, width: unitSize.width, height: semiLargeCellHeight)
            setAttribute(frame: fifth, index: index + 4)
            
            
            
            
            let sixth = CGRect(x: fourth.minX, y: fourth.maxY + padding, width: unitSize.width*0.75, height: unitSize.height)
            setAttribute(frame: sixth, index: index + 5)
            
            let seventh = CGRect(x: sixth.maxX + padding, y: sixth.minY, width: unitSize.width*1.25, height: largeCellHeight)
            setAttribute(frame: seventh, index: index + 6)
            
            let eighth = CGRect(x: sixth.minX, y: sixth.maxY + padding, width: unitSize.width*0.75, height: unitSize.height)
            setAttribute(frame: eighth, index: index + 7)
            
            // Equal width
            let nineth = CGRect(x: eighth.minX, y:eighth.maxY + padding, width: unitSize.width, height: semiLargeCellHeight)
            setAttribute(frame: nineth, index: index + 8)
            
            let tenth = CGRect(x: nineth.maxX + padding, y:nineth.minY, width: unitSize.width, height: semiLargeCellHeight)
            setAttribute(frame: tenth, index: index + 9)
            
            startOrigin = CGPoint(x: startOrigin.x, y: tenth.maxY)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cellLayouts.values.filter({$0.frame.intersects(rect)})
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cellLayouts[indexPath]
    }
    
    override var collectionViewContentSize: CGSize {
        
        let height = cellLayouts.sorted(by: {$0.value.frame.maxY > $1.value.frame.maxY}).first?.value.frame.maxY ?? 0
        
        return CGSize(width: self.collectionView?.frame.width ?? 0, height: height)
    }
}
