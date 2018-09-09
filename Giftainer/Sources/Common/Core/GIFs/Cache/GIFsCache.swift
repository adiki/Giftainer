//
//  GIFsCache.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 06/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

class GIFsCache {
    
    enum Event {
        case progress(Float)
        case image(UIImage)
    }
    
    private let fileManager: FileManager
    private let webAPICommunicator: WebAPICommunicator
    private let networkOperationQueue = OperationQueue()
    private let imagesOperationQueue = OperationQueue()
    private let animatedImagesOperationQueue = OperationQueue()
    private let cache = NSCache<NSString, UIImage>()
    private var remoteMP4Operations = [String: RemoteMP4Operation]()
    private var remoteStillOperations = [String: RemoteStillOperation]()
    private let serialQueue = DispatchQueue(label: "GIFsCache")
    private let disposeBag = DisposeBag()
    
    init(fileManager: FileManager, webAPICommunicator: WebAPICommunicator) {
        self.fileManager = fileManager
        self.webAPICommunicator = webAPICommunicator
        
        networkOperationQueue.maxConcurrentOperationCount = 5
        imagesOperationQueue.maxConcurrentOperationCount = 15
        animatedImagesOperationQueue.maxConcurrentOperationCount = 5
        cache.totalCostLimit = Int(min(ProcessInfo.processInfo.physicalMemory / 10, UInt64(Int.max)))
    }
    
    func image(for gif: GIF) -> Observable<Event> {
        
        if let image = cachedImage(key: gif.localStillURL.path) {
            return Observable.just(.image(image))
        }

        return still(forLocalURL: gif.localStillURL)
            .asObservable()
            .catchError { [networkOperationQueue, serialQueue, disposeBag] _ in
                return Observable.create({ observer in
                    let remoteStillOperation = self.remoteStillOperation(for: gif)
                    remoteStillOperation.result
                        .do(onDispose: {
                            serialQueue.async(flags: .barrier) { [weak self] in
                                self?.remoteStillOperations[gif.stillURLString] = nil
                            }
                        })
                        .flatMap { dataEvent -> Observable<Event> in
                            switch dataEvent {
                            case .progress(let progress):
                                return Observable.just(.progress(progress * 0.1))
                            case .data:
                                return self.still(forLocalURL: gif.localStillURL)
                                    .asObservable()
                            }
                        }
                        .subscribe(onNext: { event in
                            observer.onNext(event)
                        }, onError: { error in
                            observer.onError(error)
                        }, onCompleted: {
                            observer.onCompleted()
                        })
                        .disposed(by: disposeBag)
                    
                    if !remoteStillOperation.isFinished
                        && !remoteStillOperation.isCancelled
                        && !networkOperationQueue.operations.contains(remoteStillOperation) {
                        networkOperationQueue.addOperation(remoteStillOperation)
                    }
                    return Disposables.create {
                        remoteStillOperation.cancel()                        
                    }
                })
            }
    }
    
    func animatedImage(for gif: GIF) -> Observable<Event> {
        
        if let image = cachedImage(key: gif.localMP4URL.path) {
            return Observable.just(.image(image))
        }
        
        return animatedImage(forLocalURL: gif.localMP4URL)
            .asObservable()
            .catchError { [networkOperationQueue, serialQueue, disposeBag] _ in
                return Observable.create({ observer in
                    let remoteMP4Operation = self.remoteMP4Operation(for: gif)
                    remoteMP4Operation.result
                        .do(onDispose: {
                            serialQueue.async(flags: .barrier) { [weak self] in
                                self?.remoteMP4Operations[gif.mp4URLString] = nil
                            }
                        })
                        .flatMap { dataEvent -> Observable<Event> in
                            switch dataEvent {
                            case .progress(let progress):
                                return Observable.just(.progress(0.1 + progress * 0.9))
                            case .url:
                                return self.animatedImage(forLocalURL: gif.localMP4URL)
                                    .asObservable()
                            }
                        }
                        .subscribe(onNext: { event in
                            observer.onNext(event)
                        }, onError: { error in
                            observer.onError(error)
                        }, onCompleted: {
                            observer.onCompleted()
                        })
                        .disposed(by: disposeBag)
                    
                    if !remoteMP4Operation.isFinished
                        && !remoteMP4Operation.isCancelled
                        && !networkOperationQueue.operations.contains(remoteMP4Operation) {
                        networkOperationQueue.addOperation(remoteMP4Operation)
                    }
                    return Disposables.create {
                        remoteMP4Operation.cancel()
                    }
                })
        }
    }
    
    private func still(forLocalURL localURL: URL) -> Single<Event> {
        let operation = LocalStillOperation(url: localURL)        
        return single(for: operation, queue: imagesOperationQueue)
    }
    
    private func animatedImage(forLocalURL localURL: URL) -> Single<Event> {
        let operation = LocalMP4Opertation(url: localURL)
        return single(for: operation, queue: animatedImagesOperationQueue)
    }
    
    private func single(for operation: LocalMediaOperation, queue: OperationQueue) -> Single<Event> {
        return Single.create(subscribe: { [disposeBag] observer in
            operation.result
                .subscribe(onNext: { [weak self] image in
                    observer(.success(.image(image)))
                    self?.cache(image: image, key: operation.url.path)
                }, onError: { error in
                    observer(.error(error))                    
                })
                .disposed(by: disposeBag)
                queue.addOperation(operation)
            return Disposables.create {
                operation.cancel()
            }
        })
    }
    
    private func remoteStillOperation(for gif: GIF) -> RemoteStillOperation {
        var remoteStillOperation: RemoteStillOperation!
        serialQueue.sync {
            remoteStillOperation = self.remoteStillOperations[gif.stillURLString]
            if remoteStillOperation == nil || remoteStillOperation!.isCancelled {
                remoteStillOperation = RemoteStillOperation(webAPICommunicator: webAPICommunicator,
                                                            remoteURLString: gif.stillURLString,
                                                            localURL: gif.localStillURL,
                                                            fileManager: fileManager)
            }
            self.remoteStillOperations[gif.stillURLString] = remoteStillOperation
        }
        return remoteStillOperation
    }
    
    private func remoteMP4Operation(for gif: GIF) -> RemoteMP4Operation {
        var remoteMP4Operation: RemoteMP4Operation!
        serialQueue.sync {
            remoteMP4Operation = self.remoteMP4Operations[gif.mp4URLString]
            if remoteMP4Operation == nil || remoteMP4Operation!.isCancelled {
                remoteMP4Operation = RemoteMP4Operation(webAPICommunicator: webAPICommunicator,
                                                        remoteURLString: gif.mp4URLString,
                                                        localURL: gif.localMP4URL,
                                                        fileManager: fileManager)
            }
            self.remoteMP4Operations[gif.mp4URLString] = remoteMP4Operation
        }
        return remoteMP4Operation
    }
    
    private func cachedImage(key: String) -> UIImage? {
        var image: UIImage?
        serialQueue.sync { [cache] in
            image = cache.object(forKey: key as NSString)
        }
        return image
    }
    
    private func cache(image: UIImage, key: String) {
        if let cost = image.cacheCost {
            serialQueue.async(flags: .barrier) { [cache] in
                cache.setObject(image, forKey: key as NSString, cost: cost)
            }
        }
    }
}
