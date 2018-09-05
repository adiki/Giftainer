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
    
    var numberOfObjects: Observable<Int> { get }
    var updates: Observable<[Update<Object>]> { get }
    
    func object(at indexPath: IndexPath) -> Object
}
