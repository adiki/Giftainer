//
//  RemoteMP4Operation.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 09/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import RxSwift

class RemoteMP4Operation: RemoteMediaOperation {
    
    var disposable: Disposable?
    
    let result: Observable<WebAPICommunicator.DownloadEvent>
    let resultPublishSubject = PublishSubject<WebAPICommunicator.DownloadEvent>()
    
    override init(webAPICommunicator: WebAPICommunicator, remoteURLString: String, localURL: URL, fileManager: FileManager) {
        result = resultPublishSubject.asObservable()
        super.init(webAPICommunicator: webAPICommunicator,
                   remoteURLString: remoteURLString,
                   localURL: localURL,
                   fileManager: fileManager)
    }
    
    override func execute() {
        disposable = webAPICommunicator.download(urlString: remoteURLString)
            .do(onNext: { [weak self, resultPublishSubject, fileManager, localURL] event in
                if fileManager.fileExists(atPath: localURL.path) {
                    resultPublishSubject.onNext(.url(localURL))
                    self?.cancel()
                }
                if case .url(let url) = event {
                    do {
                        try fileManager.createDirectory(at: localURL.deletingLastPathComponent(),
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
                        
                        try fileManager.moveItem(at: url, to: localURL)
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
