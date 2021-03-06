//
//  CGSize.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 06/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import UIKit

extension CGSize {
    
    var isPortrait: Bool {
        return width < height
    }
    
    var isLandscape: Bool {
        return width > height
    }
}
