//
//  CoreDataModelsProvider.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 02/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import CoreData
import Foundation
import RxCocoa
import RxSwift

class CoreDataObjectsProvider<CoreDataObject: Convertible>: NSObject, ObjectsProvider, NSFetchedResultsControllerDelegate where CoreDataObject: NSFetchRequestResult {
    
    let updates: Observable<[Update]>
    
    private let updatesBehaviorRelay = BehaviorRelay<[Update]>(value: [])
    private let fetchedResultsController: NSFetchedResultsController<CoreDataObject>
    
    private var updatesList: [Update] = []
    
    init(fetchedResultsController: NSFetchedResultsController<CoreDataObject>) {
        self.fetchedResultsController = fetchedResultsController
        try! fetchedResultsController.performFetch()
        updates = updatesBehaviorRelay.asObservable()
        
        super.init()
        
        fetchedResultsController.delegate = self
    }
    
    func numberOfObjects() -> Int {
        return fetchedResultsController.numberOfObjects
    }
    
    func object(at indexPath: IndexPath) -> CoreDataObject.ConvertedType {
        return fetchedResultsController.object(at: indexPath).convert()
    }
    
    func set(predicate: NSPredicate) {
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: fetchedResultsController.cacheName)
        fetchedResultsController.fetchRequest.predicate = predicate
        do { try fetchedResultsController.performFetch() } catch { fatalError("fetch request failed") }
        updatesBehaviorRelay.accept([])
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updatesList = []
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { fatalError("Index path should be not nil") }
            updatesList.append(.insert(newIndexPath))
        case .update:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            guard let newIndexPath = newIndexPath else { fatalError("Index path should be not nil") }
            if indexPath != newIndexPath {
                updatesList.append(.move(indexPath, newIndexPath))
            } else {
                updatesList.append(.update(indexPath))
            }
        case .move:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            guard let newIndexPath = newIndexPath else { fatalError("New index path should be not nil") }
            updatesList.append(.move(indexPath, newIndexPath))
        case .delete:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            updatesList.append(.delete(indexPath))
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updatesBehaviorRelay.accept(updatesList)
    }
}
