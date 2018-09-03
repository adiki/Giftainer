//
//  FeedViewModel.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 02/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class FeedViewModel {
    
    let gifsProvider: AnyObjectsProvider<GIF>
    
    let isNoGIFsInfoHidden: Observable<Bool>    
 
    private let persistencyManager: PersistencyManager
    
    init(persistencyManager: PersistencyManager) {
        self.persistencyManager = persistencyManager
        gifsProvider = persistencyManager.makeGIFsProvider()
        isNoGIFsInfoHidden = gifsProvider.numberOfObjects.map { $0 > 0 }
    }
}
