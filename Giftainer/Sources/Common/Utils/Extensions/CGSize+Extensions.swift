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
    var mimizedNumberOfColumns: Int {
        return width < height ? 2 : 3
    }
    
    var maximizedNumberOfColumns: Int {
        return width < height ? 1 : 2
    }
}
