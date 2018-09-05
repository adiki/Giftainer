//
//  CDKeyword.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 02/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import CoreData

class CDKeyword: NSManagedObject, Managed {
    
    @NSManaged private(set) var value: String
    
    static func findOrCreate(keyword: Keyword, in context: NSManagedObjectContext) -> CDKeyword {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(value), keyword.value)
        let cdKeyword = findOrCreate(in: context, matching: predicate) 
        if cdKeyword.value != keyword.value {
            cdKeyword.value = keyword.value
        }
        return cdKeyword
    }
}

extension CDKeyword: Convertible {
    func convert() -> Keyword {
        return Keyword(value: value)
    }
}
