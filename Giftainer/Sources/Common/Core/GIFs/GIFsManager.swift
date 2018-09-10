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
    private let objectsManager: ObjectsManager
    
    init(gifsMetadataFetcher: GIFsMetadataFetcher, objectsManager: ObjectsManager) {
        self.gifsMetadataFetcher = gifsMetadataFetcher
        self.objectsManager = objectsManager
    }
    
    func fetchAndSavePopularGIFs() -> Completable {
        return gifsMetadataFetcher.fetchPopularGIFs()
            .flatMapCompletable(objectsManager.save)
    }
    
    func fetchAndSaveGIFs(searchText: String) -> Completable {        
        return gifsMetadataFetcher.fetchGIFs(searchText: searchText)
            .map { gifs in
                let keywords = searchText.keywords()
                return gifs.map { $0.with(keywords: keywords) }
            }
            .flatMapCompletable(objectsManager.save)
    }
}
