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
    
    func constraint<Axis>(for anchor: NSLayoutAnchor<Axis>) -> NSLayoutConstraint? {        
        for constraint in constraints {
            if constraint.firstAnchor == anchor || constraint.secondAnchor == anchor {
                return constraint
            }
        }
        if let superview = superview {
            return superview.constraint(for: anchor)
        }
        return nil
    }
}
