//
//  UIFont+Extensions.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 01/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import UIKit

extension UIFont {
        
    static func appMediumFont(ofSize size: CGFloat) -> UIFont {
        let boldFont = UIFont(name: "HelveticaNeue-Medium", size: size)!
        return UIFontMetrics.default.scaledFont(for: boldFont)
    }

    static func appBoldFont(ofSize size: CGFloat) -> UIFont {
        let boldFont = UIFont(name: "HelveticaNeue-Bold", size: size)!
        return UIFontMetrics.default.scaledFont(for: boldFont)
    }
}
