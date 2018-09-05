//
//  ViewModelsFactory.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 02/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation

class ViewModelsFactory {
    
    let gifsManager = GIFsManager()
    let objectsManager: ObjectsManager
    
    init(objectsManager: ObjectsManager) {
        self.objectsManager = objectsManager
    }
 
    func makeFeedViewModel() -> FeedViewModel {
        return FeedViewModel(gifsManager: gifsManager,
                             objectsManager: objectsManager)
    }
}
