//
//  GiphyMetadataFetcher.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 05/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import RxSwift

class GiphyMetadataFetcher: GIFsMetadataFetcher {
    
    private let baseURLString = "https://api.giphy.com/v1/gifs/"
    private let webAPICommunicator: WebAPICommunicator
    
    init(webAPICommunicator: WebAPICommunicator) {
        self.webAPICommunicator = webAPICommunicator
    }
    
    func fetchPopularGIFs() -> Single<[GIF]> {
        var parameters = makeBaseParameters()
        parameters["limit"] = 50
        let popularGIFsMethod = WebAPIMethod<GiphyResponse>(urlString: baseURLString + "trending",
                                                            parameters: parameters)
        return webAPICommunicator.GET(method: popularGIFsMethod)
            .map { $0.convert() }
        
    }
    
    func fetchGIFs(searchText: String) -> Single<[GIF]> {
        var parameters = makeBaseParameters()
        parameters["q"] = searchText.keywords().map { $0.value }.joined(separator: "+")
        let gifsMethod = WebAPIMethod<GiphyResponse>(urlString: baseURLString + "search",
                                                     parameters: parameters)
        return webAPICommunicator.GET(method: gifsMethod)
            .map { $0.convert() }
    }
    
    private func makeBaseParameters() -> [String: Any] {
        return ["api_key": "0eeeijZDpk8uzzCOsuWthiyEFIzYr8tj"]
    }
}
