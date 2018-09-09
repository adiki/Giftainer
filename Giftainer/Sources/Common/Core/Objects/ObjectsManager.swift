//
//  ObjectsManager.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 02/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import RxSwift

protocol ObjectsManager {
    
    func makeGIFsProvider() -> AnyObjectsProvider<GIF>
    func save(gifs: [GIF]) -> Completable
    func remove(gif: GIF)
    
    static func makeObjectsManager(completion: @escaping (ObjectsManager) -> Void)
}
