//
//  GiphyGIF.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 05/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation

struct GiphyGIF: Codable {
    let id: String
    let import_datetime: Date
    let images: GiphyImages    
}

extension GiphyGIF: Convertible {
    
    func convert() -> GIF? {
        guard let width = Int(images.mp4.width),
            let height = Int(images.mp4.width) else {
                return nil
        }
        return GIF(id: "giphy:\(id)",
                   date: import_datetime,
                   width: width,
                   height: height,
                   mp4URLString: images.mp4.mp4,
                   stillURLString: images.still.url,
                   keywords: [])
    }
}
