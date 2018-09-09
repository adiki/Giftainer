//
//  WebAPICommunicator.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 05/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class WebAPICommunicator: NSObject {
    
    enum WebAPIError: LocalizedError {
        case invalidURL
        case invalidResponse
        
        var errorDescription: String? {
            switch self {
            case .invalidURL, .invalidResponse:
                return .We_have_an_issue_will_get_back_to_you
            }
        }
    }
    
    enum DataEvent {
        case progress(Float)
        case data(Data)
    }
    
    enum DownloadEvent {
        case progress(Float)
        case url(URL)
    }
    
    private var urlSession: URLSession!
    private var fileManager: FileManager
    private let decoder: JSONDecoder
    private var dataObservers = [Int: (AnyObserver<DataEvent>, Data)]()
    private var downloadObservers = [Int: AnyObserver<DownloadEvent>]()
    private let observersQueue = DispatchQueue(label: "WebAPICommunicator",
                                               qos: .userInitiated,
                                               attributes: .concurrent)
    
    init(fileManager: FileManager, decoder: JSONDecoder) {
        self.fileManager = fileManager
        self.decoder = decoder
        decoder.dateDecodingStrategy = .formatted(.webAPIDateFormater)
        super.init()
        Logging.URLRequests = { _ in return true }
    }
    
    static func makeWebAPICommunicator() -> WebAPICommunicator {
        let fileManager = FileManager.default
        let decoder = JSONDecoder()
        let webAPICommunicator = WebAPICommunicator(fileManager: fileManager, decoder: decoder)
        let configuration = URLSessionConfiguration.default
        webAPICommunicator.urlSession = URLSession(configuration: configuration,
                                                   delegate: webAPICommunicator,
                                                   delegateQueue: nil)
        return webAPICommunicator
    }
    
    func data(urlString: String) -> Observable<DataEvent> {        
        guard let url = URL(string: urlString) else {
            return Observable.error(WebAPIError.invalidURL)
        }
        
        return Observable<DataEvent>.create({ [urlSession, observersQueue] observer in
            let dataTask = urlSession!.dataTask(with: url)
            observersQueue.async(flags: .barrier) {
                self.dataObservers[dataTask.taskIdentifier] = (observer, Data())
                dataTask.resume()
            }
            return Disposables.create {
                dataTask.cancel()
                observersQueue.async(flags: .barrier) { [weak self] in
                    self?.dataObservers[dataTask.taskIdentifier] = nil
                }
            }
        })
    }
    
    func download(urlString: String) -> Observable<DownloadEvent> {
        guard let url = URL(string: urlString) else {
            return Observable.error(WebAPIError.invalidURL)
        }
        
        return Observable<DownloadEvent>.create({ [urlSession, observersQueue] observer in
            let downloadTask = urlSession!.downloadTask(with: url)
            observersQueue.async(flags: .barrier) {
                self.downloadObservers[downloadTask.taskIdentifier] = observer
                downloadTask.resume()
            }
            return Disposables.create {
                downloadTask.cancel()
                observersQueue.async(flags: .barrier) { [weak self] in
                    self?.downloadObservers[downloadTask.taskIdentifier] = nil
                }
            }
        })
    }
    
    func GET<SuccessResponse>(method: WebAPIMethod<SuccessResponse>) -> Single<SuccessResponse> {
        let request = makeGETRequest(method: method)
        return urlSession.rx.data(request: request)
            .asSingle()
            .flatMap(handleResponse)
    }
    
    private func makeGETRequest<SuccessResponse>(method: WebAPIMethod<SuccessResponse>) -> URLRequest {
        let url = method.urlWithEncodedParameters
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
    
    private func handleResponse<SuccessResponse: Decodable>(data: Data) -> Single<SuccessResponse> {
        guard let response = try? decoder.decode(SuccessResponse.self, from: data) else {
            return Single.error(WebAPIError.invalidResponse)
        }
        return Single.just(response)        
    }
}

extension WebAPICommunicator: URLSessionDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        observersQueue.async(flags: .barrier) { [weak self] in
            guard let (observer, data) = self?.dataObservers[task.taskIdentifier] else {
                return
            }
            observer.onNext(.progress(1))
            observer.onNext(.data(data))
            observer.on(.completed)
            self?.dataObservers[task.taskIdentifier] = nil
        }
    }
}

extension WebAPICommunicator: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        observersQueue.async { [weak self] in
            guard let (observer, buffer) = self?.dataObservers[dataTask.taskIdentifier] else {
                return
            }
            let progress = Float(dataTask.countOfBytesReceived) / Float(dataTask.countOfBytesExpectedToReceive)
            observer.onNext(.progress(progress))
            var d = buffer
            d.append(data)
            self?.dataObservers[dataTask.taskIdentifier] = (observer, d)
        }
    }
}

extension WebAPICommunicator: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let temporaryDocumentsMP4URL = URL.temporaryDocumentsMP4URL
        do {
            try fileManager.moveItem(at: location, to: temporaryDocumentsMP4URL)
        } catch {
            Log(error.localizedDescription)
        }
        
        observersQueue.async(flags: .barrier) { [weak self] in
            guard let observer = self?.downloadObservers[downloadTask.taskIdentifier] else {
                return
            }
            observer.onNext(.progress(1))
            observer.onNext(.url(temporaryDocumentsMP4URL))
            observer.on(.completed)
            self?.downloadObservers[downloadTask.taskIdentifier] = nil
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        observersQueue.async { [weak self] in
            guard let observer = self?.downloadObservers[downloadTask.taskIdentifier] else {
                return
            }
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            observer.onNext(.progress(progress))
        }
    }
}
