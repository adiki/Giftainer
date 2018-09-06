//
//  GiftainerCollectionView.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 01/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import UIKit

class GiftainerCollectionView: UICollectionView {
    
    var giftainerLayout: GiftainerLayout? {
        return collectionViewLayout as? GiftainerLayout
    }
    
    init() {
        super.init(frame: .zero, collectionViewLayout: GiftainerLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
