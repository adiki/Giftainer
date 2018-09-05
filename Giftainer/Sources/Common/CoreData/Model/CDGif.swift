//
//  CDGIF.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 02/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import CoreData

class CDGIF: NSManagedObject, Managed {
    
    @NSManaged private(set) var id: String
    @NSManaged private(set) var date: Date
    @NSManaged private(set) var width: Int
    @NSManaged private(set) var height: Int
    @NSManaged private(set) var mp4URLString: String
    @NSManaged private(set) var stillURLString: String
}

extension CDGIF: Convertible {
    
    func convert() -> GIF {
        return GIF(id: id,
                   date: date,
                   width: width,
                   height: height,
                   mp4URLString: mp4URLString,
                   stillURLString: stillURLString)
    }
}
