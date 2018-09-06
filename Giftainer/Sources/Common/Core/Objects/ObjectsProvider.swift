//
//  ModelsProvider.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 02/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import RxSwift

protocol ObjectsProvider {
    
    associatedtype Object
    
    var updates: Observable<[Update<Object>]> { get }
    
    func numberOfObjects() -> Int
    func object(at indexPath: IndexPath) -> Object
}
