//
//  KeyboardNotifications.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 02/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import UIKit

protocol KeyboardNotification {
    
    var duration: TimeInterval { get set }
    var animationOptions: UIViewAnimationOptions { get set }
    var endFrame: CGRect { get set }
    
    var userInfo: [AnyHashable: Any]? { get }
    
    init()
    init(notification: Notification)
}

extension KeyboardNotification {
    
    var userInfo: [AnyHashable: Any]? {
        return nil
    }
    
    init(notification: Notification) {
        self.init()
        duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        animationOptions = UIViewAnimationOptions(rawValue: (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uintValue)
        endFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue        
    }
}

struct KeyboardWillShowNotification: KeyboardNotification {
    var duration: TimeInterval
    var animationOptions: UIViewAnimationOptions
    var endFrame: CGRect
    
    init() {
        duration = 0
        animationOptions = .curveLinear
        endFrame = .zero
    }
}

extension KeyboardWillShowNotification: NotificationDescriptor {
    static let name = Notification.Name.UIKeyboardWillShow
    
    func notification(object: Any?) -> Notification {
        return Notification(name: type(of: self).name,
                            object: object,
                            userInfo: userInfo)
    }
}

struct KeyboardDidShowNotification: KeyboardNotification {
    var duration: TimeInterval
    var animationOptions: UIViewAnimationOptions
    var endFrame: CGRect
    
    init() {
        duration = 0
        animationOptions = .curveLinear
        endFrame = .zero
    }
}

extension KeyboardDidShowNotification: NotificationDescriptor {
    
    static let name = Notification.Name.UIKeyboardDidShow
    
    func notification(object: Any?) -> Notification {
        return Notification(name: type(of: self).name,
                            object: object,
                            userInfo: nil)
    }
}


struct KeyboardWillHideNotification: KeyboardNotification {
    var duration: TimeInterval
    var animationOptions: UIViewAnimationOptions
    var endFrame: CGRect
    
    init() {
        duration = 0
        animationOptions = .curveLinear
        endFrame = .zero
    }
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

struct KeyboardWillChangeFrameNotification: KeyboardNotification {
    var duration: TimeInterval
    var animationOptions: UIViewAnimationOptions
    var endFrame: CGRect
    
    init() {
        duration = 0
        animationOptions = .curveLinear
        endFrame = .zero
    }
}

extension KeyboardWillChangeFrameNotification: NotificationDescriptor {
    static let name = Notification.Name.UIKeyboardWillChangeFrame
    
    func notification(object: Any?) -> Notification {
        return Notification(name: type(of: self).name,
                            object: object,
                            userInfo: userInfo)
    }
}
