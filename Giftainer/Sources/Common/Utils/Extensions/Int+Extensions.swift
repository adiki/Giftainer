//
//  Int+Extensions.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 10/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation

extension Int {
    var megaBytes: Int {
        return self / 1024 / 1024
    }
}

extension UInt64 {
    var megaBytes: UInt64 {
        return self / 1024 / 1024
    }
}
