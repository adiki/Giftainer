//
//  AppDelegate.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 01/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var appFlowCoordinator: AppFlowCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        setupAppFlowCoordinator()
        
        return true
    }
    
    private func setupAppFlowCoordinator() {
        AppFlowCoordinator.makeAppFlowCoordinator { appFlowCoordinator in
            let frame = UIScreen.main.bounds
            let window = UIWindow(frame: frame)
            window.backgroundColor = .white
            self.window = window
            self.appFlowCoordinator = appFlowCoordinator
            window.rootViewController = appFlowCoordinator.rootViewController
            window.makeKeyAndVisible()
        }
    }
}

