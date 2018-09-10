//
//  GIFsError.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 09/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation

enum GIFsError: Error {
    case imageNotPersistent
    case mp4NotPersistent
    case cannotCreateAnimatedImage
    case operationCancelled
    case cannotReadDataFromDisk
    case cannotSaveImageOnDisk
    case cannotSaveMP4OnDisk
}
