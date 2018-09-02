//
//  NotificationDescriptor.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 02/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation

protocol NotificationDescriptor {
    
    static var name: Notification.Name { get }
    init(notification: Notification)
    func notification(object: Any?) -> Notification
}
