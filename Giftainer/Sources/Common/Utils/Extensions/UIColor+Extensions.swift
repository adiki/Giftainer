//
//  UIColor+Extensions.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 01/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import UIKit

extension UIColor {
    
    static let snapperRocksBlue = UIColor(rgb: 0x19A0BE)
    static let lightSnapperRocksBlue = UIColor(rgb: 0x3EAAC4)
    
    convenience init(rgb: Int) {
        self.init(red: (rgb >> 16) & 0xff, green: (rgb >> 8) & 0xff, blue: rgb & 0xff)
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
}
