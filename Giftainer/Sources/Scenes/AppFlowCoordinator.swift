//
//  AppFlowCoordinator.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 01/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import UIKit

class AppFlowCoordinator: FlowCoordinator {
    
    var rootViewController: UIViewController {
        return navigationController
    }
    private let viewControllersFactory: ViewControllersFactory
    private let navigationController: UINavigationController
    
    init(viewControllersFactory: ViewControllersFactory) {
        self.viewControllersFactory = viewControllersFactory
        let feedViewController = viewControllersFactory.makeFeedViewController()
        navigationController = UINavigationController(rootViewController: feedViewController)
        navigationController.navigationBar.barTintColor = .snapperRocksBlue
        navigationController.navigationBar.isTranslucent = true
        
        feedViewController.events
            .subscribe(onNext: { [weak self] event in
                self?.handle(feedSceneEvent: event)
            })
            .disposed(by: feedViewController.disposeBag)
    }
    
    private func handle(feedSceneEvent: FeedSceneEvent) {
        switch feedSceneEvent {
        case let .share(urlString, sourceView):
            share(urlString: urlString, sourceView: sourceView)
        }
    }
    
    private func share(urlString: String, sourceView: UIView) {
        let activityViewController = UIActivityViewController(activityItems: [urlString],
                                                              applicationActivities: nil)
        if let popoverPresentationController = activityViewController.popoverPresentationController {
            popoverPresentationController.sourceView = sourceView
            popoverPresentationController.sourceRect = sourceView.bounds
        }
        rootViewController.present(activityViewController, animated: true)
    }
    
    static func makeAppFlowCoordinator(completion: @escaping (AppFlowCoordinator) -> Void) {
        CoreDataManager.makeObjectsManager { objectsManager in
            let webAPICommunicator = WebAPICommunicator.makeWebAPICommunicator()
            let gifsMetadataFetcher = GiphyMetadataFetcher(webAPICommunicator: webAPICommunicator)
            let gifsManager = GIFsManager(gifsMetadataFetcher: gifsMetadataFetcher,
                                          objectsManager: objectsManager)
            let viewModelsFactory = ViewModelsFactory(gifsManager: gifsManager,
                                                      objectsManager: objectsManager)
            let fileManager = FileManager.default
            let gifsCache = GIFsCache(fileManager: fileManager,
                                      webAPICommunicator: webAPICommunicator)
            let viewControllersFactory = ViewControllersFactory(viewModelsFactory: viewModelsFactory,
                                                                gifsCache: gifsCache)
            let appFlowCoordinator = AppFlowCoordinator(viewControllersFactory: viewControllersFactory)
            completion(appFlowCoordinator)
        }
    }
}
