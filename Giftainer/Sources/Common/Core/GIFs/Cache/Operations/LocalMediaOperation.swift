//
//  LocalMediaOperation.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 09/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

class LocalMediaOperation: Operation {
    
    let url: URL
    let result: Observable<UIImage>
    let resultPublishSubject = PublishSubject<UIImage>()
    
    init(url: URL) {
        self.url = url
        self.result = resultPublishSubject.asObservable()        
        super.init()
    }
    
    override func cancel() {
        super.cancel()
        resultPublishSubject.dispose()
    }
}
