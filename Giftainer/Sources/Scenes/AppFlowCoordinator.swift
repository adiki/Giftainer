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
    
    static func makeAppFlowCoordinator() -> AppFlowCoordinator {
        let viewControllersFactory = ViewControllersFactory()
        return AppFlowCoordinator(viewControllersFactory: viewControllersFactory)
    }
}
