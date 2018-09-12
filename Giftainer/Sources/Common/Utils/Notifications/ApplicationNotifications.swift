//
//  ApplicationNotifications.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 12/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation

public struct ApplicationWillEnterForegroundNotification {
}

extension ApplicationWillEnterForegroundNotification: NotificationDescriptor {
    
    public static let name = Notification.Name.UIApplicationWillEnterForeground
    
    public init(notification: Notification) {
    }
    
    public func notification(object: Any?) -> Notification {
        return Notification(name: type(of: self).name,
                            object: object,
                            userInfo: nil)
    }
}
