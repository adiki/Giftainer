//
//  NotificationCenter+Extensions.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 02/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation

extension NotificationCenter {
    
    func addObserver<Note: NotificationDescriptor>(queue: OperationQueue? = nil, using block: @escaping (Note) -> ()) -> NotificationToken {
        let token = addObserver(forName: Note.name, object: nil, queue: queue, using: { note in
            block(Note(notification: note))
        })
        return NotificationToken(token: token, center: self)
    }
}
