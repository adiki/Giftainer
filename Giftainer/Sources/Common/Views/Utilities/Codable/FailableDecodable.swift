//
//  FailableDecodable.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 05/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation

struct FailableDecodable<Base: Decodable> : Decodable {
    
    let base: Base?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.base = try? container.decode(Base.self)
    }
}
