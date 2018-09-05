//
//  CDGIF.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 02/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import CoreData

class CDGIF: NSManagedObject {    
}

extension CDGIF: Convertible {    
    func convert() -> GIF {
        return GIF()
    }
}

extension CDGIF: Managed {
}
