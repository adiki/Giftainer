//
//  Update.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 02/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation

enum Update {
    case insert(IndexPath)
    case update(IndexPath)
    case move(IndexPath, IndexPath)
    case delete(IndexPath)
}
