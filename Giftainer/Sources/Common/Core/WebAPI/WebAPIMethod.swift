//
//  WebAPIMethod.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 05/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation

struct WebAPIMethod<SuccessResponse: Decodable> {
    
    var urlWithEncodedParameters: URL {
        var urlComponents = URLComponents(string: urlString)!
        urlComponents.queryItems = parameters
            .map { ($0, String(describing: $1)) }
            .map(URLQueryItem.init)
        return urlComponents.url!
    }
    
    private let urlString: String
    private let parameters: [String: Any]
    
    init(urlString: String, parameters: [String: Any]) {
        self.urlString = urlString
        self.parameters = parameters
    }
    
    
}
