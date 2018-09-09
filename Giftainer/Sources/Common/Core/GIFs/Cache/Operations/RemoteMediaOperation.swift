//
//  RemoteMediaOperation.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 09/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

class RemoteMediaOperation: ConcurrentOperation {
    
    let webAPICommunicator: WebAPICommunicator
    let remoteURLString: String
    let localURL: URL
    let fileManager: FileManager
    
    init(webAPICommunicator: WebAPICommunicator, remoteURLString: String, localURL: URL, fileManager: FileManager) {
        self.webAPICommunicator = webAPICommunicator
        self.remoteURLString = remoteURLString
        self.localURL = localURL
        self.fileManager = fileManager
    }
}
