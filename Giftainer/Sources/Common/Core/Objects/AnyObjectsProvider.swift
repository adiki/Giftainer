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
        
    let updates: Observable<[Update]>    
    
    init<OP: ObjectsProvider>(objectsProvider: OP) where OP.Object == T {
        
        updates = objectsProvider.updates
        _numberOfObjects = objectsProvider.numberOfObjects
        _object = objectsProvider.object
        _set = objectsProvider.set
    }
    
    private let _numberOfObjects: () -> Int
    
    func numberOfObjects() -> Int {
        return _numberOfObjects()
    }
    
    private let _object: (IndexPath) -> T
    
    func object(at indexPath: IndexPath) -> T {
        return _object(indexPath)
    }
    
    private let _set: (NSPredicate) -> Void
    
    func set(predicate: NSPredicate) {
        _set(predicate)
    }
}
