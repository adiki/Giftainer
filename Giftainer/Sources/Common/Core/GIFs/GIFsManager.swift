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
    
    func fetchPopularGIFs() -> Completable {
        return gifsMetadataFetcher.fetchPopularGIFs()
            .flatMap { [objectsManager] gifs in
                return objectsManager.save(gifs: gifs)                    
                    .asObservable()
                    .map { _ in () }
                    .asSingle()
            }
            .asObservable()
            .ignoreElements()
    }
    
    func fetchGIFs(searchText: String) -> Completable {
        let keywords = searchText.keywords()
        return gifsMetadataFetcher.fetchGIFs(searchText: searchText)
            .map { gifs in                
                return gifs.map { $0.with(keywords: keywords) }
            }
            .flatMap { [objectsManager] gifs in
                return objectsManager.save(gifs: gifs)
                    .asObservable()
                    .map { _ in () }
                    .asSingle()
            }
            .asObservable()
            .ignoreElements()
    }
}
