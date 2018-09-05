//
//  GIFsMetadataFetcher.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 05/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import RxSwift

protocol GIFsMetadataFetcher {
    func fetchPopularGIFs() -> Single<[GIF]>
    func fetchGIFs(keyword: String) -> Single<[GIF]>
}
