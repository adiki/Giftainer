//
//  ViewControllersFactory.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 01/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation

class ViewControllersFactory {
    
    private let viewModelsFactory: ViewModelsFactory
    private let gifsCache: GIFsCache
    
    init(viewModelsFactory: ViewModelsFactory, gifsCache: GIFsCache) {
        self.viewModelsFactory = viewModelsFactory
        self.gifsCache = gifsCache
    }
    
    func makeFeedViewController() -> FeedViewController {
        let feedViewModel = viewModelsFactory.makeFeedViewModel()        
        return FeedViewController(feedViewModel: feedViewModel,
                                  gifsCache: gifsCache)
    }
}
