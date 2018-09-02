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
    
    init(viewModelsFactory: ViewModelsFactory) {
        self.viewModelsFactory = viewModelsFactory
    }
    
    func makeFeedViewController() -> FeedViewController {
        let feedViewModel = viewModelsFactory.makeFeedViewModel()
        return FeedViewController(feedViewModel: feedViewModel)
    }
}
