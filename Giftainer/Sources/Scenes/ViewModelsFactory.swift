//
//  ViewModelsFactory.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 02/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation

class ViewModelsFactory {
    
    let persistencyManager: PersistencyManager
    
    init(persistencyManager: PersistencyManager) {
        self.persistencyManager = persistencyManager
    }
 
    func makeFeedViewModel() -> FeedViewModel {
        return FeedViewModel(persistencyManager: persistencyManager)
    }
}
