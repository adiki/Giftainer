//
//  RemoteStillOperation.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 09/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import RxSwift

class RemoteStillOperation: RemoteMediaOperation {
    
    var disposable: Disposable?
    
    let result: Observable<WebAPICommunicator.DataEvent>
    let resultPublishSubject = PublishSubject<WebAPICommunicator.DataEvent>()
    
    override init(webAPICommunicator: WebAPICommunicator, remoteURLString: String, localURL: URL, fileManager: FileManager) {
        result = resultPublishSubject.asObservable()
        super.init(webAPICommunicator: webAPICommunicator,
                   remoteURLString: remoteURLString,
                   localURL: localURL,
                   fileManager: fileManager)
    }
    
    override func execute() {
        disposable = webAPICommunicator.data(urlString: remoteURLString)
            .do(onNext: { [weak self, resultPublishSubject, fileManager, localURL] event in
                if fileManager.fileExists(atPath: localURL.path) {
                    if let data = try? Data(contentsOf: localURL) {
                        resultPublishSubject.onNext(.data(data))
                    }                    
                    self?.cancel()
                }
                if case .data(let data) = event {
                    do {
                        try fileManager.createDirectory(at: localURL.deletingLastPathComponent(),
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
                        try data.write(to: localURL)
                    } catch {
                        Log(error.localizedDescription)
                    }
                }
            })
            .subscribe(onNext: { [resultPublishSubject] event in
                resultPublishSubject.onNext(event)
            }, onError: { [resultPublishSubject] error in
                resultPublishSubject.onError(error)
            }, onCompleted: { [resultPublishSubject] in
                resultPublishSubject.onCompleted()
            }, onDisposed: {
                self.finish()                
            })
    }
    
    override func cancel() {
        super.cancel()
        disposable?.dispose()
        resultPublishSubject.dispose()
    }
}
