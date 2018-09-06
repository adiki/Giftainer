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
    
    let updates: Observable<[Update<CoreDataObject.ConvertedType>]>
    
    private let updatesBehaviorRelay = BehaviorRelay<[Update<CoreDataObject.ConvertedType>]>(value: [])
    private let fetchedResultsController: NSFetchedResultsController<CoreDataObject>
    
    private var updatesList: [Update<Object>] = []
    
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
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updatesList = []
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { fatalError("Index path should be not nil") }
            updatesList.append(.insert(newIndexPath))
        case .update:
            guard let newIndexPath = newIndexPath else { fatalError("Index path should be not nil") }
            let obj = object(at: newIndexPath)
            updatesList.append(.update(newIndexPath, obj))
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
