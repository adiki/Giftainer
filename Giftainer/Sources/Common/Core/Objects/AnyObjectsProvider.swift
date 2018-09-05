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
    
    let numberOfObjects: Observable<Int>
    let updates: Observable<[Update<T>]>    
    
    init<OP: ObjectsProvider>(objectsProvider: OP) where OP.Object == T {
        numberOfObjects = objectsProvider.numberOfObjects
        updates = objectsProvider.updates
        _object = objectsProvider.object(at:)
    }
    
    private let _object: (IndexPath) -> T
    
    func object(at indexPath: IndexPath) -> T {
        return _object(indexPath)
    }
}
