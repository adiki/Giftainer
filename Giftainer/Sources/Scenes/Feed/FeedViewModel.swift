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
    let isNoResultsInfoHidden: Observable<Bool>
    let isActivityInProgress: Observable<Bool>
    
    private let searchTextBehaviorRelay: BehaviorRelay<String>
    private let numberOfFetchesInProgress = BehaviorRelay(value: 0)
    private let gifsManager: GIFsManager
    private let objectsManager: ObjectsManager
    private let disposeBag = DisposeBag()
    
    init(gifsManager: GIFsManager, objectsManager: ObjectsManager) {
        self.gifsManager = gifsManager
        self.objectsManager = objectsManager
        gifsProvider = objectsManager.makeGIFsProvider()
        
        let searchTextBehaviorRelay = BehaviorRelay(value: "")
        self.searchTextBehaviorRelay = searchTextBehaviorRelay
        searchText = searchTextBehaviorRelay.asObservable()
        
        isNoGIFsInfoHidden = Observable
            .combineLatest(gifsProvider.numberOfObjects, searchText, numberOfFetchesInProgress.asObservable())
            .map { $0 > 0 || !$1.isEmpty || $2 > 0 }
        isNoResultsInfoHidden = Observable
            .combineLatest(gifsProvider.numberOfObjects, searchText, numberOfFetchesInProgress.asObservable())
            .map { $0 > 0 || $1.isEmpty || $2 > 0 }
        isActivityInProgress = Observable
            .combineLatest(gifsProvider.numberOfObjects, numberOfFetchesInProgress.asObservable())
            .map { $0 == 0 && $1 > 0 }
        
        setupFetchingPopularGIFsWhenContentIsEmpty()
    }
    
    func accept<O: ObservableType>(searchInput: O) where O.E == String {
        searchInput
            .bind(to: searchTextBehaviorRelay)
            .disposed(by: disposeBag)
        
        var lastSearchInput = ""
        searchTextBehaviorRelay            
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .filter { searchInput in
                let result = searchInput.count > lastSearchInput.count
                lastSearchInput = searchInput
                return result
            }
            .filter { !$0.isEmpty }
            .do(onNext: { [weak self] _ in
                self?.increaseNumberOfFetchesInProgress()
            })
            .flatMap { [gifsManager] searchText in
                gifsManager.fetchGIFs(keyword: searchText)
                    .catchError { _ in Completable.empty() }
                    .andThen(Observable.just(()))
            }
            .do(onNext: { [weak self] in
                self?.decreaseNumberOfFetchesInProgress()
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func setupFetchingPopularGIFsWhenContentIsEmpty() {
        isNoGIFsInfoHidden
            .filter { $0 == false }
            .take(1)
            .do(onNext: { [weak self] _ in
                self?.increaseNumberOfFetchesInProgress()
            })
            .ignoreElements()
            .andThen(gifsManager.fetchPopularGIFs())
            .do(onDispose: { [weak self] in
                self?.decreaseNumberOfFetchesInProgress()
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func increaseNumberOfFetchesInProgress() {
        numberOfFetchesInProgress.accept(numberOfFetchesInProgress.value + 1)
    }
    
    private func decreaseNumberOfFetchesInProgress() {
        numberOfFetchesInProgress.accept(numberOfFetchesInProgress.value - 1)
    }
}
