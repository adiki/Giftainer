//
//  ModelsProvider.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 02/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import RxSwift

class ObjectsProvider<Object>: NSObject {
    
    let numberOfObjects: Observable<Int>
    let updates: Observable<[Update<Object>]>
    
    init(numberOfObjects: Observable<Int>,
                  updates: Observable<[Update<Object>]>) {
        self.numberOfObjects = numberOfObjects
        self.updates = updates
    }
    
    func object(at indexPath: IndexPath) -> Object {
        fatalError("This is abstract class")
    }
}
