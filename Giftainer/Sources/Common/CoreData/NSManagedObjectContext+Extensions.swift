//
//  NSManagedObjectContext+Extensions.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 02/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import CoreData

struct ContextDidSaveNotification {
    
    init(note: Notification) {
        guard note.name == .NSManagedObjectContextDidSave else { fatalError() }
        notification = note
    }
    
    var insertedObjects: AnyIterator<NSManagedObject> {
        return iterator(forKey: NSInsertedObjectsKey)
    }
    
    var updatedObjects: AnyIterator<NSManagedObject> {
        return iterator(forKey: NSUpdatedObjectsKey)
    }
    
    var deletedObjects: AnyIterator<NSManagedObject> {
        return iterator(forKey: NSDeletedObjectsKey)
    }
    
    var managedObjectContext: NSManagedObjectContext {
        guard let c = notification.object as? NSManagedObjectContext else { fatalError("Invalid notification object") }
        return c
    }
    
    fileprivate let notification: Notification
    
    fileprivate func iterator(forKey key: String) -> AnyIterator<NSManagedObject> {
        guard let set = (notification as Notification).userInfo?[key] as? NSSet else {
            return AnyIterator { nil }
        }
        var innerIterator = set.makeIterator()
        return AnyIterator { return innerIterator.next() as? NSManagedObject }
    }
    
}
extension NSManagedObjectContext {
    
    func insertObject<A: NSManagedObject>() -> A where A: Managed {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A else { fatalError("Wrong object type") }
        return obj
    }
    
    func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            rollback()
            return false
        }
    }
    
    func performSaveOrRollback() {
        perform {
            _ = self.saveOrRollback()
        }
    }
    
    func performChanges(block: @escaping () -> ()) {
        perform {
            block()
            _ = self.saveOrRollback()
        }
    }
}

extension NSManagedObjectContext {
    
    func addContextDidSaveNotificationObserver(_ handler: @escaping (ContextDidSaveNotification) -> ()) -> NSObjectProtocol {
        let nc = NotificationCenter.default
        return nc.addObserver(forName: .NSManagedObjectContextDidSave, object: self, queue: nil) { note in
            let wrappedNote = ContextDidSaveNotification(note: note)
            handler(wrappedNote)
        }
    }
    
    func performMergeChanges(from note: ContextDidSaveNotification) {
        perform {
            self.mergeChanges(fromContextDidSave: note.notification)
        }
    }
}
