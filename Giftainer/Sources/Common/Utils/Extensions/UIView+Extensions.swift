//
//  UIView+Extensions.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 02/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    var isPortrait: Bool {
        return frame.size.isPortrait
    }
    
    var isLandscape: Bool {
        return frame.size.isLandscape
    }
    
    func constraint<Axis>(for anchor1: NSLayoutAnchor<Axis>, and anchor2: NSLayoutAnchor<Axis>) -> NSLayoutConstraint? {
        for constraint in constraints {
            if constraint.firstAnchor == anchor1 && constraint.secondAnchor == anchor2
                || (constraint.firstAnchor == anchor2 && constraint.secondAnchor == anchor1) {
                return constraint
            }
        }
        if let superview = superview {
            return superview.constraint(for: anchor1, and: anchor2)
        }
        return nil
    }
}
