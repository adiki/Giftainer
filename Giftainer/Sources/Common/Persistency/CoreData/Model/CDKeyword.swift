//
//  CDKeyword.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 02/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import CoreData

class CDKeyword: NSManagedObject {    
}

extension CDKeyword: Convertible {
    func convert() -> Keyword {
        return Keyword()
    }
}

extension CDKeyword: Managed {
}
