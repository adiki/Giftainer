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
    static let No_results_found = localize("No_results_found")
    static let We_have_an_issue_will_get_back_to_you = localize("We_have_an_issue_will_get_back_to_you")    
    
    static func localize(_ string: String) -> String {
        return NSLocalizedString(string, tableName: nil, comment: "")
    }
}
