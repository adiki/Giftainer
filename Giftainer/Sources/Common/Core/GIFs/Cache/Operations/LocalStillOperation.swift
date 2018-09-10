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
        if let image = UIImage(contentsOfFile: url.path) {
            if !isCancelled {
                resultPublishSubject.onNext(image.decoded())             
            }
            resultPublishSubject.onCompleted()
        } else {
            resultPublishSubject.onError(GIFsError.imageNotPersistent)
        }
    }
}
