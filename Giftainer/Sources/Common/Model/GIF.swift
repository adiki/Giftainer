//
//  GIF.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 02/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation

struct GIF {
    let id: String
    let date: Date
    let width: Int
    let height: Int
    let mp4URLString: String
    let stillURLString: String
    private(set) var keywords: [Keyword]
    
    func with(keywords: [Keyword]) -> GIF {
        var copy = self
        copy.keywords = keywords
        return copy
    }
}
