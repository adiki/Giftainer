//
//  LocalStillOperation.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 09/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import UIKit

class LocalStillOperation: LocalMediaOperation {
    
    override func main() {
        if let data = try? Data(contentsOf: url) {
            if let image = UIImage(data: data) {
                if !isCancelled {
                    resultPublishSubject.onNext(image.decoded())
                    resultPublishSubject.onCompleted()
                } else {
                    resultPublishSubject.onError(GIFsError.operationCancelled)
                }
            } else {
                resultPublishSubject.onNext(UIImage())
                resultPublishSubject.onCompleted()
            }
        } else {
            resultPublishSubject.onError(GIFsError.imageNotPersistent)
        }
        resultPublishSubject.dispose()
    }
}
