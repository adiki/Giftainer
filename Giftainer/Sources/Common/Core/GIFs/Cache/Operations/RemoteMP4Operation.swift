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
    
    override init(webAPICommunicator: WebAPICommunicator, remoteURLString: String, localURL: URL, fileManager: FileManager, logger: Logger) {
        result = resultPublishSubject.asObservable()
        super.init(webAPICommunicator: webAPICommunicator,
                   remoteURLString: remoteURLString,
                   localURL: localURL,
                   fileManager: fileManager,
                   logger: logger)
    }
    
    override func execute() {
        disposable = webAPICommunicator.download(urlString: remoteURLString)
            .flatMap { [fileManager, logger, localURL] event -> Observable<WebAPICommunicator.DownloadEvent> in
                if case .url(let url) = event {
                    do {
                        try fileManager.createDirectory(at: localURL.deletingLastPathComponent(),
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
                        try fileManager.moveItem(at: url, to: localURL)
                    } catch {
                        logger.log(error.localizedDescription)
                        return .error(GIFsError.cannotSaveMP4OnDisk)
                    }
                }
                return .just(event)
            }
            .do(onDispose: { [weak self] in
                self?.finish()
            })
            .subscribe { [weak self] event in
                self?.resultPublishSubject.on(event)
            }
    }
    
    override func cancel() {
        super.cancel()
        disposable?.dispose()
        resultPublishSubject.dispose()
    }
}
