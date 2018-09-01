//
//  String+Extensions.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 01/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation

extension String {
    
    static let Giftainer = "Giftainer"
    static let Search = localize("Search")
    
    static func localize(_ string: String) -> String {
        return NSLocalizedString(string, tableName: nil, comment: "")
    }
}
