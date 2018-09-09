//
//  ReferencesBag.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 04/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation

class ReferencesBag {
    
    private var tokens: [AnyObject] = []
    
    func append(_ token: AnyObject) {
        tokens.append(token)
    }
}
