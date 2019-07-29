//
//  KeyboardNotifications.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 02/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import UIKit

class KeyboardNotification {
    let duration: TimeInterval
    let animationOptions: UIViewAnimationOptions
    let endFrame: CGRect

    private var userInfo: [AnyHashable : Any]? {
        return [
            UIKeyboardAnimationDurationUserInfoKey: duration,
            UIKeyboardAnimationCurveUserInfoKey: animationOptions.rawValue,
            UIKeyboardFrameEndUserInfoKey: NSValue(cgRect: endFrame),
        ]
    }
    
    required init(notification: Notification) {
        duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        animationOptions = UIViewAnimationOptions(rawValue: (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uintValue)
        endFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    }

    func notification(object: Any?, name: Notification.Name) -> Notification {
        return Notification(name: name,
                            object: object,
                            userInfo: userInfo)
    }
}

class KeyboardWillShowNotification: KeyboardNotification {
}

extension KeyboardWillShowNotification: NotificationDescriptor {
    static let name = Notification.Name.UIKeyboardWillShow
    
    func notification(object: Any?) -> Notification {
        return notification(object: object, name: type(of: self).name)
    }
}

class KeyboardDidShowNotification: KeyboardNotification {
}

extension KeyboardDidShowNotification: NotificationDescriptor {
    
    static let name = Notification.Name.UIKeyboardDidShow
    
    func notification(object: Any?) -> Notification {
        return notification(object: object, name: type(of: self).name)
    }
}


class KeyboardWillHideNotification: KeyboardNotification {
}

extension KeyboardWillHideNotification: NotificationDescriptor {
    static let name = Notification.Name.UIKeyboardWillHide
    
    func notification(object: Any?) -> Notification {
        return notification(object: object, name: type(of: self).name)
    }
}

class KeyboardDidHideNotification: KeyboardNotification {
}

extension KeyboardDidHideNotification: NotificationDescriptor {
    
    static let name = Notification.Name.UIKeyboardDidHide
    
    func notification(object: Any?) -> Notification {
        return notification(object: object, name: type(of: self).name)
    }
}

class KeyboardWillChangeFrameNotification: KeyboardNotification {
}

extension KeyboardWillChangeFrameNotification: NotificationDescriptor {
    static let name = Notification.Name.UIKeyboardWillChangeFrame
    
    func notification(object: Any?) -> Notification {
        return notification(object: object, name: type(of: self).name)
    }
}
