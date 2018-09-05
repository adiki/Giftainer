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
    @NSManaged private(set) var date: NSDate
    @NSManaged private(set) var width: Int16
    @NSManaged private(set) var height: Int16
    @NSManaged private(set) var mp4URLString: String
    @NSManaged private(set) var stillURLString: String
    @NSManaged private(set) var keywords: Set<CDKeyword>
    
    static func findOrCreate(gif: GIF, in context: NSManagedObjectContext) -> CDGIF {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(id), gif.id)
        let cdGIF = findOrCreate(in: context, matching: predicate)
        if cdGIF.id != gif.id {
            cdGIF.id = gif.id
        }
        if cdGIF.date != gif.date as NSDate {
            cdGIF.date = gif.date as NSDate
        }
        if cdGIF.width != Int16(gif.width) {
            cdGIF.width = Int16(gif.width)
        }
        if cdGIF.height != Int16(gif.height) {
            cdGIF.height = Int16(gif.height)
        }
        if cdGIF.mp4URLString != gif.mp4URLString {
            cdGIF.mp4URLString = gif.mp4URLString
        }
        if cdGIF.stillURLString != gif.stillURLString {
            cdGIF.stillURLString = gif.stillURLString
        }
        for keyword in gif.keywords {
            let cdKeyword = CDKeyword.findOrCreate(keyword: keyword, in: context)
            if !cdGIF.keywords.contains(cdKeyword) {
                cdGIF.keywords.insert(cdKeyword)
            }            
        }
        return cdGIF
    }
}

extension CDGIF: Convertible {
    
    func convert() -> GIF {
        return GIF(id: id,
                   date: date as Date,
                   width: Int(width),
                   height: Int(height),
                   mp4URLString: mp4URLString,
                   stillURLString: stillURLString,
                   keywords: keywords.map { $0.convert() })
    }
}
