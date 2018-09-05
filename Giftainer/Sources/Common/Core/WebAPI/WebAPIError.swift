//
//  WebAPIError.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 05/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation

enum WebAPIError {
    case invalidResponse
}

extension WebAPIError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return .We_have_an_issue_will_get_back_to_you
        }
    }
}
