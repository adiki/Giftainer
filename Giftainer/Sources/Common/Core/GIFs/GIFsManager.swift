//
//  GIFsManager.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 04/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import RxSwift

class GIFsManager {
    
    func fetchPopularGIFs() -> Completable {
        return Completable.create(subscribe: { observer in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                observer(.completed)
            }
            return Disposables.create()
        })
    }
    
    func fetchGIFs(keyword: String) -> Completable {
        return Completable.create(subscribe: { observer in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                observer(.completed)
            }
            return Disposables.create()
        })
    }
}
