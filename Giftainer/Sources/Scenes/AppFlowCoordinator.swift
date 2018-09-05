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
    }
    
    static func makeAppFlowCoordinator(completion: @escaping (AppFlowCoordinator) -> Void) {
        CoreDataManager.makeObjectsManager { objectsManager in
            let viewModelsFactory = ViewModelsFactory(objectsManager: objectsManager)
            let viewControllersFactory = ViewControllersFactory(viewModelsFactory: viewModelsFactory)
            let appFlowCoordinator = AppFlowCoordinator(viewControllersFactory: viewControllersFactory)
            completion(appFlowCoordinator)
        }
    }
}
