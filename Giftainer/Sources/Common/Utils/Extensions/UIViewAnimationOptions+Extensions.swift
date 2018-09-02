//
//  UIViewAnimationOptions+Extensions.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 02/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import UIKit

extension UIViewAnimationOptions {
    
    var curve: UIViewAnimationCurve {
        switch self {
        case .curveEaseInOut:
            return .easeInOut
        case .curveEaseIn:
            return .easeIn
        case .curveEaseOut:
            return .easeOut
        case .curveLinear:
            return .linear
        default:
            return .easeInOut
        }
    }
}
