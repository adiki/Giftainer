//
//  String+Extensions.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 01/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation

extension String {
    
    static let Search = localize("Search")
    static let Your_search_history_appear_here = localize("Your_search_history_appear_here")
    
    static func localize(_ string: String) -> String {
        return NSLocalizedString(string, tableName: nil, comment: "")
    }
    
    func removingCharacters(in set: CharacterSet) -> String {
        var chars = self
        for idx in chars.indices.reversed() {
            if set.contains(String(chars[idx]).unicodeScalars.first!) {
                chars.remove(at: idx)
            }
        }
        return String(chars)
    }
}