//
//  WebAPICommunicator.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 05/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class WebAPICommunicator {
    
    private let urlSession: URLSession
    private let decoder: JSONDecoder

    init(urlSession: URLSession, decoder: JSONDecoder) {
        self.urlSession = urlSession
        self.decoder = decoder
        decoder.dateDecodingStrategy = .formatted(.webAPIDateFormater)
        
        Logging.URLRequests = { _ in return true }
    }
    
    static func makeWebAPICommunicator() -> WebAPICommunicator {
        let urlSession = URLSession.shared
        let decoder = JSONDecoder()
        return WebAPICommunicator(urlSession: urlSession, decoder: decoder)
    }
    
    func GET<SuccessResponse>(method: WebAPIMethod<SuccessResponse>) -> Single<SuccessResponse> {
        let request = makeGETRequest(method: method)
        return urlSession.rx.data(request: request)
            .asSingle()
            .flatMap(handleResponse)
    }
    
    private func makeGETRequest<SuccessResponse>(method: WebAPIMethod<SuccessResponse>) -> URLRequest {
        let url = method.urlWithEncodedParameters
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
    
    private func handleResponse<SuccessResponse: Decodable>(data: Data) -> Single<SuccessResponse> {
        
        return Single.create(subscribe: { [decoder] observer in
            guard let response = try? decoder.decode(SuccessResponse.self, from: data) else {
                observer(.error(WebAPIError.invalidResponse))
                return Disposables.create()
            }
            observer(.success(response))
            return Disposables.create()
        })
    }
}
