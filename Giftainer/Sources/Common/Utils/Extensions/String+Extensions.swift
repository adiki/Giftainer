//
//  String+Extensions.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 01/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    static let Search = localize("Search")
    static let Your_search_history_appear_here = localize("Your_search_history_appear_here")
    static let No_results_found = localize("No_results_found")
    static let We_have_an_issue_will_get_back_to_you = localize("We_have_an_issue_will_get_back_to_you")
    static let Download_failed = localize("Download_failed")
    static let Single_tap_maximises_layout = localize("Single_tap_maximises_layout")
    static let Single_tap_minimises_layout = localize("Single_tap_minimises_layout")
    static let Double_tap_shares_gif = localize("Double_tap_shares_gif")
    static let Swipe_right_shares_gif = localize("Swipe_right_shares_gif")
    static let Swipe_left_deletes_gif = localize("Swipe_left_deletes_gif")
    
    static let isLayoutMaximised = "isLayoutMaximised"
    static let wasTapTooltipPresented = "wasTapTooltipPresented"
    static let wasSwipeTooltipPresented = "wasSwipeTooltipPresented"
    
    static func localize(_ string: String) -> String {
        return NSLocalizedString(string, tableName: nil, comment: "")
    }
    
    func keywords() -> [Keyword] {
        if let regex = try? NSRegularExpression(pattern: "\\w+", options: .caseInsensitive) {
            let string = self as NSString
            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
                Keyword(value: string.substring(with: $0.range).lowercased())
            }
        }
        return []
    }
    
    var color: UIColor {
        return UIColor(rgb: hashValue & 0xFFFFFF)
    }
}
