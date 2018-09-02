//
//  PersistencyManager.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 02/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation

protocol PersistencyManager {
    
    func makeGIFsProvider() -> ObjectsProvider<GIF>
    
    static func makePersistencyManager(completion: @escaping (PersistencyManager) -> Void)
}
