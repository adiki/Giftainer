//
//  GiphyImages.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 05/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation

struct GiphyImages: Codable {
    
    enum CodingKeys: String, CodingKey {
        case mp4 = "original_mp4"
        case still = "original_still"
    }
    
    let mp4: GiphyMP4
    let still: GiphyStill
}
