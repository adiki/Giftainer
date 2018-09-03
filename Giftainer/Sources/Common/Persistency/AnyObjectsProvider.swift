//
//  AnyObjectsProvider.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 03/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import RxSwift

//This class uses Type Erasure, it's a useful technique when working with protocols with associatedtype
class AnyObjectsProvider<T>: ObjectsProvider {
    
    private let _updates: Observable<[Update<T>]>
    private let _object: (IndexPath) -> T
    
    let numberOfObjects: Observable<Int>
    var updates: Observable<[Update<T>]> {
        return _updates
    }
    
    init<OP: ObjectsProvider>(objectsProvider: OP) where OP.Object == T {
        numberOfObjects = objectsProvider.numberOfObjects
        _updates = objectsProvider.updates
        _object = objectsProvider.object(at:)
    }
    
    func object(at indexPath: IndexPath) -> T {
        return _object(indexPath)
    }
}
