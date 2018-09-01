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
    
    convenience init(rgb:Int) {
        self.init(r:(rgb >> 16) & 0xff, g:(rgb >> 8) & 0xff, b:rgb & 0xff)
    }
    
    convenience init(r: Int, g: Int, b: Int) {
        assert(r >= 0 && r <= 255, "Invalid red component")
        assert(g >= 0 && g <= 255, "Invalid green component")
        assert(b >= 0 && b <= 255, "Invalid blue component")
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1.0)
    }
}
