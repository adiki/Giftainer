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
    
    private var disposable: Disposable?
    
    let result: Observable<WebAPICommunicator.DataEvent>
    private let resultPublishSubject = PublishSubject<WebAPICommunicator.DataEvent>()
    
    override init(webAPICommunicator: WebAPICommunicator, remoteURLString: String, localURL: URL, fileManager: FileManager, logger: Logger) {
        result = resultPublishSubject.asObservable()
        super.init(webAPICommunicator: webAPICommunicator,
                   remoteURLString: remoteURLString,
                   localURL: localURL,
                   fileManager: fileManager,
                   logger: logger)
    }
    
    override func execute() {
        disposable = webAPICommunicator.data(urlString: remoteURLString)
            .flatMap { [fileManager, logger, localURL] event -> Observable<WebAPICommunicator.DataEvent> in
                if case .data(let data) = event {
                    do {
                        try fileManager.createDirectory(at: localURL.deletingLastPathComponent(),
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
                        try data.write(to: localURL)
                    } catch {
                        logger.log(error.localizedDescription)
                        return .error(GIFsError.cannotSaveImageOnDisk)
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
