//
//  GiphyResponse.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 05/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation

struct GiphyResponse: Codable {
    let data: [GiphyGIF]

    //This initializer makes it possible to parse some valid nodes in the response array, invalid nodes are skipped
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode(FailableCodableArray<GiphyGIF>.self, forKey: .data).elements
    }
}

extension GiphyResponse: Convertible {
    
    func convert() -> [GIF] {
        return data.compactMap { $0.convert() }
    }
}
