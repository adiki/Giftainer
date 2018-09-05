//
//  GIFsManager.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 04/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import RxSwift

class GIFsManager {
    
    private let gifsMetadataFetcher: GIFsMetadataFetcher    
    
    init(gifsMetadataFetcher: GIFsMetadataFetcher) {
        self.gifsMetadataFetcher = gifsMetadataFetcher
    }
    
    func fetchPopularGIFs() -> Completable {
        return gifsMetadataFetcher.fetchPopularGIFs()
            .asObservable()
            .ignoreElements()
    }
    
    func fetchGIFs(keyword: String) -> Completable {
        return gifsMetadataFetcher.fetchGIFs(keyword: keyword)
            .asObservable()
            .ignoreElements()
    }
}
