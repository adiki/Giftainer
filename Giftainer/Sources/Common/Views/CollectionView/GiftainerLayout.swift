//
//  GiftainerLayout.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 06/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import UIKit

protocol GiftainerLayoutDelegate: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, sizeAtIndexPath indexPath: IndexPath) -> CGSize
}

class GiftainerLayout: UICollectionViewLayout {
    
    weak var delegate: GiftainerLayoutDelegate? {
        return collectionView?.delegate as? GiftainerLayoutDelegate
    }
    
    var numberOfColumns = 0 {
        didSet {
            invalidateLayout()
        }
    }
    private let cellPadding: CGFloat = 15
    
    
    private var cache = [UICollectionViewLayoutAttributes]()
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let safeAreaInsets = collectionView.safeAreaInsets
        return collectionView.bounds.width - (safeAreaInsets.left + safeAreaInsets.right)
    }
    private var contentHeight: CGFloat = 0
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        
        guard let collectionView = collectionView,
            let delegate = delegate else {
                return
        }
        if numberOfColumns == 0 {
            numberOfColumns = collectionView.frame.size.mimizedNumberOfColumns
        }
        cache = []
        contentHeight = 0
        
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset = [CGFloat]()
        for column in 0..<numberOfColumns {
            xOffset.append(collectionView.safeAreaInsets.left + CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            
            let minOffset = yOffset.min()!
            column = yOffset.index(of: minOffset)!
            
            let indexPath = IndexPath(item: item, section: 0)
            
            let size = delegate.collectionView(collectionView, sizeAtIndexPath: indexPath)
            let gifHeight = (columnWidth - (numberOfColumns == 1 ? 2 : 1.5) * cellPadding) / size.width * size.height
            let height = gifHeight + cellPadding
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            var insetFrame = frame
            if column == 0 {
                insetFrame.origin.x += cellPadding
            } else if column == numberOfColumns - 1 {
                insetFrame.origin.x += 0.5 * cellPadding
            } else {
                insetFrame.origin.x += 0.75 * cellPadding
            }
            insetFrame.size.width -= (numberOfColumns == 1 ? 2 : 1.5) * cellPadding
            insetFrame.origin.y += cellPadding
            insetFrame.size.height -= cellPadding
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if indexPath.row >= cache.count {
            return nil
        }
        return cache[indexPath.item]
    }
}
