//
//  ViewModelsFactory.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 02/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation

class ViewModelsFactory {
    
    let gifsManager: GIFsManager
    let objectsManager: ObjectsManager
    
    init(gifsManager: GIFsManager, objectsManager: ObjectsManager) {
        self.gifsManager = gifsManager
        self.objectsManager = objectsManager
    }
 
    func makeFeedViewModel() -> FeedViewModel {
        let userDefaults = UserDefaults.standard
        return FeedViewModel(gifsManager: gifsManager,
                             objectsManager: objectsManager,
                             userDefaults: userDefaults)
    }
}
