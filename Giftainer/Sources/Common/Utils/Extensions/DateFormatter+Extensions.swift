//
//  DateFormatter+Extensions.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 05/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    static let webAPIDateFormater: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}
