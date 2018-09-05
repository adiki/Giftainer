//
//  TokensBag.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 04/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation

class TokensBag {
    
    private var tokens: [Any] = []
    
    func append(_ token: Any) {
        tokens.append(token)
    }
}
