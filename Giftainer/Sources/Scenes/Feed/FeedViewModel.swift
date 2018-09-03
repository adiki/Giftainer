//
//  FeedViewModel.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 02/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class FeedViewModel {
    
    let gifsProvider: AnyObjectsProvider<GIF>
    
    let searchText: Observable<String>
    let isNoGIFsInfoHidden: Observable<Bool>
    
    private let searchTextBehaviorRelay: BehaviorRelay<String>
    private let persistencyManager: PersistencyManager
    private let disposeBag = DisposeBag()
    
    init(persistencyManager: PersistencyManager) {
        self.persistencyManager = persistencyManager
        gifsProvider = persistencyManager.makeGIFsProvider()
        let searchTextBehaviorRelay = BehaviorRelay(value: "")
        self.searchTextBehaviorRelay = searchTextBehaviorRelay
        searchText = searchTextBehaviorRelay.asObservable()
        isNoGIFsInfoHidden = Observable
            .combineLatest(gifsProvider.numberOfObjects, searchText)
            .map { $0 > 0 || !$1.isEmpty }        
    }
    
    func accept<Observable: ObservableType>(searchInput: Observable) where Observable.E == String {
        searchInput
            .bind(to: searchTextBehaviorRelay)
            .disposed(by: disposeBag)
    }
}
