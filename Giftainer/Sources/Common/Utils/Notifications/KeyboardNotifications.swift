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

    fileprivate var userInfo: [AnyHashable : Any]? {
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
}

class KeyboardWillShowNotification: KeyboardNotification {
}

extension KeyboardWillShowNotification: NotificationDescriptor {
    static let name = Notification.Name.UIKeyboardWillShow
    
    func notification(object: Any?) -> Notification {
        return Notification(name: type(of: self).name,
                            object: object,
                            userInfo: userInfo)
    }
}

class KeyboardDidShowNotification: KeyboardNotification {
}

extension KeyboardDidShowNotification: NotificationDescriptor {
    
    static let name = Notification.Name.UIKeyboardDidShow
    
    func notification(object: Any?) -> Notification {
        return Notification(name: type(of: self).name,
                            object: object,
                            userInfo: nil)
    }
}


class KeyboardWillHideNotification: KeyboardNotification {
}

extension KeyboardWillHideNotification: NotificationDescriptor {
    static let name = Notification.Name.UIKeyboardWillHide
    
    func notification(object: Any?) -> Notification {
        return Notification(name: type(of: self).name,
                            object: object,
                            userInfo: userInfo)
    }
}

struct KeyboardDidHideNotification {
}

extension KeyboardDidHideNotification: NotificationDescriptor {
    
    static let name = Notification.Name.UIKeyboardDidHide
    
    init(notification: Notification) {
    }
    
    func notification(object: Any?) -> Notification {
        return Notification(name: type(of: self).name,
                            object: object,
                            userInfo: nil)
    }
}

class KeyboardWillChangeFrameNotification: KeyboardNotification {
}

extension KeyboardWillChangeFrameNotification: NotificationDescriptor {
    static let name = Notification.Name.UIKeyboardWillChangeFrame
    
    func notification(object: Any?) -> Notification {
        return Notification(name: type(of: self).name,
                            object: object,
                            userInfo: userInfo)
    }
}
