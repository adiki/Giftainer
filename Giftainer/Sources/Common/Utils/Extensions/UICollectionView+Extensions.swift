//
//  UICollectionView+Extensions.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 09/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView {
    
    var giftainerLayout: GiftainerLayout? {
        return collectionViewLayout as? GiftainerLayout
    }
}
