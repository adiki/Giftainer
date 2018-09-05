//
//  NSFetchedResultsController+Extensions.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 05/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import CoreData

extension NSFetchedResultsController {
    
    @objc
    var numberOfObjects: Int {
        return sections?.reduce(0) { $0 + $1.numberOfObjects } ?? 0
    }
}
